import ../../../toolbox

import heapqueue, tables, hashes, options

# A Star implementation, from the astar package.

type
    Distance* = int|float
    Node* = concept n
        `==`(n, n) is bool
        `hash`(n) is Hash

    Graph* = concept g
        var node: Node
        for neighbor in g.neighbors(node):
            type(neighbor) is Node
        cost(g, node, node) is Distance

    Point* = concept p
        p.x is Distance
        p.y is Distance


type
    FrontierElem[N, D] = tuple[node: N, priority: D, cost: D]
    CameFrom[N, D] = tuple[node: N, cost: D]

proc `<`(a, b: FrontierElem): bool = a.priority < b.priority

iterator backtrack[N, D](
    cameFrom: Table[N, CameFrom[N, D]], start, goal: N
): N =
    yield start
    var current: N = goal
    var path: seq[N] = @[]
    while current != start:
        path.add(current)
        current = `[]`(cameFrom, current).node

    for i in countdown(path.len - 1, 0):
        yield path[i]

proc calcHeuristic[G: Graph, N: Node, D: Distance] (
    graph: G,
    next, start, goal: N,
    current: FrontierElem[N, D],
    cameFrom: Table[N, CameFrom[N, D]],
): D {.inline.} =
    when compiles(graph.heuristic(next, start, goal, current.node)):
        return D(graph.heuristic(next, start, goal, current.node))

    elif compiles(graph.heuristic(next, start, goal, current.node, none(N))):
        var grandparent: Option[N]
        if cameFrom.hasKey(current.node):
            grandparent = some[N]( `[]`(cameFrom, current.node).node )
        else:
            grandparent = none(N)
        return D(graph.heuristic(next, start, goal, current.node, grandparent))

    else:
        return D(graph.heuristic(next, goal))

iterator path*[G: Graph, N: Node, D: Distance](graph: G, start, goal: N): N =
    var frontier = initHeapQueue[FrontierElem[N, D]]()
    frontier.push( (node: start, priority: D(0), cost: D(0)) )
    var cameFrom = initTable[N, CameFrom[N, D]]()

    while frontier.len > 0:
        let current = frontier.pop
        if current.node == goal:
            for node in backtrack(cameFrom, start, goal):
                yield node
            break

        for next in graph.neighbors(current.node):
            let cost = current.cost + D( graph.cost(current.node, next) )
            if not cameFrom.hasKey(next) or cost < `[]`(cameFrom, next).cost:
                `[]=`(cameFrom, next, (node: current.node, cost: cost))
                let priority: D = cost + calcHeuristic[G, N, D](
                    graph, next, start, goal, current, cameFrom )
                frontier.push( (next, priority, cost) )

## =======================================================================

proc parseInput(s: string): seq[seq[int8]] = 
    var lines = s.strip.split("\n")
    result = newSeq[seq[int8]](lines.len)
    for i in 0..<lines.len:
        for j in lines[i]:
            result[i].add parseInt($j).int8

type Dir = enum
    Vertical
    Horizontal

type MyG = seq[seq[int8]]
type MyN = (int16, int16, Dir) # x,y and Dir. You can only turn.

template validatePos(grid: MyG, node: MyN) =
    let isOk = node[0] >= 0 and node[1] >= 0 and node[0] < grid.len and node[1] < grid[node[0]].len
    if isOk:
        yield node

proc cost*(grid: MyG, a: MyN, b: MyN): int =
    if a[0] == b[0] and a[1] == b[1]:
        return 0

    for i in min(a[0],b[0])..max(a[0],b[0]):
        for j in min(a[1],b[1])..max(b[1],a[1]):
            if i != a[0] or j != a[1]:
                result += grid[i][j]

proc heuristic*(grid: MyG, a: MyN, b: MyN): int =
    return abs(a[0] - b[0]) + abs(a[1] - b[1])


type HQ = tuple[node: MyN, cost: int]
proc `<`(a, b: HQ): bool = a.cost < b.cost

#[

Part 1 result: 1039                                                                                                                                                   
Done in: 51.814ms                                                                                                                                                     
Running part 2:                                                                                                                                                       
Part 2 result: 1201                                                                                                                                                   
Done in: 126.232ms

]#

type NGraph = tuple[w: int16, h: int16, data: seq[int8]]

proc at(grid: NGraph, i, j: int16): int8 =
    return grid.data[j + i * grid.w]

template nvalidatePos(grid: NGraph, node: MyN) =
    if node[0] >= 0 and node[1] >= 0 and node[0] < grid.h and node[1] < grid.w:
        yield node

iterator nneighbors*(grid: NGraph, node: MyN): MyN =
    var (y, x, d) = node

    if y == grid.h - 1 and x == grid.w - 1:
        for i in Dir:
            yield (y, x, i)
    elif y == 0 and x == 0:
        for i in Dir:
            yield (y, x, i)

    if d == Vertical:
        for i in 1..3:
            nvalidatePos(grid, (y, (x-i).int16, Horizontal))
            nvalidatePos(grid, (y, (x+i).int16, Horizontal))

    elif d == Horizontal:
        for i in 1..3:
            nvalidatePos(grid, ((y-i).int16, x, Vertical))
            nvalidatePos(grid, ((y+i).int16, x, Vertical))

proc ncost*(grid: NGraph, a: MyN, b: MyN): int =
    if a[0] == b[0] and a[1] == b[1]:
        return 0

    for i in min(a[0],b[0])..max(a[0],b[0]):
        for j in min(a[1],b[1])..max(b[1],a[1]):
            if i != a[0] or j != a[1]:
                result += grid.at(i,j)
             

proc part1(s: string): string = 
    var r: NGraph = (w: 0, h: 0, data: newSeqOfCap[int8](s.len))

    for i in 0..<s.len:
        if r.w == 0:
            inc r.h
        if s[i] == '\n':
            inc r.w
        else:
            r.data.add(cast[int8](s[i]) - cast[int8]('0'))

    var start = (0.int16, 0.int16, Vertical)
    var dest = (r.h - 1, r.w - 1, Horizontal)
    var pcost = 0

 
    var frontier = initHeapQueue[HQ]() # node, cost
    frontier.push((node: start, cost: 0))
    var cameFrom: Table[MyN, CameFrom[MyN, int]] # node => node, cost

    while frontier.len > 0:
        let current = frontier.pop # extract smallest priority first
        if current.node == dest:
            pcost = current.cost
            break

        for next in r.nneighbors(current.node):
            let cost = current.cost + r.ncost(current.node, next)
            if not (next in cameFrom) or cost < cameFrom[next].cost:
                cameFrom[next] = (node: current.node, cost: cost)
                frontier.push( (next, cost) )

    return $pcost


type MyG2 = distinct MyG

proc heuristic*(grid: MyG2, a: MyN, b: MyN): int =
    # return max(abs(a[0] - b[0]),abs(a[1] - b[1]))
    return abs(a[0] - b[0]) + abs(a[1] - b[1])

proc cost*(grid: MyG2, a: MyN, b: MyN): int =
    return cost(grid.MyG, a, b)

iterator neighbors*(grid: MyG2, node: MyN): MyN =
    var (y, x, d) = node

    if y == grid.MyG.len - 1 and x == grid.MyG[0].len - 1:
        for i in Dir:
            yield (y, x, i)
    elif y == 0 and x == 0:
        for i in Dir:
            yield (y, x, i)

    if d == Vertical:
        for i in 4..10:
            validatePos(grid.MyG, (y, (x-i).int16, Horizontal))
            validatePos(grid.MyG, (y, (x+i).int16, Horizontal))

    elif d == Horizontal:
        for i in 4..10:
            validatePos(grid.MyG, ((y-i).int16, x, Vertical))
            validatePos(grid.MyG, ((y+i).int16, x, Vertical))

proc part2(s: string): string = 
    var r = parseInput(s)

    var start: MyN = (0, 0, Vertical)
    var dest: MyN = ((r.len - 1).int16, (r[0].len - 1).int16, Horizontal)
    var pcost = 0

    var currentPos = start
    for pt in path[MyG2, MyN, int](r.MyG2, start, dest):
        pcost += r.cost(currentPos, pt)
        currentPos = pt

    return $pcost

run(2023, 17, part1, part2)