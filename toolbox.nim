# Utils functions for aoc.
# Include a astar with some docs
# a sat solver
# and other goodies.

# Good functional packages
import strutils, sequtils, strscans, tables, sets, sugar, algorithm
export strutils, sequtils, strscans, tables, sets, sugar, algorithm

# Helper functions that are commonly useful.
import itertools, astar, memo
export itertools, astar, memo


import times, re

# Inspired by:
# https://github.com/mcpower/adventofcode/blob/15ae109bc882ca688665f86e4ca2ba1770495bb4/utils.py

#[
proc isPrime*(p: int): bool =
    (2..(p-1)).toSeq.map((n) => (p mod n) != 0).all((x) => x)
]#


# ------------- COMMON -----------------

proc ints*(s: string): seq[int] =
    ## return all integers inside a string
    return re.findAll(s, re"-?\d+").map(parseInt)

proc reverseTable* [T](l: seq[T]): Table[T, int] =
    ## Returns the table containing indices to elements of a list
    for i in 0..<l.len:
        result[l[i]] = i

# ------------ STRING -----------------

iterator findAll*(input: string, pattern: seq[string]): seq[string] =
    ## pattern = ["*","hello","*"]
    ## input = this is hello hello world
    ## output:
    ## yield ["this is ","hello"," hello world"]
    ## yield ["this is hello ","hello"," world"]
    discard


# We can define editDistance recursively using a cache.
# https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance
proc editDistance*[T](a: seq[T], b: seq[T]): int =
    var rTable: Table[(int, int), int]

    proc edh[T](a: seq[T], b: seq[T], i,j: int): int =
        # Edit distance helper.
        if (i,j) in rTable:
            return rTable[(i,j)]
        if i == 0 and j == 0: return 0
        if i == 0: return j
        if j == 0: return i

        if a[i] == b[i]:
            var r = edh(a,b,i-1,j-1)
            rTable[(i,j)] = r
            return r 

        let e1 = edh(a,b,i-1,j)
        let e2 = edh(a,b,i,j-1)
        let e3 = edh(a,b,i-1,j-1)
        var r = 1 + min(e1, min(e2, e3))
        rTable[(i,j)] = r
        return r

    return edh(a,b, a.len - 1, b.len - 1)

# ------------ GRIDS ------------------

proc getArr*[T](a: seq[seq[T]], x,y: int, default: T): T =
    if x < 0 or y < 0 or y >= a.len or x >= a[y].len:
        return default
    return a[y][x]

proc makeGrid*[T](x:int,y:int,filler: T): seq[seq[T]] =
    result = newSeq[T](y)
    for i in 0..<y:
        result[i] = newSeq[T](x)


iterator neighFour*[T](a: seq[seq[T]], x,y: int): T =
    if x+1 < a[y+1].len:
        yield a[y][x+1]
    if x-1 >= 0:
        yield a[y][x-1]
    if y-1 >= 0:
        yield a[y-1][x]
    if y+1 < a.len:
        yield a[y+1][x]

iterator neighEight*[T](a: seq[seq[T]], x,y: int): T =
    if x+1 < a[y+1].len:
        yield a[y][x+1]
    if x-1 >= 0:
        yield a[y][x-1]
    if y-1 >= 0:
        yield a[y-1][x]
    if y+1 < a.len:
        yield a[y+1][x]
    if y+1 < a.len and x+1 < a[y+1].len:
        yield a[y+1][x+1]
    if y+1 < a.len and x-1 >= 0:
        yield a[y+1][x-1]
    if y-1 >= 0 and x+1 < a[y-1].len:
        yield a[y-1][x+1]
    if y-1 >= 0 and x-1 >= 0:
        yield a[y-1][x-1]


# ------------ ITERTOOLS SEQUEL -------------

iterator addUpTo*(elementCount: int, addsUpTo: int): seq[int] =
    ## yields all sequences of positive integers of length elementCount
    ## where the sum is addsUpTo.
    ## Example:
    ## addsUpTo = 5, elementCount = 3
    ## [5,0,0], [3,1,1], [2,2,1], [2,1,2], etc...


    var bin = newSeq[bool](elementCount + addsUpTo - 1)
    for i in 0..<(elementCount - 1):
        bin[i] = true

    while true:
        # place addsUpTo-1 elements to true.
        var n = newSeq[int](elementCount)
        var j = 0
        for i in 0..<bin.len:
            if bin[i]: # There are elementCount - 1 such elements
                inc j
            else:
                inc n[j]
        yield n

        if not bin.prevPermutation():
            break




proc run*(year: int, day: int, part1: proc(s: string): string, part2: proc(
        s: string): string) =
    var everything = stdin.readAll()

    block:
        echo "Running part 1: "
        let time = cpuTime()
        var p1_result = part1(everything)
        let t = cpuTime() - time
        if p1_result.len > 0:
            echo "Part 1 result: ", p1_result
            echo "Done in: ",t,"s"
            try:
                discard parseInt(p1_result)
            except:
                echo ""
                echo "> WARNING: result of part1 is not an integer!"
                echo ""

        else:
            return # part 1 not finished, don't run part 2

    block:
        echo "Running part 2: "
        let time = cpuTime()
        var p2_result = part2(everything)
        let t = cpuTime() - time

        if p2_result.len > 0:
            echo "Part 2 result: ", p2_result
            echo "Done in: ",t,"s"
            
            try:
                discard parseInt(p2_result)
            except:
                echo ""
                echo "> WARNING: result of part2 is not an integer!"
                echo ""