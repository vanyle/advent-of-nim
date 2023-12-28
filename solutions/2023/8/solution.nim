import ../../../toolbox

type Graph = Table[array[3, char], (array[3, char], array[3, char])]
import math

proc part1(s: string): string = 
    var stepsLen = 0
    while s[stepsLen] != '\n':
        inc stepsLen

    var graph: Graph

    for i in s.toOpenArray(stepsLen+2, s.len-1).fastSplit('\n'):
        var start: array[3, char]
        var left: array[3, char]
        var right: array[3, char]
        
        var idx = 0
        for j in 0..2:
            start[j] = i[j]
        for j in 7..9:
            left[idx] = i[j]
            inc idx
        idx = 0
        for j in 12..14:
            right[idx] = i[j]
            inc idx

        graph[start] = (left, right)
    
    var pos = ['A','A','A']
    var posInStep = 0
    var step = 0

    if ['A', 'A', 'A'] notin graph: return "0"

    while pos != ['Z','Z','Z']:
        let d = s[posInStep]
        if d == 'R':
            pos = graph[pos][1]
        else:
            pos = graph[pos][0]

        inc step
        inc posInStep
        if posInStep >= stepsLen:
            posInStep = 0

    return $step


proc part2(s: string): string = 
    var stepsLen = 0
    while s[stepsLen] != '\n':
        inc stepsLen

    var graph: Graph

    for i in s.toOpenArray(stepsLen+2, s.len-1).fastSplit('\n'):
        var start: array[3, char]
        var left: array[3, char]
        var right: array[3, char]
        
        var idx = 0
        for j in 0..2:
            start[j] = i[j]
        for j in 7..9:
            left[idx] = i[j]
            inc idx
        idx = 0
        for j in 12..14:
            right[idx] = i[j]
            inc idx

        graph[start] = (left, right)

    var startingPoints: seq[array[3, char]] = @[]
    for i, v in graph:
        if i[2] == 'A':
            startingPoints.add(i)

    var cycleData: seq[int] # length
    for pt in startingPoints:
        var pos = pt
        var posInStep = 0
        var step = 0
        while pos[2] != 'Z':
            let d = s[posInStep]
            if d == 'R':
                pos = graph[pos][1]
            else:
                pos = graph[pos][0]

            inc step
            inc posInStep
            if posInStep >= stepsLen:
                posInStep = 0
        cycleData.add(step)

    var prod = 1
    for c in cycleData:
        prod = lcm(prod, c)

    return $prod



run(2023, 8, part1, part2)