---
slug: "compiling-crest-macos-m1"
aliases: ["/blog/compiling-crest-macos-m1/"]
title: "Compiling CREST on macOS with M-series Chips"
date: "2025-03-14"
lastmod: "2026-04-02"
summary: "The standard CREST build fails on Apple Silicon because cmake
    links against the Accelerate framework. Compiling against openblas and
    lapack instead fixes it."
description: "The standard CREST compilation fails on Apple Silicon Macs
    because cmake links against the Accelerate framework. This guide
    compiles CREST against openblas and lapack instead."
tags: ["computational-chemistry","macos"]
---

![CREST logo](crest_logo.png)

[CREST (Conformer-Rotamer Ensemble Sampling
Tool)](https://crest-lab.github.io/crest-docs/) is a program for exploring
molecular conformations. Developed by the Grimme group at the University of
Bonn, it automates the search for low-energy conformers and rotamers, which is
particularly useful for flexible molecules that can adopt many
configurations.[^1] [^2]

The official CREST documentation provides clear installation instructions, but
following them on a Mac with an M-series chip leads to problems. By default,
`cmake` links against Apple's Accelerate framework. On Arm-based Macs (M1, M2,
etc.), this either fails or produces binaries that segfault at runtime. The
solution is to compile against `openblas` and `lapack` instead of Accelerate.

## Building against openblas and lapack

Let's start by getting the source code. Download the latest release of CREST
[following the instructions on the official
documentation](https://crest-lab.github.io/crest-docs/page/installation/install_basic.html#option-3-compiling-from-source).
Be sure to clone the repository and update the necessary submodules. This can be
done by running `git submodule update --init` after `git clone`, as explained
[here](https://github.com/crest-lab/crest/issues/333) (credit to Jingdan Chen
for pointing this out).

Now we need to get the right libraries: `cmake`, `gcc`, `openblas` and `lapack`.
Doing this with Homebrew is straightforward:

```sh
brew install gcc cmake openblas lapack
```

Next, we need to tell `cmake` where to find these libraries. This is where the
official docs don't work when applied on a Mac. CREST's documentation suggests
doing this with:

```sh
export FC=gfortran CC=gcc
```

On a Mac with an Arm chip, this resolves to macOS's default compilers,
which will link against Accelerate. Point to the Homebrew-installed
compilers instead:

```sh
export FC=gfortran-14 CC=gcc-14
```

> [!warning]
> Check which specific version of `gcc` Homebrew installed on your system. In my
case, this was version 14, but you might have a different one. You can check
with `brew info gcc`.

Now tell `cmake` where to find the `lapack` and `openblas` libraries you
installed with Homebrew. Without this, `cmake` falls back to the macOS system
libraries. Look for the path where Homebrew installed them, and run:

```sh
cmake -DCMAKE_PREFIX_PATH="/opt/homebrew/opt/lapack;/opt/homebrew/opt/openblas" -B _build
```

With everything configured correctly, you can finish the compilation:

```sh
make -C _build
```

This builds CREST in the `_build` directory, linked against `openblas` and
`lapack`.

## Troubleshooting

If the build fails, check these first:

- Verify which version of `gcc` you have installed. Typing `gfortran-14` when
  you have version 13 will produce confusing errors. Run `brew info gcc` to
  confirm.
- Confirm the paths to `lapack` and `openblas` match your Homebrew
  configuration. They may differ depending on how Homebrew is set up on your
  system.
- If you see errors about missing dependencies, make sure all submodules are
  initialized (`git submodule update --init`).

The entire problem comes down to which math libraries `cmake` links against. The
error messages do not make this obvious, and I spent a couple of hours on it
before finding the fix. Hopefully this saves you the same trouble.

[^1]: Pracht, P.; Bohle, F.; Grimme, S. Automated Exploration of the Low-Energy
    Chemical Space with Fast Quantum Chemical Methods. _Phys. Chem. Chem.
    Phys._ **2020**, _22_ (14), 7169–7192.
    <https://doi.org/10.1039/C9CP06869D>.
[^2]: Pracht, P.; Grimme, S.; Bannwarth, C.; Bohle, F.; Ehlert, S.; Feldmann,
    G.; Gorges, J.; Müller, M.; Neudecker, T.; Plett, C.; Spicher, S.;
    Steinbach, P.; Wesołowski, P. A.; Zeller, F. CREST—A Program for the
    Exploration of Low-Energy Molecular Chemical Space. _J. Chem. Phys._
    **2024**, _160_ (11), 114110. <https://doi.org/10.1063/5.0197592>.
