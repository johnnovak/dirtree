# dirtree

Render directory trees as pretty pictures.


## Prerequisites

The [Cairo](https://www.cairographics.org/download/) dynamic-link libraries
must be available for the program.

### Windows

Download the DLL files from [here]([Cairo](https://www.cairographics.org/download/)) and put it in the program directory.

### macOS

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

## License

This work is free. You can redistribute it and/or modify it under the terms of
the [Do What The Fuck You Want To Public License, Version 2](http://www.wtfpl.net/),
as published by Sam Hocevar. See the [COPYING](./COPYING) file for more
details.
