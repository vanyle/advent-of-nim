import ../../../toolbox

proc countWays(
    containers: array[20, int],
    cid: int,
    liquidLeft: int
    ): int =
    if liquidLeft == 0: return 1
    if liquidLeft < 0: return 0
    # A partial sum optimization is doable but not needed
    # This solution is fast enough
    if cid == 19 and liquidLeft != containers[19]: return 0
    if cid == 19 and liquidLeft == containers[19]: return 1

    # the cid container can be filled, or not.
    var ways = countWays(containers, cid + 1, liquidLeft)
    ways += countWays(containers, cid + 1, liquidLeft - containers[cid])

    return ways


var part1Ready* = true
proc part1(s: string): string = 
    var nbs = s.strip.splitLines.map(parseInt)
    var containers: array[20, int]
    for i in 0..<nbs.len: containers[i] = nbs[i]

    var ways = countWays(containers, 0, 150)

    return $ways


proc countWays2(
    containers: array[20, int],
    cid: int,
    liquidLeft: int,
    maxFillable: int,
    ): int =
    if maxFillable == 0 and liquidLeft > 0: return 0
    if liquidLeft == 0: return 1
    if liquidLeft < 0: return 0
    if cid == 19 and liquidLeft != containers[19]: return 0
    if cid == 19 and liquidLeft == containers[19]: return 1

    # the cid container can be filled, or not.
    var ways = countWays2(containers, cid + 1, liquidLeft, maxFillable)
    ways += countWays2(containers, cid + 1, liquidLeft - containers[cid], maxFillable - 1)

    return ways

var part2Ready* = true
proc part2(s: string): string = 
    var nbs = s.strip.splitLines.map(parseInt)
    var containers: array[20, int]
    for i in 0..<nbs.len: containers[i] = nbs[i]

    # How many 4 containers can hold 150 liters of eggnog ?
    return $countWays2(containers, 0, 150, 4) 


run(2015, 17, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)