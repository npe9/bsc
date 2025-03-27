# Compiling BSC from source

Source code for the Bluespec toolchain can currently be built on Linux
and macOS. It may compile for other flavors of Unix.

The core of BSC is written in Haskell, with some libraries in C/C++.

---

## Overview

The following sections describe the requirements and commands for building
BSC using Cabal, the standard Haskell build system. Running the build commands 
will create an installation of BSC in your Cabal store, with executables 
symlinked to your Cabal bin directory.

We recommend adding your Cabal bin directory to your PATH:

    $ export PATH=$HOME/.cabal/bin:$PATH

---

## Install the Haskell compiler (GHC) and Cabal

You will need:
- The Glasgow Haskell Compiler (GHC) 9.4.8 or later
- Cabal 3.0 or later

The recommended way to install these is using [ghcup](https://www.haskell.org/ghcup/):

    $ curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
    $ ghcup install ghc 9.4.8
    $ ghcup set ghc 9.4.8
    $ ghcup install cabal 3.10.1.0

## Additional requirements

For building and using the Bluespec Tcl shell (`bluetcl`),
you will need the `tcl` library:

    $ apt-get install tcl-dev    # On Debian/Ubuntu
    $ brew install tcl-tk        # On macOS with Homebrew

The repository for [the Yices SMT Solver](https://github.com/SRI-CSL/yices2) is
cloned as a submodule of this repository. Building BSC will automatically build
and link against Yices.

Building Yices requires:
- autoconf
- gperf

On Debian/Ubuntu:

    $ apt-get install autoconf gperf

On macOS with Homebrew:

    $ brew install autoconf gperf

## Clone the repository

Clone this repository by running:

    $ git clone --recursive https://github.com/B-Lang-org/bsc

That will clone this repository and all of the submodules that it depends on.
If you have cloned the repository without the `--recursive` flag, you can setup
the submodules later with a separate command:

    $ git clone https://github.com/B-Lang-org/bsc
    $ git submodule update --init --recursive

## Build the BSC toolchain

At the root of the repository:

    $ cabal update
    $ cabal build all

This will build BSC and all its dependencies. The build products will be placed in your
Cabal store.

To install the executables to your Cabal bin directory:

    $ cabal install all

You can control GHC's parallel compilation with the -j flag:

    $ cabal build all -j4

For development builds, you can use different optimization levels:

    $ cabal build --ghc-options="-O0"        # No optimization
    $ cabal build --ghc-options="-O2"        # Full optimization (default)
    $ cabal build --ghc-options="-prof"      # Build with profiling

## Running tests

The test suite can be run with:

    $ cabal test all

For more details about testing, see the [testsuite README](testsuite/README.md).

## Building documentation 

To build the documentation:

    $ cabal haddock all

The documentation will be generated in your Cabal store's documentation directory.

For building the PDF documentation, you'll need LaTeX installed:

On Debian/Ubuntu:

    $ apt-get install texlive-latex-base texlive-latex-recommended \
                      texlive-latex-extra texlive-font-utils texlive-fonts-extra

Then build the documentation:

    $ cabal build --enable-documentation all

## Using the Bluespec compiler

The installation contains a `