# Advent of code crusher

Crush your friends and foes using this automated tool
that fetchs the example, the problem and
automates trivial parts of the solving process.

Usage: `./aoc`

## Notes

You need to put your session cookie inside credentials.txt

## More options !

In general, the syntax is: `./aoc -y:year -d:day [more options]`
By specifying the year/day, you can work on past solutions (or past years), not just the latest one.

The options are:
- `--noedit` : to disable the opening the text editor
- `--speed` : to compile with speed options (by default, the executable is compiled in debug mode to see errors)

## Examples

- `./aoc`
- `./aoc -y:2023 -d:11 --speed`
- `./aoc --noedit`