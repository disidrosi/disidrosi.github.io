---
slug: "installing-orca-macos"
aliases: ["/blog/installing-orca-macos/"]
author: "Tobia Cavalli"
title: "Installing ORCA on macOS Arm64"
date: "2024-09-22"
lastmod: "2026-04-02"
summary: "Installing and configuring ORCA 6.0.0 on Apple Silicon Macs,
    including Open MPI compilation for parallel calculations."
description: "Step-by-step installation of ORCA 6.0.0 on macOS Arm64
    (Apple Silicon), with Open MPI setup for parallel execution and a
    test calculation to verify the setup."
tags: ["computational-chemistry","macos"]
toc: true
---

![Orca logo](orca_logo.svg)

[ORCA](https://www.faccts.de/orca/) is a quantum chemistry program for
molecular electronic structure calculations, developed and maintained
by Frank Neese's research group at the Max-Planck-Institut für
Kohlenforschung in Mülheim an der Ruhr, Germany. It supports density
functional theory (DFT), coupled-cluster theory, semi-empirical
methods, and more.

Version `6.0.0`, released in August 2024, is a major redesign (see
the [foreword to its
release](https://www.faccts.de/docs/orca/6.0/manual/contents/foreword.html)).
This guide covers installing it on macOS with Apple Silicon (M1, M2,
etc.), including Open MPI setup for parallel calculations.

## Installation

### Getting the files

To get started, download the ORCA package from the [official ORCA download
page](https://orcaforum.kofo.mpg.de/app.php/dlext/). Note that you'll need a
registered account to access the download---registration is free if you don't
have an account yet.

For macOS on Arm64, the download page lists two options (both
containing pre-compiled binaries linked to Open MPI `4.1.1`):

1. **ORCA 6.0.0, MacOS X, Arm64, Installer Version:** Extracts,
   installs, and adds ORCA to your `PATH` automatically.
2. **ORCA 6.0.0, MacOS X, Arm64, .tar.bz2 Archive:** Manual
   extraction and `PATH` setup, but more control over the installation
   location.

This guide uses the **Installer Version**, which downloads as
`orca_6_0_0_macosx_arm64_openmpi411.run`.

### Setting file permissions

Before running the installer, make it executable:

```shell {lineNos = false}
cd ~/Downloads
chmod +x orca_6_0_0_macosx_arm64_openmpi411.run
```

### Running the installer

Run the installer from the same directory:

```shell {lineNos = false}
$ ./orca_6_0_0_macosx_arm64_openmpi411.run

Creating directory orca_6_0_0
Verifying archive integrity...  100%   MD5 checksums are OK. All good.
Uncompressing ORCA 6.0.0 Installer ...  100%
```

By default, this operation installs the ORCA binaries in the directory
`/Users/<username>/Library/Orca/`, where `<username>` is your system's user.

### Setting the `PATH`

The installer should automatically add ORCA to your system's `PATH`.
Verify by running:

```shell {lineNos = false}
$ orca

This program requires the name of a parameterfile as argument
For example ORCA TEST.INP
```

If you see this output, ORCA is installed. You can also confirm by
checking your `.zshrc` (macOS ships with zsh by default) for a line
like:

```zsh {lineNos = false}
# ORCA 6.0.0 section
export PATH=/Users/<username>/Library/orca_6_0_0:$PATH
```

If this line is missing, add it manually, pointing to the correct
installation directory. Save the file and restart your terminal.

### Parallelization with Open MPI

To run calculations in parallel, ORCA needs **Open MPI**.

> [!warning]
> The ORCA `6.0.0` binaries are linked against Open MPI `4.1.1`. This
> guide installs `4.1.6` instead, because `4.1.1` failed to compile on
> Apple Silicon in my testing. Version `4.1.6` works without issues.

Download Open MPI `4.1.6` from the [official Open MPI
page](https://www.open-mpi.org/software/ompi/v4.1/). The file is
`openmpi-4.1.6.tar.gz`.

Before compiling, install the Fortran compiler via
[Homebrew](https://brew.sh/):

```shell {lineNos = false}
brew install gcc
```

Unpack and prepare Open MPI for compilation. This example installs it
in a dedicated folder in the home directory:

```shell {lineNos = false}
# Create a directory for Open MPI
$ mkdir $HOME/openmpi
$ cd $HOME/openmpi

# Move the downloaded file and extract it
$ cp ~/Downloads/openmpi-4.1.6.tar.gz .
$ tar -xzvf openmpi-4.1.6.tar.gz
$ cd openmpi-4.1.6
```

Compile Open MPI with Fortran support and the flags needed for ORCA:

```shell {lineNos = false}
./configure --prefix=$HOME/openmpi --without-verbs --enable-mpi-fortran --disable-builtin-atomics
make all
make install
```

> [!note] Update 2025-07-30
> A reader has reported that compiling `openmpi` on newer
> versions of Xcode-devtools (Ventura 13.5 to Sonoma 14.x) requires the
> additional flag `LDFLAGS="-ld_classic"`. In this case, the full configuration
> command should be:
> 
> ```shell {lineNos = false}
> ./configure --prefix=$HOME/openmpi --without-verbs --enable-mpi-fortran --disable-builtin-atomicsC LDFLAGS="-ld_classic"
> ```
> 
> See this [GitHub issue](https://github.com/open-mpi/ompi/issues/11935) for
> details.

Compilation takes time. To speed it up, use multiple cores with the
`-jN` flag:

```shell {lineNos = false}
make -j4 all
make -j4 install
```

After compilation, create a symbolic link to make Open MPI accessible
system-wide:

```shell {lineNos = false}
sudo ln -s $HOME/openmpi/lib/libmpi.40.dylib /usr/local/lib/libmpi.40.dylib
```

Update the `PATH` and `LD_LIBRARY_PATH` in your `.zshrc` (or
`.bash_profile` if using bash):

```zsh {lineNos = false}
export PATH=$HOME/openmpi/bin:$PATH
export LD_LIBRARY_PATH=$HOME/openmpi/lib:$LD_LIBRARY_PATH
```

Run `source ~/.zshrc` (or restart your terminal), then verify:

```shell {lineNos = false}
$ mpirun --version

mpirun (Open MPI) 4.1.6

Report bugs to http://www.open-mpi.org/community/help/
```

If you see this output, Open MPI is ready.

## Testing

Verify the setup by running a simple calculation. Create a folder for
the test files:

```shell {lineNos = false}
# Navigate to the desktop
$ cd ~/Desktop

# Create a new folder for the test
$ mkdir orca_test
$ cd orca_test

# Create an input file for the calculation
$ touch water.inp
```

Add a basic Hartree-Fock (HF) calculation on a water molecule using the
Def2-SVP basis set (from the [official ORCA
tutorial](https://www.faccts.de/docs/orca/6.0/tutorials/first_steps/first_calc.html)):

```orca
!HF DEF2-SVP

* xyz 0 1
O   0.0000   0.0000   0.0626
H  -0.7920   0.0000  -0.4973
H   0.7920   0.0000  -0.4973
*
```

Save the file and run ORCA in serial mode:

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

If the output ends with `ORCA TERMINATED NORMALLY`, the serial setup
works. Next, test parallel execution by adding a `%PAL` block that
specifies the number of processes. Update `water.inp`:

```orca
!HF DEF2-SVP

%PAL NPROCS 4 END

* xyz 0 1
O   0.0000   0.0000   0.0626
H  -0.7920   0.0000  -0.4973
H   0.7920   0.0000  -0.4973
*
```

For parallel runs, use the full path to the ORCA executable (replace
`<username>` with your macOS username):

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

If the output confirms 4 parallel MPI processes and terminates
normally, both ORCA and Open MPI are working.

> [!note]
> The parallel run took 17.7 seconds versus 0.3 seconds in
serial. MPI startup and inter-process communication add overhead that
outweighs the benefit for small calculations. The speedup becomes
visible on larger systems.
