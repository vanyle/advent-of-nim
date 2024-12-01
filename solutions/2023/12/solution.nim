import ../../../toolbox

func parseInput(s: string): seq[(string, seq[uint8])] = 
    let lines = s.strip.splitLines
    for i in lines:
        var s = i.split(" ",2)
        result.add((
            s[0],
            s[1].split(",").map(x => x.parseInt().uint8)
        ))

var hints: seq[uint8]
var memoTable: Table[(int16, int8), int]
proc possibilities(pattern: string, pslice: int16, hintSlice: int8): int =
    if hintSlice == -1:
        for c in pattern.toOpenArray(0, pslice):
            if c == '#': return 0
        return 1
    
    if pslice == -1:
        return 0
    
    if (pslice, hintSlice) in memoTable:
        return memoTable[(pslice, hintSlice)]

    let hint = hints[hintSlice].int
    var res = 0

    for i in countdown(pslice.int, hint - 1):
        var isMatch = true
        for i in (i - hint + 1)..<(i + 1):
            isMatch = isMatch and not (pattern[i] == '.')
        isMatch = isMatch and not (i - hint + 1 > 0 and pattern[i - hint] == '#')
        isMatch = isMatch and not (i + 1 < pattern.len and pattern[i + 1] == '#')

        if isMatch:
            let nextSlice = max(-1, i - hint - 1)
            res += possibilities(pattern, nextSlice.int16, hintSlice - 1)

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
        var p = possibilities(i[0], i[0].len.int16 - 1, hints.len.int8 - 1)
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
        var p = possibilities(j[0], j[0].len.int16 - 1, hints.len.int8 - 1)
        res += p

    return $res

run(2023, 12, part1, part2)

