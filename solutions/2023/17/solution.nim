import ../../../toolbox

proc parseInput(s: string): seq[seq[int8]] = 
    var lines = s.strip.split("\n")
    result = newSeq[seq[int8]](lines.len)
    for i in 0..<lines.len:
        for j in lines[i]:
            result[i].add parseInt($j).int8

type Dir = enum
    Up
    Down
    Left
    Right

type MyG = seq[seq[int8]]
type MyN = (int16, int16, Dir) # x,y and Dir. You can only turn.

template validatePos(grid: MyG, node: MyN) =
    let isOk = node[0] >= 0 and node[1] >= 0 and node[0] < grid.len and node[1] < grid[node[0]].len
    if isOk:
        yield node

iterator neighbors*(grid: MyG, node: MyN): MyN =
    var (y, x, d) = node

    if y == grid.len - 1 and x == grid[0].len - 1:
        for i in Dir:
            yield (y, x, i)
    elif y == 0 and x == 0:
        for i in Dir:
            yield (y, x, i)

    if d == Up or d == Down:
        for i in 1..3:
            validatePos(grid, (y, (x-i).int16, Left))
            validatePos(grid, (y, (x+i).int16, Right))

    elif d == Left or d == Right:
        for i in 1..3:
            validatePos(grid, ((y-i).int16, x, Up))
            validatePos(grid, ((y+i).int16, x, Down))

proc cost*(grid: MyG, a: MyN, b: MyN): int =
    if a[0] == b[0] and a[1] == b[1]:
        return 0

    for i in min(a[0],b[0])..max(a[0],b[0]):
        for j in min(a[1],b[1])..max(b[1],a[1]):
            if i != a[0] or j != a[1]:
                result += grid[i][j]

proc heuristic*(grid: MyG, a: MyN, b: MyN): int =
    return abs(a[0] - b[0]) + abs(a[1] - b[1])


proc part1(s: string): string = 
    var r = parseInput(s)

    var start = (0.int16, 0.int16, Down)
    var dest = ((r.len - 1).int16, (r[0].len - 1).int16, Right)
    var pcost = 0

    var currentPos = start
    for pt in path[MyG, MyN, int](r, start, dest):
        if currentPos != pt:
            pcost += r.cost(currentPos, pt)
            currentPos = pt

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

    if d == Up or d == Down:
        for i in 4..10:
            validatePos(grid.MyG, (y, (x-i).int16, Left))
            validatePos(grid.MyG, (y, (x+i).int16, Right))

    elif d == Left or d == Right:
        for i in 4..10:
            validatePos(grid.MyG, ((y-i).int16, x, Up))
            validatePos(grid.MyG, ((y+i).int16, x, Down))

proc part2(s: string): string = 
    var r = parseInput(s)

    var start: MyN = (0, 0, Down)
    var dest: MyN = ((r.len - 1).int16, (r[0].len - 1).int16, Right)
    var pcost = 0

    var currentPos = start
    for pt in path[MyG2, MyN, int](r.MyG2, start, dest):
        if currentPos != pt:
            pcost += r.cost(currentPos, pt)
            currentPos = pt

    return $pcost

run(2023, 17, part1, part2)