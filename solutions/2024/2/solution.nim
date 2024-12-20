import ../../../toolbox

proc isSafe(lvls: seq[int]): bool = 
    var isUp = lvls[1] > lvls[0] and lvls[2] > lvls[1]

    for i in 0..<lvls.len-1:
        if (lvls[i+1] > lvls[i]) != isUp:
            return false
        let delta = abs(lvls[i+1] - lvls[i])
        if delta < 1 or delta > 3:
            return false
    return true

proc part1(s: string): string = 
    var safeCount = 0

    for l in s.fastSplit('\n'):
        if l.len <= 2:
            continue
        var lvls = ints(l, 8)
        if isSafe(lvls):
            safeCount.inc()

    return $safeCount


proc part2(s: string): string = 
    var safeCount = 0

    for l in s.fastSplit('\n'):
        if l.len <= 2:
            continue
        var lvls = ints(l, 8)
        if isSafe(lvls):
            safeCount.inc()
            continue
        
        var existsSafeCombination = false

        for i in 0..<lvls.len:
            var copy = lvls
            copy.delete(i)
            if isSafe(copy):
                existsSafeCombination = true
                break
        if existsSafeCombination:
            safeCount.inc()

    return $safeCount

run(2024, 2, part1, part2)