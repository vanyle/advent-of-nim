import ../../../toolbox

type Graph = Table[string, (string, string)]

import math

proc parseInput(s: string): (string, Graph) = 
    var parts = s.strip.split("\n\n")
    let moveInstructions = parts[0]
    var graph: Graph
    let lines = parts[1].split("\n")

    for i in lines:
        var start = i[0..2]
        var left = i[7..9]
        var right = i[12..14]
        graph[start] = (left, right)

    return (moveInstructions, graph)

proc part1(s: string): string = 
    var (steps, graph) = parseInput(s)
    
    var pos = "AAA"
    var posInStep = 0
    var step = 0

    if "AAA" notin graph or "ZZZ" notin graph:
        return "0"

    while pos != "ZZZ":
        let d = steps[posInStep]
        if d == 'R':
            pos = graph[pos][1]
        else:
            pos = graph[pos][0]

        inc step
        inc posInStep
        if posInStep >= steps.len:
            posInStep = 0

    return $step


proc part2(s: string): string = 
    var (steps, graph) = parseInput(s)

    var startingPoints: seq[string] = @[]
    for i, v in graph:
        if i[2] == 'A':
            startingPoints.add(i)

    var cycleData: seq[int] # length
    for pt in startingPoints:
        var pos = pt
        var posInStep = 0
        var step = 0
        while pos[2] != 'Z':
            let d = steps[posInStep]
            if d == 'R':
                pos = graph[pos][1]
            else:
                pos = graph[pos][0]

            inc step
            inc posInStep
            if posInStep >= steps.len:
                posInStep = 0
        cycleData.add(step)

    var prod = 1
    for c in cycleData:
        prod = lcm(prod, c)

    return $prod



run(2023, 8, part1, part2)