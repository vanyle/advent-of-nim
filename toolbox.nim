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


import re, std/monotimes, times

# Inspired by:
# https://github.com/mcpower/adventofcode/blob/15ae109bc882ca688665f86e4ca2ba1770495bb4/utils.py

#[
proc isPrime*(p: int): bool =
    (2..(p-1)).toSeq.map((n) => (p mod n) != 0).all((x) => x)
]#


# ------------- COMMON -----------------

proc reverseTable* [T](l: seq[T]): Table[T, int] =
    ## Returns the table containing indices to elements of a list
    for i in 0..<l.len:
        result[l[i]] = i

proc reverseTable* [A,B](t: Table[A,B]): Table[B,A] =
    ## Return the table with keys and values swapped.
    ## We assume that every value is unique.
    for k,v in t:
        result[v] = k

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

proc getArr*[T](a: openarray[openarray[T]], x,y: int, default: T): T =
    if x < 0 or y < 0 or y >= a.len or x >= a[y].len:
        return default
    return a[y][x]

proc getArr*(a: seq[string], x,y: int, default: char): char =
    if x < 0 or y < 0 or y >= a.len or x >= a[y].len:
        return default
    return a[y][x]

proc bToI8*(a: bool): int8 =
    return cast[int8](a)

proc bToI*(a: bool): int =
    return cast[int](a)

proc makeGrid*[T](x:int,y:int,filler: T): seq[seq[T]] =
    result = newSeq[T](y)
    for i in 0..<y:
        result[i] = newSeq[T](x)
        for j in 0..<x:
            result[i][j] = filler

iterator neighFour*[T](a: openarray[openarray[T]], x,y: int): T =
    if x+1 < a[y+1].len:
        yield a[y][x+1]
    if x-1 >= 0:
        yield a[y][x-1]
    if y-1 >= 0:
        yield a[y-1][x]
    if y+1 < a.len:
        yield a[y+1][x]

iterator neighEight*[T](a: seq[seq[T]], y,x: int): (T, (int,int)) =
    if x+1 < a[y+1].len:
        yield (a[y][x+1], (y,x+1))
    if x-1 >= 0:
        yield (a[y][x-1], (y,x-1))
    if y-1 >= 0:
        yield (a[y-1][x], (y-1,x))
    if y+1 < a.len:
        yield (a[y+1][x], (y+1, x))
    if y+1 < a.len and x+1 < a[y+1].len:
        yield (a[y+1][x+1], (y+1,x+1))
    if y+1 < a.len and x-1 >= 0:
        yield (a[y+1][x-1], (y+1,x-1))
    if y-1 >= 0 and x+1 < a[y-1].len:
        yield (a[y-1][x+1], (y-1,x+1))
    if y-1 >= 0 and x-1 >= 0:
        yield (a[y-1][x-1], (y-1, x-1))


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

# ---------- BENCHMARKING AND SPEED SPECIFIC -----------

template timeBlock*(name: string, body: untyped) =
    ## Return the execution time of a piece of code.
    let startTime = getMonoTime()
    block:
        body
    let endTime = getMonoTime()
    let delta = ((endTime - startTime).inMicroseconds / 1000)
    echo name & ": " & $delta & " ms"

iterator fastSplit*(s: openarray[char], c: char): auto =
    var i = 0
    var prev = 0
    while i < s.len:
        if s[i] == c:
            yield s.toOpenArray(prev, i-1)
            prev = i+1
        inc i
    yield s.toOpenArray(prev, s.len-1)

proc toString*(s: openarray[char]): string =
    result = newString(s.len)
    copyMem(result[0].addr, s[0].addr, s.len)

proc isDigitFast*(c: char): bool {.inline.} =
    return c <= '9' and '0' <= c

proc toDigit*(c: char): int {.inline.} =
    return cast[int](c) - cast[int]('0')

proc toDigitOfType*[T](c: char): T {.inline.} =
    return cast[T](c) - cast[T]('0')

type Tokenizer* = object
    s*: string
    offset*: int

proc isEqual*(a: openarray[char], b: static[string]): bool {.inline.} =
    # Don't check for length as b is static, so we can assume that a was correctly sliced.
    for i in 0..<b.len: # notice we use b here as b is know at compile time so the loop can be unrolled.
        if a[i] != b[i]: return false
    return true

proc advance*(t: var Tokenizer, c: char, until: int = int.high) =
    while t.offset < until and t.s[t.offset] != c:
        inc t.offset

proc advance*(t: var Tokenizer, s: static[string], until: int = int.high) =
    while t.offset < until and not isEqual(t.s.toOpenArray(t.offset, t.offset+s.len-1), s):
        inc t.offset

proc findNext*(t: Tokenizer, c: char, until: int = int.high): int =
    result = t.offset
    while result < until and result < t.s.len and t.s[result] != c:
        inc result

proc findNext*(t: Tokenizer, s: static[string], until: int = int.high): int =
    result = t.offset
    while result < until and result < (t.s.len - s.len + 1) and not isEqual(t.s.toOpenArray(result, result+s.len-1), s):
        inc result

proc advanceFixed*(t: var Tokenizer, i: int) =
    t.offset += i

proc atEnd*(t: Tokenizer): bool {.inline.} = return t.offset >= t.s.len

proc parseUnsignedInt*(s: openarray[char]): int =
    var i = 0
    while i < s.len and isDigitFast(s[i]):
        result *= 10
        result += toDigit(s[i])
        inc i

proc parseUnsignedIntOfSize*[T](s: openarray[char]): T =
    var i = 0
    while i < s.len and isDigitFast(s[i]):
        result *= 10
        result += toDigitOfType[T](s[i])
        inc i


proc eatUnsignedInt*(t: var Tokenizer): int =
    while t.offset < t.s.len:
        let c = t.s[t.offset]
        if not isDigitFast(c):
            return result
        var d = toDigit(c)
        result *= 10
        result += d
        inc t.offset

proc ints*(s: openarray[char], cap: int = 3): seq[int] =
    ## return all integers inside a string, quickly.
    ## Handle negative numbers (at a speed cost.)
    result = newSeqOfCap[int](cap)
    var p = 0
    var nflag = 1
    var isP = false

    for i in 0..<s.len:
        if s[i] == '-':
            nflag = -1
        elif isDigitFast(s[i]):
            isP = true
            p *= 10
            p += toDigit(s[i]) * nflag
        else:
            if isP:
                result.add(p)
                p = 0
                isP = false
            nflag = 1
    
    if isP:
        result.add p

# ---------------------------------------------------------

proc run*(year: int, day: int, part1: proc(s: string): string, part2: proc(
        s: string): string) =
    var everything = stdin.readAll()

    block:
        echo "Running part 1: "
        let time = getMonoTime()
        var p1_result = part1(everything)
        let t = getMonoTime() - time
        if p1_result.len > 0:
            echo "Part 1 result: ", p1_result
            echo "Done in: ",(t.inMicroseconds.float)/1000,"ms"
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
        let time = getMonoTime()
        var p2_result = part2(everything)
        let t = getMonoTime() - time # nanoseconds

        if p2_result.len > 0:
            echo "Part 2 result: ", p2_result
            echo "Done in: ",(t.inMicroseconds.float/1000),"ms"
            
            try:
                discard parseInt(p2_result)
            except:
                echo ""
                echo "> WARNING: result of part2 is not an integer!"
                echo ""