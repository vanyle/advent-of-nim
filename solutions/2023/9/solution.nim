import ../../../toolbox

proc isAllZero(v: seq[int]): bool =
    for i in v:
        if i != 0: return false
    return true

proc extrapolate(v: seq[int]): int =
    var exStack: seq[seq[int]] = newSeqOfCap[seq[int]](v.len)
    exStack.add v
    while (not isAllZero exStack[^1]):
        var p: seq[int]
        for i in 1..<exStack[^1].len:
            p.add(exStack[^1][i] - exStack[^1][i-1])

        exStack.add p

    var nextValue = 0
    for i in countdown(exStack.len - 1, 0):
        nextValue += exStack[i][^1]

    return nextValue

proc part1(s: string): string = 
    var res = 0
    for l in s.fastSplit('\n'):
        if l.len == 0: continue
        var i = ints(l)
        res += extrapolate(i)

    return $res


proc extrapolate2(v: seq[int]): int =
    var exStack: seq[seq[int]] = @[v]
    while (not isAllZero exStack[^1]):
        var p: seq[int]
        for i in 1..<exStack[^1].len:
            p.add(exStack[^1][i] - exStack[^1][i-1])

        exStack.add p

    var nextValue = 0
    for i in countdown(exStack.len - 1, 0):
        nextValue = exStack[i][0] - nextValue

    return nextValue

proc part2(s: string): string = 
    var res = 0
    for l in s.fastSplit('\n'):
        if l.len == 0: continue
        var i = ints(l)
        res += extrapolate2(i)

    return $res


run(2023, 9, part1, part2)