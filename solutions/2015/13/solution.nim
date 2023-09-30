import ../../../toolbox

proc parseInput(s: string): (seq[string], Table[(string,string), int]) =
    var lines = s.strip.splitLines

    var happy: Table[(string, string), int]
    var names: seq[string]

    for l in lines:
        var start, finish: string
        var d: int
        if scanf(l, "$w would gain $i happiness units by sitting next to $w.", start, d, finish):
            happy[(start, finish)] = d
            if start notin names:
                names.add(start)
        elif scanf(l, "$w would lose $i happiness units by sitting next to $w.", start, d, finish):
            happy[(start, finish)] = -d
            if start notin names:
                names.add(start)

    return (names, happy)

var part1Ready* = true
proc part1(s: string): string = 
    var (names, happy) = parseInput(s)

    var nameIndices: seq[int] = toSeq(0..<names.len-1)
    var maxHappiness = low(int)
    for per in permutations(nameIndices):
        var happiness = 0
        var p = per
        p.add(names.len-1) # add the fixed point.

        for j in 0..<(names.len-1):
            happiness += happy[(names[p[j]], names[p[j+1]])]
            happiness += happy[(names[p[j+1]], names[p[j]])]

        # wrap around the table.
        happiness += happy[(names[p[0]], names[p[names.len-1]])]
        happiness += happy[(names[p[names.len-1]], names[p[0]])]

        maxHappiness = max(
            maxHappiness,
            happiness
        )

    return $maxHappiness


var part2Ready* = true
proc part2(s: string): string = 
    var (names, happy) = parseInput(s)
    
    # No fixed point, no wrapping around.
    var nameIndices: seq[int] = toSeq(0..<names.len)

    var maxHappiness = low(int)
    for p in permutations(nameIndices):
        var happiness = 0

        for j in 0..<(names.len-1):
            happiness += happy[(names[p[j]], names[p[j+1]])]
            happiness += happy[(names[p[j+1]], names[p[j]])]

        maxHappiness = max(
            maxHappiness,
            happiness
        )

    # seek a permutation of names.len-1 elements.
    return $maxHappiness


run(2015, 13, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)