# Building BSC with Cabal

This directory contains the Cabal build configuration for BSC (Bluespec System Compiler).

## Prerequisites

- GHC 9.2.8
- Cabal 3.8 or later
- Make

## Building

To build BSC using Cabal:

```bash
cabal build
```

To run the tests:

```bash
cabal test
```

To install:

```bash
cabal install
```

## Configuration

The build is configured to use the STP stub by default. To use the actual STP solver,
remove the `+stp-stub` flag from `cabal.project`.

## Notes

- The build process generates several files in the `dist-newstyle` directory.
- Generated files and build artifacts are ignored by Git.
- The `Makefile.cabal` provides additional build targets and configuration options. 