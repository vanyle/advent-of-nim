# Utils functions for aoc.
# Include a astar with some docs
# a sat solver
# and other goodies.

# Good functional packages
import strutils, sequtils, strscans, tables, sets, sugar
export strutils, sequtils, strscans, tables, sets, sugar

# Helper functions that are commonly useful.
import itertools, astar, memo
export itertools, astar, memo


import times

# Inspired by:
# https://github.com/mcpower/adventofcode/blob/15ae109bc882ca688665f86e4ca2ba1770495bb4/utils.py

#[
proc isPrime*(p: int): bool =
    (2..(p-1)).toSeq.map((n) => (p mod n) != 0).all((x) => x)
]#


# ------------- COMMON -----------------

proc ints*(s: string): seq[int] =
    ## return all integers inside a string
    discard

# ------------ STRING -----------------

iterator findAll*(input: string, pattern: seq[string]): seq[string] =
    ## pattern = ["*","hello","*"]
    ## input = this is hello hello world
    ## output:
    ## yield ["this is ","hello"," hello world"]
    ## yield ["this is hello ","hello"," world"]
    discard

proc editDistance*[T](a: seq[T], b: seq[T]): int =
    discard

# ------------ GRIDS ------------------

proc getArr*[T](a: seq[seq[T]], x,y: int, default: T): T =
    if x < 0 or y < 0 or y > a.len or x > a[y].len:
        return default
    return a[y][x]

proc makeGrid[T](x:int,y:int,filler: T): seq[seq[T]] =
    discard

iterator neighFour*[T](a: seq[seq[T]], x,y: int): T =
    discard
iterator neighEight*[T](a: seq[seq[T]], x,y: int): T =
    discard

# ------------ ITERTOOLS SEQUEL -------------

iterator addUpTo(elementCount: int, addsUpTo: int): seq[int] =
    ## yields all sequences of ints of length elementCount
    ## where the sum is addsUpTo.
    discard



proc run*(year: int, day: int, part1: proc(s: string): string, part2: proc(
        s: string): string) =
    var everything = stdin.readAll()

    if part1 != nil:
        echo "Running part 1: "
        let time = cpuTime()
        var p1_result = part1(everything)
        let t = cpuTime() - time
        echo "Part 1 result: ", p1_result
        echo "Done in: ",t,"s"

    if part2 != nil:
        echo "Running part 2: "
        let time = cpuTime()
        var p2_result = part2(everything)
        let t = cpuTime() - time
        echo "Part 2 result: ", p2_result
        echo "Done in: ",t,"s"