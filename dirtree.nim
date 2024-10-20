import std/algorithm
import std/lenientops
import std/options
import std/strformat
import std/strutils

import cairo

# {{{ Types
type
  NodeType = enum
    ntDir, ntFile, ntSpacer, ntEllipses

  NodeObj = object
    name:     string
    nodeType: NodeType
    children: seq[Node]
    parent:   Node
    layout:   Layout

  Node = ref NodeObj

  Layout = object
    x: float
    y: float

  Config = object
    dpi:            float

    imageWidth:     Natural
    imageHeight:    Natural
    imageHorizPad:  float
    imageVertPad:   float
    imageBgColor:   Option[Color]

    nameFontName:   string
    nameFontSize:   float
    nameIndent:     float
    nameHeight:     float
    nameColor:      Color

    iconFontName:   string
    iconFontSize:   float
    iconHorizPad:   float
    iconVertOffs:   float
    iconFolder:     string
    iconColor:      Color

    spacerHeight:   float

    lineIndent:     float
    lineWidth:      float
    lineVertOffs:   float
    lineHorizPad:   float
    lineVertPad:    float
    lineColor:      Color

  Color = object
    r: float
    g: float
    b: float
    a: float

# }}}

# {{{ Color helpers
proc rgb(r, g, b: float): Color =
  Color(r: r, g: g, b: b, a: 1.0)

proc rgba(r, g, b, a: float): Color =
  Color(r: r, g: g, b: b, a: a)

proc setSourceRgba(c: ptr Context, color: Color) =
    c.setSourceRgba(color.r, color.g, color.b, color.a)

# }}}

# {{{ getLevel()
proc getLevel(s: string): Natural =
  var indent = 0
  for c in s:
    if c == ' ': inc(indent)
    elif c == '\t':
      raise newException(IOError, "must only use spaces for indentation")
    else: break

  if indent mod 2 != 0:
    raise newException(IOError, "must use even number of spaces for indentation")

  indent div 2

# }}}
# {{{ parseTree()
proc parseTree(s: string): Node =
  let tree: Node = Node(
    name: "root", nodeType: ntDir, children: @[], parent: nil
  )
  var
    currLine   = 0
    currLevel  = 0
    currParent = tree
    lastNode: Node = nil

  try:
    for idx, line in s.splitLines().pairs():
      currLine = idx + 1

      let name = line.strip
      var node = Node(
        name:     name,
        nodeType: if name.contains('.'): ntFile else: ntDir,
        children: @[]
      )
      if name.len == 0:
        node.nodeType = ntSpacer
        currParent.children.add(node)
        continue

      let level = getLevel(line)
      if level == currLevel:
        discard # no-op

      elif level == currLevel + 1:
        currParent = lastNode
        lastNode.nodeType = ntDir

      else:
        for _ in 0..<(currLevel - level):
          currParent = currParent.parent

      if name == "...":
        node.nodeType = ntEllipses

      node.parent = currParent
      currParent.children.add(node)

      lastNode  = node
      currLevel = level

  except CatchableError as e:
    echo fmt"ERROR: line {currLine}: {e.msg}"
    quit(1)

  tree

# }}}
# {{{ debugPrint()
proc debugPrint(node: Node, level: Natural = 0) =
  let indent = "  ".repeat(level)
  echo fmt"{indent}{node.name}"
  for n in node.children:
    debugPrint(n, level + 1)

# }}}

# {{{ doLayout()
proc doLayout(node: Node, conf: Config) =
  var y = conf.nameFontSize

  proc walk(node: Node, level: Natural) =
    if node.parent != nil:
      node.layout.x = conf.imageHorizPad + (level-1) * conf.nameIndent
      node.layout.y = conf.imageVertPad + y

      if node.nodeType == ntSpacer: y += conf.spacerHeight
      else:                         y += conf.nameHeight

    for n in node.children:
      walk(n, level+1)

  walk(node, level=0)

# }}}
# {{{ renderImage()
proc renderImage(node: Node, conf: Config): ptr Surface =
  var
    image = imageSurfaceCreate(FORMAT_ARGB32,
                               conf.imageWidth.int32, conf.imageHeight.int32)
    c = image.create()

  const DefaultDpi = 72.0
  let scale = conf.dpi / DefaultDpi
  c.scale(scale, scale)

  # comment out for transparent background
  if conf.imageBgColor.isSome:
    c.setSourceRgba(conf.imageBgColor.get)

  c.rectangle(0, 0, conf.imageWidth.float, conf.imageHeight.float)
  c.fill()

  c.setLineWidth(conf.lineWidth)

  proc walk(node: Node, isLastNode: bool = false) =
    let nl = node.layout

    if node.parent != nil:
      if node.nodeType == ntEllipses:
        c.moveTo(nl.x, nl.y - conf.nameFontSize / 2)

      elif node.nodeType == ntDir:
        c.moveTo(nl.x, nl.y - conf.iconFontSize * conf.iconVertOffs)
        c.selectFontFace(conf.iconFontName, FontSlantNormal, FontWeightNormal)
        c.setFontSize(conf.iconFontSize)
        c.setSourceRgba(conf.iconColor)
        c.showText(conf.iconFolder)

        c.moveTo(nl.x + conf.iconHorizPad, nl.y)

      else:
        c.moveTo(nl.x, nl.y)

      c.selectFontFace(conf.nameFontName, FontSlantNormal, FontWeightNormal)
      c.setFontSize(conf.nameFontSize)
      c.setSourceRgba(conf.nameColor)
      c.showText(node.name.cstring)

      if node.nodeType in {ntDir, ntFile} and
         (node.parent != nil and node.parent.parent != nil):

        let
          pl = node.parent.layout
          x1 = nl.x - conf.lineHorizPad
          y1 = nl.y - conf.nameFontSize * conf.lineVertOffs
          x2 = pl.x + conf.lineIndent
          y2 = pl.y + conf.lineVertPad

        c.setSourceRgba(conf.lineColor)
        c.moveTo(x1, y1)
        c.lineTo(x2, y1)
        if isLastNode:
          c.lineTo(x2, y2)

        c.stroke()

    var lastNodeFound = false
    for idx, n in node.children.reversed():
      let isLastNode = if lastNodeFound: false
                       else: n.nodeType in {ntDir, ntFile}
      if isLastNode:
        lastNodeFound = true

      walk(n, isLastNode)

  walk(node)
  image

# }}}

include "config1.nim"

let
  contents = readFile("examples/ex1.txt")
  tree = parseTree(contents)

#debugPrint(tree)
doLayout(tree, conf)

var image = renderImage(tree, conf)
discard image.writeToPng("tree.png")

# vim: et:ts=2:sw=2:fdm=marker
