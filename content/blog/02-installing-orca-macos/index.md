---
layout: article
slug: "installing-orca-macos"
author: "Tobia Cavalli"
title: "Installing ORCA on Mac OS Arm64"
date: "2024-09-22"
description: "Guide to installing ORCA on Mac OS Arm64"
tags: [
    "software",
    "orca",
    "computational chemistry",
    "Mac OS"
]
categories: [
    "software",
    "orca",
    "computational chemistry",
    "Mac OS"
]
---

## Outline

- [What is ORCA?](#what-is-orca)
- [Installation](#installation)
  - [Getting the files](#getting-the-files)
  - [Setting file permissions](#setting-file-permissions)
  - [Running the installer](#running-the-installer)
  - [Setting the `PATH`](#setting-the-path)
  - [Parallelization with Open MPI](#parallelization-with-open-mpi)
- [Testing](#testing)

> [!Note] Summary
> This post is a step-by-step guide to installing and configuring ORCA, a powerful quantum chemistry software, on macOS with Arm64 architecture. It includes steps for downloading packages, setting up Open MPI for parallel computations, and testing the installation with sample calculations.

## What is ORCA?

[ORCA](https://www.faccts.de/orca/) is a powerful and versatile quantum chemistry program designed for molecular electronic structure calculations, developed and maintained by Frank Neese's research group at the Max-Planck-Institut für Kohlenforschung in Mülheim an der Ruhr, Germany.

Think of ORCA as the Swiss Army knife of computational chemistry---compact yet packed with a range of capabilities to tackle a wide variety of scientific problems. Straight out of the box, ORCA offers numerous computational methods such as Density Functional Theory (DFT), coupled-cluster theory (CCT), and semi-empirical approaches.

In August 2024, ORCA released its latest version, `6.0.0`, which is a major redesign of the software (see the [foreword to its release](https://www.faccts.de/docs/orca/6.0/manual/contents/foreword.html)). Having used ORCA in the past for my research, I was curious to try out this new version and see what's new.

If you're using a Mac equipped with an Arm64 architecture (such as Apple's M1 or M2 chips), this post will guide you through the process of downloading, installing, and configuring ORCA `6.0.0` on your system. Let's dive in!

## Installation

### Getting the files

To get started, download the ORCA package from the [official ORCA download page](https://orcaforum.kofo.mpg.de/app.php/dlext/). Note that you'll need a registered account to access the download---registration is free if you don't have an account yet.

For this installation, I'll be using version `6.0.0` for macOS running on Arm64 chips. On the website, you'll find two options for this version, both containing pre-compiled binaries linked to Open MPI `4.1.1`:

1. **ORCA 6.0.0, MacOS X, Arm64, Installer Version:** This is the more convenient option, as it includes pre-compiled binaries along with a utility that automatically extracts and installs ORCA, and adds the binaries to your system's path.
2. **ORCA 6.0.0, MacOS X, Arm64, .tar.bz2 Archive:** This is a compressed archive of the pre-compiled binaries. This option gives you more control over where you install the software, but you'll need to manually add ORCA to your system's path.

For simplicity, I'll be using the **Installer Version**, which downloads a file named `orca_6_0_0_macosx_arm64_openmpi411.run`.

### Setting file permissions

Before we can run the installer, we need to make the file executable. To do this, open your terminal and navigate to the directory where the file was saved. By default, this will likely be in the `~/Downloads` directory (unless you saved it elsewhere). Once you're in the correct directory, change the file permissions to make it executable using the `chmod` command with the `+x` option:

```shell {lineNos = false}
# Navigate to the directory where the file is stored
cd ~/Downloads

# Add execute permissions to the installer
chmod +x orca_6_0_0_macosx_arm64_openmpi411.run
```

After running these commands, you won't see any output, but the file permissions will be updated. To confirm that the file is now executable, you can check its status using the `ls` command with the `-l` option:

```shell {lineNos = false}
$ ls -l orca_6_0_0_macosx_arm64_openmpi411.run

-rwxr-xr-x@ 1 <username>  staff  579539683 Sep 21 14:29 orca_6_0_0_macosx_arm64_openmpi411.run
```

In the output, the `x` characters in the `-rwxr-xr-x@` indicate that the file is now executable. This means you're ready to proceed by running the installer directly.

### Running the installer

Now that the file is executable, we can proceed with the installation by simply running the installer from the same directory:

```shell {lineNos = false}
$ ./orca_6_0_0_macosx_arm64_openmpi411.run

Creating directory orca_6_0_0
Verifying archive integrity...  100%   MD5 checksums are OK. All good.
Uncompressing ORCA 6.0.0 Installer ...  100%
```

By default, this operation installs the ORCA binaries in the directory `/Users/<username>/Library/Orca/`, where `<username>` is your system's user.

### Setting the `PATH`

The installer should automatically add ORCA to your system's `PATH`---a variable that tells your terminal where to find executables, allowing you to run `orca` directly from the command line. To verify that ORCA has been properly added to your `PATH`, simply type the following command in your terminal:

```shell {lineNos = false}
$ orca

This program requires the name of a parameterfile as argument
For example ORCA TEST.INP
```

If you see this output, ORCA has been successfully installed and recognized by your terminal.

You can also confirm this by checking your shell's configuration file. Since macOS ships with **zsh** by default, the configuration file is called `.zshrc` and is located in your home directory. Open this file and scroll to the bottom to look for a line similar to:

```zsh {lineNos = false}
# ORCA 6.0.0 section
export PATH=/Users/<username>/Library/orca_6_0_0:$PATH
```

If this line is missing, you will need to manually add it, ensuring that the path points to the correct installation directory.

Once you've added or confirmed the correct `PATH`, save the configuration file and restart your terminal for the changes to take effect.

### Parallelization with Open MPI

While ORCA is now installed and ready to use, to take full advantage of its capabilities---such as running calculations in parallel---we need to install **Open MPI**. The ORCA binaries are linked against Open MPI `4.1.1`, but I'll be using a newer version, `4.1.6`, as I encountered issues compiling the earlier version.

First, download the latest Open MPI version (`4.1.6`) from the [official Open MPI page](https://www.open-mpi.org/software/ompi/v4.1/). The downloaded file will be named `openmpi-4.1.6.tar.gz`.

Before compiling Open MPI, we need to ensure we have the Fortran compiler installed. This can be easily done using [Homebrew](https://brew.sh/):

```shell {lineNos = false}
brew install gcc
```

Once the Fortran compiler is ready, unpack the Open MPI binaries and prepare them for compilation. I'll install Open MPI in a dedicated folder in the home directory:

```shell {lineNos = false}
# Create a directory for Open MPI
$ mkdir $HOME/openmpi
$ cd $HOME/openmpi

# Move the downloaded file and extract it
$ cp ~/Downloads/openmpi-4.1.6.tar.gz .
$ tar -xzvf openmpi-4.1.6.tar.gz
$ cd openmpi-4.1.6
```

Now, we're ready to compile Open MPI. The following configuration options ensure it works smoothly with ORCA and that Fortran is enabled:

```shell {lineNos = false}
$ ./configure --prefix=$HOME/openmpi --without-verbs --enable-mpi-fortran --disable-builtin-atomics
$ make all
$ make install
```

These steps can take some time. If you want to speed things up, you can compile using multiple cores by adding the `-jN` option to the `make` commands, where `N` is the number of cores you want to use. For example:

```shell {lineNos = false}
$ make -j4 all
$ make -j4 install
```

After the compilation is complete, the folder `openmpi` will contain the following directories: `bin`, `etc`, `include`, `lib`, and `share`, holding the compiled binaries and libraries.

To make Open MPI accessible system-wide, we need to create a symbolic link to the `libmpi.40.dylib` library:

```shell {lineNos = false}
$ sudo ln -s $HOME/openmpi/lib/libmpi.40.dylib /usr/local/lib/libmpi.40.dylib
```

To ensure the system recognizes Open MPI, we need to update the `PATH` and `LD_LIBRARY_PATH` environment variables. Add the following lines to your `.zshrc` (or `.bash_profile` if using bash):

```zsh {lineNos = false}
export PATH=$HOME/openmpi/bin:$PATH
export LD_LIBRARY_PATH=$HOME/openmpi/lib:$LD_LIBRARY_PATH
```

Once you've updated the file, run `source ~/.zshrc` (or restart your terminal) for the changes to take effect.

Finally, verify that Open MPI is correctly installed by running:

```shell {lineNos = false}
$ mpirun --version

mpirun (Open MPI) 4.1.6

Report bugs to http://www.open-mpi.org/community/help/
```

If you see this output, Open MPI is installed and ready to work with ORCA for parallel calculations!

## Testing

Now that ORCA and Open MPI are set up, let's verify everything is working correctly by running a simple calculation. We'll start by creating a folder on the desktop to hold the files generated during the test.

```shell {lineNos = false}
# Navigate to the desktop
$ cd ~/Desktop

# Create a new folder for the test
$ mkdir orca_test
$ cd orca_test

# Create an input file for the calculation
$ touch water.inp
```

In the `water.inp` file, we'll add instructions to perform a basic Hartree-Fock (HF) calculation using the Def2-SVP basis set on a water molecule. These instructions are based on the [official ORCA tutorial](https://www.faccts.de/docs/orca/6.0/tutorials/first_steps/first_calc.html):

```orca
!HF DEF2-SVP

* xyz 0 1
O   0.0000   0.0000   0.0626
H  -0.7920   0.0000  -0.4973
H   0.7920   0.0000  -0.4973
*
```

Save the file. Now, in the terminal (from within the `orca_test` folder), run the following command to execute ORCA in serial mode, using a single core:

```shell {lineNos = false}
$ orca water.inp

                                 *****************
                                 * O   R   C   A *
                                 *****************

--- truncated output ---

Timings for individual modules:

Sum of individual times          ...        0.245 sec (=   0.004 min)
Startup calculation              ...        0.081 sec (=   0.001 min)  33.0 %
SCF iterations                   ...        0.114 sec (=   0.002 min)  46.5 %
Property calculations            ...        0.050 sec (=   0.001 min)  20.6 %
                             ****ORCA TERMINATED NORMALLY****
TOTAL RUN TIME: 0 days 0 hours 0 minutes 0 seconds 302 msec
```

If you see the above message, the serial calculation has completed successfully!

Next, let's test ORCA's parallel capabilities. Modify your input file to enable parallel processing by adding the `%PAL` block, which specifies the number of processes (`NPROCS`) to use. Update `water.inp` to the following:

```orca
!HF DEF2-SVP

%PAL NPROCS 4 END

* xyz 0 1
O   0.0000   0.0000   0.0626
H  -0.7920   0.0000  -0.4973
H   0.7920   0.0000  -0.4973
*
```

To run the parallel version, we need to specify the complete path to the ORCA executable. In this case, use the following command (replace `<username>` with your actual macOS username):

```shell {lineNos = false}
$ /Users/<username>/Library/orca_6_0_0/orca water.inp

           ************************************************************
           *        Program running with 4 parallel MPI-processes     *
           *              working on a common directory               *
           ************************************************************

--- truncated output ---

Timings for individual modules:

Sum of individual times          ...       17.403 sec (=   0.290 min)
Startup calculation              ...       16.408 sec (=   0.273 min)  94.3 %
SCF iterations                   ...        0.721 sec (=   0.012 min)   4.1 %
Property calculations            ...        0.275 sec (=   0.005 min)   1.6 %
                             ****ORCA TERMINATED NORMALLY****
TOTAL RUN TIME: 0 days 0 hours 0 minutes 17 seconds 708 msec
```

If everything ran successfully, ORCA and Open MPI are correctly installed and functioning. You can now take full advantage of ORCA's capabilities for parallel quantum chemical calculations!

**Note:** The parallel calculation took 17 seconds and 708 milliseconds, while the identical calculation in serial took only 302 milliseconds. Setting up the parallel environment and managing communication between processes adds time. This overhead can offset the benefits of parallel execution, which becomes evident in calculations of simple molecules.
