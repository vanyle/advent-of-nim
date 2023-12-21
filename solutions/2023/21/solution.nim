import ../../../toolbox

import math, deques

var testIndicator = -1

proc parseInput(s: string): seq[string] =
    let lines = s.strip.split("\n")
    if lines[0].len <= 4:
        testIndicator = parseInt(lines[0])
        return lines[1..<lines.len]
    return lines

proc acc(map: seq[string], i,j:int): char {.inline.} =
    if i < 0 or j < 0 or i >= map.len or j >= map[0].len:
        return '#'
    return map[i][j]

iterator nei(map: seq[string], start: (int, int)): (int,int) =
    var (y,x) = start

    if map.acc(y,x+1) != '#':
        yield (y, x+1)
    if map.acc(y,x-1) != '#':
        yield (y, x-1)
    if map.acc(y+1,x) != '#':
        yield (y+1, x)
    if map.acc(y-1,x) != '#':
        yield (y-1, x)

proc bfs(map: seq[string], start: (int, int), steps: int): int =
    var current: HashSet[(int, int)]
    var visited = [start].toHashSet
    var q = [(start[0], start[1], steps)].toDeque

    while q.len > 0:
        var (r, c, s) = q.popFirst()

        if s mod 2 == 0:
            current.incl (r, c)
        if s == 0:
            continue

        for n in map.nei((r, c)):
            if n notin visited:
                visited.incl n
                q.addLast (n[0], n[1], s - 1)
    
    return current.len

proc part1(s: string): string = 
    var r = parseInput(s)
    var start: (int,int)
    block seekS:
        for i in 0..<r.len:
            for j in 0..<r[i].len:
                if r[i][j] == 'S':
                    start = (i, j)
                    break seekS

    var steps = 64
    if testIndicator != -1:
        steps = testIndicator

    var res = r.bfs(start, 64)
    return $res


proc part2(s: string): string = 
    var r = parseInput(s)
    var start: (int,int)
    block seekS:
        for i in 0..<r.len:
            for j in 0..<r[i].len:
                if r[i][j] == 'S':
                    start = (i, j)
                    break seekS

    var sm = r.len - 1    
    var steps = 26501365
    if testIndicator != -1:
        steps = testIndicator

    var diamondSize = (steps div r.len) - 1

    # The reachable points grow in a diamond like pattern.
    # Due to the form of the output, we know the number of full grids that will be reached.

    var odd = (diamondSize div 2 * 2 + 1) ^ 2
    var even = ((diamondSize + 1) div 2 * 2) ^ 2

    # We thus multiply those by the number of reachable spots on those grids for odd and even amounts of steps
    var oddPlots = r.bfs(start, r.len * 2 + 1)
    var evenPlots = r.bfs(start, r.len * 2)

    var res = odd * oddPlots + even * evenPlots # This is a very good approximation of the solution.
    
    # We need to add contribution of the 4 corners at the edges of the diamond.
    res += r.bfs((sm, start[1]), sm)
    res += r.bfs((start[0], 0), sm)
    res += r.bfs((0, start[1]), sm)
    res += r.bfs((start[0], sm), sm)

    # The diamond is not perfect, some places will be reached a bit sooner than other
    # We compute the compensation for those.
    var smallTR = r.bfs((sm,  0), r.len div 2 - 1)
    var smallTL = r.bfs((sm, sm), r.len div 2 - 1)
    var smallBR = r.bfs((0 , 0 ), r.len div 2 - 1)
    var smallBL = r.bfs((0 , sm), r.len div 2 - 1)

    var largeTR = r.bfs((sm, 0 ), r.len * 3 div 2 - 1)
    var largeTL = r.bfs((sm, sm), r.len * 3 div 2 - 1)
    var largeBR = r.bfs((0 ,  0), r.len * 3 div 2 - 1)
    var largeBL = r.bfs((0 , sm), r.len * 3 div 2 - 1)

    res += (diamondSize + 1) * (smallTR + smallTL + smallBR + smallBL)
    res += diamondSize * (largeTR + largeTL + largeBR + largeBL)

    return $res


run(2023, 21, part1, part2)