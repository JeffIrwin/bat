
# bat
BAT:  a cross-platform Bourne-again testing framework for a novel world rising from the ashes of coronavirus 🦇

## Usage
For complete projects that use the BAT framework, see any of these:
- [colormapper](https://github.com/JeffIrwin/colormapper) (C++)
- [fortfuck](https://github.com/JeffIrwin/fortfuck) (Brainfuck and Fortran)
- [life](https://github.com/JeffIrwin/life) (Fortran)
- [mandelbrotZoom](https://github.com/JeffIrwin/mandelbrotZoom) (Fortran)
- [maph](https://github.com/JeffIrwin/maph) (C++)
- [music-of-the-sars](https://github.com/JeffIrwin/music-of-the-sars) (Python)
- [pnmio](https://github.com/JeffIrwin/pnmio) (Fortran)
- [rubik](https://github.com/JeffIrwin/rubik) (Fortran)

### Building
Before you test, you have to build, right?  BAT automatically builds for you using CMake before testing, but you can also build independently from testing.  From the parent repo, run:

    ./path/to/bat/build.sh

In accordance with CMake rules, there needs to be a `CMakeLists.txt` file in the root of the parent repo.

### Testing
BAT is designed to test programs that take an *input file*, do some transformative magic in an opaque box, and then create one or more *output files*.  BAT needs to know where these inputs and outputs are, and what your program is named.  To figure out if the tests passed, BAT also needs to know what you expect the output to be.  Define these variables in the Bash environment, for example:

    inputs=./inputs/*.json
    frames=( 2 10 99 )
    exebase=life
    outdir=./inputs/frames
    expectedoutdir=./inputs/expected-output
    outputext=pbm
    use_stdin="false"
    
    source ./path/to/bat/test.sh

This will get BAT running a program named `life` (or `life.exe` on Windows) for each globbed input file.  BAT expects that the output files are named after the globbed base of the input file, but with a different file extension `outputext` and with delimited frame numbers.  For example, with an input named `./inputs/acorn.json`, BAT expects to find the files:

    inputs/frames/acorn_2.pbm
    inputs/frames/acorn_10.pbm
    inputs/frames/acorn_99.pbm

Your expected output files should be in a parallel directory:

    inputs/expected-output/acorn_2.pbm
    inputs/expected-output/acorn_10.pbm
    inputs/expected-output/acorn_99.pbm

You can compare as many frames as your program produces by adding numbers to the `frames` array.

The variable `use_stdin` (`"true"` or `"false"`) tells BAT whether your program runs with input from stdin like `main.exe < file.txt` or with a command line argument like `main.exe file.txt`.

### Cleaning
Sometimes you can't be sure unless you remove the old build first.  From the parent repo, run:

    ./path/to/bat/clean.sh

Want to test quickly without cleaning?  Run `test.sh --dirty` or `test.sh -d`.

Cleaning and building are trivial one-liners, but the example projects listed above, including [life](https://github.com/JeffIrwin/life), still provide wrapper scripts for these actions, as well as testing.

## FAQ

Q.  Why is this in Bash if it's supposed to be cross-platform?

A.  If you're using git, then you have Bash!  Even on Windows.  BAT is actively used on Linux, macOS, and Windows as part of [github workflows](https://github.com/JeffIrwin/life/blob/master/.github/workflows/main.yml).


Q.  What languages can BAT be used to test?

A.  The examples cover compiled languages like C++ and Fortran, and interpretted languages like Python.  However, it can be adapted or used as-is for just about anything that can produce a program with a [CLI](https://en.wikipedia.org/wiki/Command-line_interface).  The [fortfuck](https://github.com/JeffIrwin/fortfuck) project even includes several stages of testing, which run the fortfuck compiler, gcc, and compiled brainfuck executables.


Q.  Shouldn't I just use a real testing framework?

A.  idk, probably 
