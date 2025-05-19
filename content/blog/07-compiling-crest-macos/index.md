---
layout: article
slug: "compiling-crest-macos-m1"
author: "Tobia Cavalli"
title: "Compiling CREST on MacOS with M-series Chips"
date: "2025-03-14"
description: "A step-by-step guide to properly compiling CREST on Apple Silicon (M1/M2) Macs"
tags: [
    "computational chemistry",
    "software installation",
    "CREST",
    "MacOS",
]
categories: [
    "computational chemistry",
    "software",
    "MacOS"
]
---

> [!NOTE] Summary
> This post provides a step-by-step guide for correctly compiling CREST on Apple Silicon Macs (M1, M2, etc.). The standard installation method often fails on these systems due to issues with the accelerate libraries. I'll walk you through an alternative approach that properly compiles CREST against openblas and lapack instead.

{{% toc %}}

## What is CREST?

[CREST (Conformer-Rotamer Ensemble Sampling Tool)](https://crest-lab.github.io/crest-docs/) is a really useful program for exploring different molecular conformations. In simple terms, it helps you find all the different shapes a molecule might twist itself into. This is super handy when you're trying to understand how molecules behave in the real world.

It was developed by the Grimme group at the University of Bonn and while it's relatively new in the computational chemistry scene, it is particularly useful if you're working with flexible molecules that can adopt multiple configurations.[^1] [^2]

What I especially like about CREST is how it helps with density functional theory (DFT) work. Instead of wasting time running expensive DFT calculations on every possible molecular shape, CREST helps you identify which conformations are actually worth your computational time. This saves hours of calculation time and helps you focus on the structures that actually matter.

## What goes wrong on Apple Silicon

While the official CREST documentation provides clear installation instructions, I encountered significant problems when attempting to compile it on my Mac with an M-series chip. The main problem is all about how cmake tries to use the accelerate libraries that come with Apple's new Arm-based processors (M1, M2, etc.).

If you just follow the standard steps, you'll end up with a compilation that tries to use these accelerate libraries, which either fails completely or gives you binaries that don't work properly. To create a properly functioning CREST installation, we need to explicitly compile against alternative libraries---specifically openblas and lapack.

## How to compile CREST properly

Let's start by getting the source code. Download the latest release of CREST [following the instructions on the official documentation](https://crest-lab.github.io/crest-docs/page/installation/install_basic.html#option-3-compiling-from-source). Be sure to clone the repository and update the necessary submodules. This last step can be done by running `git submodule update --init` after `git clone`, as explained [here](https://github.com/crest-lab/crest/issues/333) (thanks Jingdan Chen for pointing this out!).

Now we need to get the right libraries---`cmake`, `gcc`, `openblas` and `lapack`. Doing this with Homebrew is straightforward:

```sh
brew install gcc cmake openblas lapack
```

Next, we need to tell cmake where to find these libraries. This is where the official docs and reality diverge. CREST's documentation suggests doing this with:

```sh
export FC=gfortran CC=gcc
```

But doing this on a Mac with an Arm chip means you'll compile using MacOS's default compilers, and that will end badly. Instead, you need to point to the compilers you just installed via Homebrew:

```sh
export FC=gfortran-14 CC=gcc-14
```

> [!IMPORTANT]
> Check which specific version of gcc Homebrew installed on your system. In my case, this was version 14, but you might have a different one. You can check with `brew info gcc`.

Now comes the truly crucial part that fixes the whole problem. When using CMake, you need to explicitly tell it where to find the `lapack` and `openblas` libraries you installed with Homebrew. If you skip this, CMake will use the default libraries that come with MacOS, and you'll be right back where we started. Look for the path where Homebrew installed the libraries, and run:

```sh
cmake -DCMAKE_PREFIX_PATH="/opt/homebrew/opt/lapack;/opt/homebrew/opt/openblas" -B _build
```

With everything configured correctly, you can finish the compilation:

```sh
make -C _build
```

And that's it! This builds CREST in the `_build` directory with all the right libraries.

## When things don't work

If you run into problems (and let's be honest, compiling software can be finicky), here are a few things I'd check:

- First, double-check which version of gcc you actually have. Typing `gfortran-14` when you have version 13 installed will obviously cause confusion.
- Also, make sure those paths to lapack and openblas are correct for your system. They might be slightly different depending on your Homebrew configuration.
- Finally, if you get mysterious errors about missing dependencies, just make sure you've installed everything. Sometimes it's the simple things we overlook!

## The takeaway

The frustrating thing about software compilation issues is that they can be both incredibly simple and maddeningly obscure at the same time. In this case, the entire problem boils down to getting CREST to use the right math libraries. I spent a couple of hours banging my head against this wall before figuring out the solution. The error messages weren't particularly helpful, and searching online didn't turn up much since this is a fairly specific issue with M-series Macs.

The M-series chips are powerful for computational chemistry, but their relative newness means we occasionally need to find workarounds like this one. If you're diving into computational chemistry on your shiny M1 or M2 Mac, don't let these small hurdles discourage you. Once you get past the installation quirks, CREST runs beautifully on Apple Silicon and can save you tons of time in your conformational analyses.

And if this guide helped you avoid the same frustration I went through, then writing it was absolutely worth it. Happy calculating!

[^1]: Pracht, P.; Bohle, F.; Grimme, S. Automated Exploration of the Low-Energy Chemical Space with Fast Quantum Chemical Methods. _Phys. Chem. Chem. Phys._ **2020**, _22_ (14), 7169–7192. https://doi.org/10.1039/C9CP06869D.
[^2]: Pracht, P.; Grimme, S.; Bannwarth, C.; Bohle, F.; Ehlert, S.; Feldmann, G.; Gorges, J.; Müller, M.; Neudecker, T.; Plett, C.; Spicher, S.; Steinbach, P.; Wesołowski, P. A.; Zeller, F. CREST—A Program for the Exploration of Low-Energy Molecular Chemical Space. _J. Chem. Phys._ **2024**, _160_ (11), 114110. https://doi.org/10.1063/5.0197592.
