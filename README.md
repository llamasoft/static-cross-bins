# Static Cross-compiler Automation Toolkit
## A toolkit that simplifies cross-compiling static binaries for any Linux target.

[![Automated Releases](https://github.com/llamasoft/static-cross-bins/actions/workflows/release.yml/badge.svg)](https://github.com/llamasoft/static-cross-bins/actions/workflows/release.yml)

Currently supported:
- Binaries: 
  [bash](include/bash.mak),
  [busybox](include/busybox.mak),
  [curl](include/curl.mak),
  [dropbear](include/dropbear.mak),
  [netcat](include/netcat.mak),
  [nmap](include/nmap.mak),
  [socat](include/socat.mak),
  [strace](include/strace.mak),
  [tcpdump](include/tcpdump.mak),
  [zstd](include/zstd.mak)
- Libraries:
  [curl](include/curl.mak),
  [libressl](librinclude/libressl.mak),
  [ncurses](ncuinclude/ncurses.mak),
  [openssl](opeinclude/openssl.mak),
  [pcap](include/pcap.mak),
  [readline](readinclude/readline.mak),
  [wolfssl](wolinclude/wolfssl.mak),
  [zlib](include/zlib.mak)

🤖 Pre-compiled binaries for common targets can be found on the [releases page](https://github.com/llamasoft/static-cross-bins/releases)!

**Pull requests are welcome!**  
Want to add your favorite tool?  See [CONTRIBUTING](CONTRIBUTING.md) for details!


# 💻 Supported Targets 💻

Any Linux target supported by [musl-cross-make](https://github.com/richfelker/musl-cross-make) is supported.  
This includes, but is not limited to:

- ARM
- MicroBlaze
- MIPS
- PowerPC
- RISC-V
- x86
- x86_64

For a complete list of targets, consult the latest [musl documentation](https://musl.libc.org/doc/1.1.24/manual.html).

⭐️ Once a target toolchain has been built, a list of all supported CPU *architectures* can be displayed with:  
`make TARGET=your-target-here archlist`


# 🧰 Build Requirements 🧰

This project uses [musl-cross-make](https://github.com/richfelker/musl-cross-make) to build a cross-compiler toolchain and compile all prerequisites for the output binaries.  
As a result, only a small number of common build packages are required:

- curl *or* wget
- GCC + recommended packages
  - gcc, g++, make, autoconf, autotools, libtool, flex, bison
- Archive utilities
  - tar, gzip, bzip2, xz-utils

Alternately, the provided [Dockerfile](Dockerfile) and [build.sh](build.sh) script can be used for a reproducible build environment.

⭐️ Builds have been successfully completed on Ubuntu, Debian, macOS, and RaspberryPi OS.


# 🛠 Usage 🛠

```
USAGE: make TARGET=musl-toolchain [ARCH=cpu-arch] [program ...]
The TARGET value must be a musl-cross-make toolchain target.
The optional ARCH value must be a valid GCC -march CPU type.

Examples targets:
  TARGET=arm-linux-musleabi
  TARGET=arm-linux-musleabihf ARCH=armv7-a+fp
  TARGET=mips-linux-musl
  TARGET=mipsel-linux-muslsf
  TARGET=x86_64-linux-musl
  ...
  For additional targets, consult the musl manual:
    https://musl.libc.org/doc/1.1.24/manual.html

Goals:
  all
    Builds all available programs:
    ...
  default
    Builds default subset of programs:
    ...
  musl
    Builds the cross-compiler toolchain for TARGET.
  archlist
    Shows available CPU architectures for TARGET.
  env
    Shows shell commands to activate TARGET toolchain.
  usage
    Shows this message.
  mostlyclean
    Removes source code and temporary objects.
  clean
    Removes cross-compiler toolchain, sources, and objects.
```

## Basic Examples

Building the **default** subset of binaries for MIPS:  
`make TARGET=mips-linux-musl default`

Building **all** binaries for the ARMv7 architecture (with hardware floating point support):  
`make TARGET=arm-linux-musleabihf ARCH=armv7-a+fp all`

Building **only the cross-compiler** toolchain for a generic ARM target:  
`make TARGET=arm-linux-musleabi musl`

**Listing** all ARCH values supported by the x86 target:  
`make TARGET=x86-linux-musl archlist`

Output shell **environment variables** for manual cross-compiling:  
`make TARGET=mipsel-linux-muslsf env`

## Advanced Examples

Optimizing binaries for speed instead of size:  
`make TARGET=... CFLAGS="-O2" all`

Build binaries using OpenSSL instead of LibreSSL:  
`make TARGET=... OPENSSL=openssl all`

Tweaking a package's configuration using `*_CONFIG` flags:  
`make TARGET=... curl CURL_CONFIG="--extra-curl-configs"`


# 📖 FAQ 📖

### What inspired this project?
I occasionally tinker with embedded Linux environments that don't have access to package managers or compilers.  
Being able to statically cross-compile my favorite tools makes it much easier to work on those systems.

### How long does this take to build?
Using `make -j` for parallel builds, the musl cross-compiler can be built in 15-30 minutes depending on the target.  
From there, building all of the programs usually takes 10-15 minutes.

For example build times, check this project's GitHub Actions workflows.

### What if I want *even smaller* binaries?
You can shrink the binaries by a further 40% by using a packer like [UPX](https://upx.github.io/).  
I've decided not to include UPX for a few reasons:
- Some anti-virus programs will detect UPX packed binaries as potentially malicious.
- I wanted the pre-compiled binaries on the releases page to be reproducible.
- Running packed binaries requires additional memory, something most embedded environments don't have.

### Why distribute pre-compiled binaries?
Because some people are lazy and I absolutely respect that. 😎

### Are the pre-compiled binaries [reproducible](https://reproducible-builds.org/)?
To the best of my ability, *yes*.  
Building the binaries using the [docker_build.sh](docker_build.sh) script *should* result in byte-for-byte identical results.  
Alternately, fork the repo and trigger the [GitHub Actions workflow](.github/workflows/release.yml) that builds and publishes the releases.

### When will __________ be added to the toolkit?
As soon as you submit a [pull request](CONTRIBUTING.md) to add it! 😉
