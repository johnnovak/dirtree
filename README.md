# dirtree

Render directory trees as pretty pictures from plaintext descriptions.

### Source file

```
DOS Games
  Passport to Adventure
    drives
      c
    dosbox.conf

  Prince of Persia
    drives
      c
    dosbox.conf
```

### Result

<img src="https://github.com/user-attachments/assets/ef399db3-562c-4cde-8eee-9d9227f8bbb6" alt="Example directory tree output" width="350">

## Usage

1. Make sure the [prerequisites](#prerequisites) are met.
2. Compile with `nim c src/dirtree`.
3. Run `dirtree input.txt output.png` (check out the [examples](examples)).
4. To change the visual style, edit `src/config1.nim` and then recompile. 


## Prerequisites

### Cairo

The [Cairo](https://www.cairographics.org/download/) dynamic-link libraries
must be available for the program.

#### Windows

Download the DLL files from [here]([Cairo](https://www.cairographics.org/download/))
and put it in the program directory.

#### macOS

Install the Cairo libraries via MacPorts or a similar package manager, then set
`DYLD_LIBRARY_PATH` accordingly.

```sh
export DYLD_LIBRARY_PATH=/opt/local/lib
./dirtree
```

Or:

```sh
DYLD_LIBRARY_PATH=/opt/local/lib ./dirtree
```

Make sure the architecture of the executable and the dynamic-link library
match (so both are either `arm64` or `x86_64`), otherwise you'll get errors at
startup. You can check this with the `file` command.

The Nim compiler installed via [choosenim](https://github.com/dom96/choosenim)
always creates `x86_64` executables by default, so you'll need to override that
in `nim.cfg` by uncomment the following:

```nim
# macOS, arm64
--l:"-target arm64-apple-macos11"
--t:"-target arm64-apple-macos11"
```

### Installing the icon font

Unpack the [fonts/Folder-Icons-v1.0.zip](fonts/Folder-Icons-v1.0.zip) ZIP file
and install the `fonts/Folder-Icons.ttf` font at the OS level..


## Working with the icon font

Unpack the [fonts/Folder-Icons-v1.0.zip](fonts/Folder-Icons-v1.0.zip) ZIP file
and open `demo.html` to see the list of available icon glyphs.

The easiest way to edit the font is to use the
[IcoMoon](https://icomoon.io/app/) webapp:

1. Go to the [Projects](https://icomoon.io/app/#/projects) view.
2. Click **Import Project**, then select the file `selection.json` from the
   unpacked ZIP.
3. This will show up as "Untitled Project"—rename that to something more
   meaningful, then click **Load**.
4. Do your edits, then click on **Generate Font** and **Download** in the
   bottom menu bar when you're done.


## License

This work is free. You can redistribute it and/or modify it under the terms of
the [Do What The Fuck You Want To Public License, Version 2](http://www.wtfpl.net/),
as published by Sam Hocevar. See the [COPYING](./COPYING) file for more
details.
