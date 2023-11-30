import ../../../toolbox

proc parseInput(s: string): seq[seq[int]] = 
    return s.split("\n\n").map(x => x.split("\n").map(parseInt))

proc sum(x: seq[int]): int = x.foldl(a + b, 0)

proc part1(s: string): string = 
    var r = parseInput(s)
    return $(r.map(sum).max())

proc part2(s: string): string = 
    var r = parseInput(s)
    return $(r.map(sum).sorted(cmp, Descending)[0..2].sum())

run(2022, 1, part1, part2)