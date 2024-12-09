<h1 align="center">🎄Advent of Code Helper</h1>

<p align="center">
  <i>Crush your friends and foes using this automated tool
that fetchs the example, the problem and
automates trivial parts of the solving process for the <a href="https://adventofcode.com/">Advent of Code</a></i>
</p>
<p align="center">
  <a href="https://github.com/vanyle/advent-of-nim/"><img src="https://img.shields.io/github/stars/vanyle/advent-of-nim?style=social" alt="GitHub Stars"></a>
</p>

<hr class="solid">

This tool is designed for the [👑Nim](https://nim-lang.org) programing language, which is in my opinion the best language for quickly solving AOC problems.

Run `./aoc` and let the command line guide you!

## 🏁 Getting started

You will need a working [Nim installation](https://github.com/nim-lang/choosenim).

Compile `aoc.nim` using `nim c -d:ssl -d:release aoc.nim` to generate an executable.

Run the generated executable `./aoc` or `aoc.exe` and let the program guide you. You can also use `./aoc.sh` or `./aoc.cmd` directly without compilation.

## ✨ Features

Automatically:

- Downloads the problem statement and case.
- Opens your text editor
- Runs your code and tests it
- Submits your solution
- Shows the performance of your solution
- Supports Linux, Windows and MacOS.

A `toolbox.nim` file is provided where you can put code that is often needed for multiple days.
Currently, the `toolbox` contains function to quickly handle string parsing with no copies.

## 📖 More usage information

In general, the syntax is: `./aoc -y:year -d:day [more options]`
By specifying the year/day, you can work on past solutions (or past years), not just the latest one.

The options are:

- `--noedit` : to disable the opening the text editor
- `--speed` : to compile with speed options (by default, the executable is compiled in debug mode to see errors)

**Examples**

- `./aoc`
- `./aoc -y:2023 -d:11 --speed`
- `./aoc --noedit`

## 🚧 TODO

- Generate HTML report with performance
- Generate a standalone result Nim or C file if requested for external repositories
