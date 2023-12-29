import ../../../toolbox

func parseInput(s: string): seq[(string, seq[uint8])] = 
    let lines = s.strip.splitLines
    for i in lines:
        var s = i.split(" ",2)
        result.add((
            s[0],
            s[1].split(",").map(x => x.parseInt().uint8)
        ))

proc checkFit(pattern: string, start: int, stop: int): bool =
    for i in start..<stop:
        if pattern[i] == '.':
            return false

    if start > 0 and pattern[start - 1] == '#': return false # avoid merge on borders
    if stop < pattern.len and pattern[stop] == '#': return false
    return true

var hints: seq[uint8]
var memoTable: Table[(int16, uint8), int]
proc possibilities(pattern: string, pslice: int16, hintSlice: uint8): int =
    if hintSlice == hints.len.uint8:
        for c in pattern.toOpenArray(pslice, pattern.len - 1):
            if c == '#': return 0
        return 1
    
    if pslice == pattern.len:
        return 0

    if (pslice, hintSlice) in memoTable:
        return memoTable[(pslice, hintSlice)]

    let currentGroupSize = hints[hintSlice]
    var res = 0

    if currentGroupSize.int + pslice <= pattern.len:
        for i in pslice ..< pattern.len - currentGroupSize.int + 1:
            if checkFit(pattern, i, i + currentGroupSize.int):
                # assume the ??? stand for ### in this part
                let nextSlice = min(pattern.len, i + currentGroupSize.int + 1)
                res += possibilities(pattern, nextSlice.int16, hintSlice + 1)

            if pattern[i] == '#':
                break

    memoTable[(pslice, hintSlice)] = res
    return res


proc part1(s: string): string = 
    var r = parseInput(s)
    var res = 0
    for i in r:
        hints = i[1]
        memoTable.clear()
        var p = possibilities(i[0], 0, 0)
        res += p
    return $res

proc duplicate(pattern: string, hints: seq[uint8]): (string, seq[uint8]) =
    var patfive = ""
    var hintfive: seq[uint8] = @[]
    for i in 0..<5:
        patfive &= pattern
        if i != 4:
            patfive.add "?"
        hintfive = hintfive.concat(hints)

    return (patfive, hintfive)

proc part2(s: string): string = 
    var r = parseInput(s)
    var res = 0

    for i in r:
        var j = duplicate(i[0], i[1])
        hints = j[1]
        memoTable.clear()
        var p = possibilities(j[0], 0, 0)
        res += p

    return $res

run(2023, 12, part1, part2)

