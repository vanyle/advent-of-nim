# Utils functions for aoc.
# Include a astar with some docs
# a sat solver
# and other goodies.

import strformat

proc run*(year: int, day: int, part1: proc(s: string): string, part2: proc(s: string): string) =
    # Test that the program works on the test cases and if so, submit it.
    # Also, have a timing system ?
    echo fmt"Running {year}/{day}"
    
    var everything = stdin.readAll()
    echo everything
    
    if part1 != nil:
        echo part1("hello part1 !")

    if part2 != nil:
        echo part1("hello part2 !")
