import ../../../toolbox

proc parseInput(s: string): seq[(string, seq[string])] = 
    var ll = s.strip.split("\n")
    for l in ll:
        var els = l.split(": ",1)
        result.add((
            els[0],
            els[1].split(" ")
        ))

proc part1(s: string): string = 
    var r = parseInput(s)

    # 1. Construct Graph
    # 2. Run ford fulkerson on pairs of vertices until we get 3 as max flow
    # 3. Cut there.

    echo r


proc part2(s: string): string = 
    var r = parseInput(s)


run(2023, 25, part1, part2)