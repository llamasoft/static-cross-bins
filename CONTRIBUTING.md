# Contributing

Adding your favorite program to this project is easy!


## Getting Started

Starting by taking a look at the [makefile template](include/_template.mak) provided with this project.
It includes all of the required makefile components in addition to an explanation of what each section does.

Next, take a look at some of the makefiles for simpler programs like [tcpdump](include/tcpdump.mak) and libraries like [zlib](include/zlib.mak).

Lastly, experiment with what it takes to compile your program manually.  
You'll need to work out details such as:

- Is running `autoreconf` required?
  - For some packages on certain build machines (e.g. [ncurses](include/ncurses.mak) on macOS), running autoreconf will cause the build to fail.
  - For other packages, autoreconf (e.g. [netcat](include/netcat.mak)) is mandatory.
  - If possible, avoid running autoreconf unless absolutely necessary.
- Does the package use a regular GNU Autoconf `configure` script or something custom?
  - Regular configure scripts should always use the standard values for `--host`, `--prefix`, etc.
  - Custom configure scripts may need these values supplied differently (e.g. [OpenSSL](include/openssl.mak)).
  - Other packages may not use a configure script at all (e.g. [busybox](include/busybox.mak) and [zstd](include/zstd.mak)).
- What options or flags are required for a static build?
- Does the package use libtool?
- Does the package depend on any libraries?

To make experimentation easier, use `make TARGET=... env` to dump the environment variables set by the toolkit.  
Importing these values into the shell environment will "activate" the cross-compiler toolchain so that most
makefiles and configuration scripts will use the cross-compiler instead of the system's default compiler.


## Selecting a Program

When selecting a program to contribute, it should:
- Be written in C/C++.
- Be reasonably small in size.
- Be something that other people might want to use.
- Result in a self-contained binary with no external dependencies.


## Pull Request Requirements

When submitting a pull request, please ensure that:

- The output program(s) are *actually* statically linked.
  - For some packages, `--disable-shared` and `--enable-static` alone are not enough (e.g. [curl](include/curl.mak)).
  - The `file` utility can be used to determine if the output program was statically linked.
- The output program(s) are *actually* cross-compiled for the selected target.
  - Some packages like [busybox](include/busybox.mak) may attempt to ignore the toolkit's
    environment variables and use the system's default compiler instead.
  - The `file` utility can be used to approximate the output program's target.
  - `sysroot/[TARGET]/bin/[TARGET]-readelf -A` can be used to inspect detailed architecture information.
- The package builds successfully for multiple cross-compiler targets.
  - Packages that depend on platform-specific assembly code may fail to build for other targets.
- Makefiles for any required libraries are also included in the pull request.

While not required, I strongly recommending testing your package by building it with the [docker_build.sh](docker_build.sh) script.  
This is a good way to check for reproducibility, missing dependencies, or build ordering issues.