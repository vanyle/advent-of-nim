import ../../../toolbox

func parseInput(s: string): seq[(string, seq[int])] = 
    let lines = s.strip.splitLines
    for i in lines:
        var s = i.split(" ",2)

        result.add((
            s[0],
            s[1].split(",").map(parseInt)
        ))


func possibilities(pattern: string, hints: seq[int], counterSeq: int): int {.memoized.} =
    # Recursion, my boy!!

    var brokenCounter = counterSeq

    for j in countdown(pattern.len-1, 0):
        if pattern[j] == '#':
            inc brokenCounter
        elif pattern[j] == '.':
            if brokenCounter == 0: continue
            if hints.len == 0: return 0
            if hints[^1] == brokenCounter: # ok!
                return possibilities(pattern[0..<j], hints[0..<hints.len-1], 0)
            else:
                return 0 # impossible!
        elif pattern[j] == '?':
            var p1 = pattern[0..<j] & '.'
            var p2 = pattern[0..<j] & '#'
            return possibilities(p1, hints, brokenCounter) + possibilities(p2, hints, brokenCounter)


    # make sure the counter and the hint match here.
    if hints.len > 1: return 0
    if hints.len == 1 and brokenCounter == hints[0]:
        return 1
    if hints.len == 0 and brokenCounter == 0:
        return 1
    return 0

proc part1(s: string): string = 
    var r = parseInput(s)
    var res = 0
    for i in r:
        var p = possibilities(i[0], i[1], 0)
        res += p
    return $res

proc duplicate(pattern: string, hints: seq[int]): (string, seq[int]) =
    var patfive = ""
    var hintfive: seq[int] = @[]
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
        var p = possibilities(j[0], j[1], 0)
        echo p
        res += p

    return $res

run(2023, 12, part1, part2)