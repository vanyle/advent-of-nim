# Utils functions for aoc.
# Include a astar with some docs
# a sat solver
# and other goodies.

# Good functional packages
import strutils, sequtils, strscans, tables, sets
export strutils, sequtils, strscans, tables, sets

proc run*(year: int, day: int, part1: proc(s: string): string, part2: proc(
        s: string): string) =
    var everything = stdin.readAll()

    if part1 != nil:
        echo "Running part 1: "
        var p1_result = part1(everything)
        echo "Part 1 result: ", p1_result

    if part2 != nil:
        echo "Running part 2: "
        var p2_result = part2(everything)
        echo "Part 2 result: ", p2_result
