import ../../../toolbox

proc parseInput(s: string): seq[string] = 
    return s.strip.split("\n")

type Dir = enum
    LEFT = 0,
    DOWN = 1,
    RIGHT = 2,
    UP = 3

proc dirTuple(d: Dir): (int, int) =
    case d:
    of LEFT: return (0, -1)
    of RIGHT: return (0, 1)
    of UP: return (-1, 0)
    of DOWN: return (1, 0)

iterator processLightBit(lpos: (int, int), level: seq[string], d: Dir): (int, int, Dir) =
    # Returns the position of light to change, if needed.
    let c = level[lpos[0]][lpos[1]]
    var lightPos = lpos
    var ldir = dirTuple(d)
    if c == '.':
        lightPos[0] += ldir[0]
        lightPos[1] += ldir[1]
        yield (lightPos[0], lightPos[1], d)
    elif c == '/' or c == '\\':
        var newDir = d
        if c == '/':
            if d == LEFT: newDir = DOWN
            elif d == DOWN: newDir = LEFT
            elif d == UP: newDir = RIGHT
            elif d == RIGHT: newDir = UP
        elif c == '\\':
            if d == LEFT: newDir = UP
            elif d == UP: newDir = LEFT
            elif d == DOWN: newDir = RIGHT
            elif d == RIGHT: newDir = DOWN  

        ldir = dirTuple(newDir)
        lightPos[0] += ldir[0]
        lightPos[1] += ldir[1]
        yield (lightPos[0], lightPos[1], newDir)

    elif c == '-':
        if d == LEFT or d == RIGHT:
            lightPos[0] += ldir[0]
            lightPos[1] += ldir[1]
            yield (lightPos[0], lightPos[1], d)   
        else:
            yield (lightPos[0], lightPos[1]-1, LEFT)
            yield (lightPos[0], lightPos[1]+1, RIGHT)
    elif c == '|':
        if d == UP or d == DOWN:
            lightPos[0] += ldir[0]
            lightPos[1] += ldir[1]
            yield (lightPos[0], lightPos[1], d)  
        else:
            yield (lightPos[0]+1, lightPos[1], DOWN)
            yield (lightPos[0]-1, lightPos[1], UP)

proc updateState(lstate: var seq[seq[set[Dir]]], y: int, x: int, d: Dir): bool =
    # Check for out of bounds.
    if y < 0 or y >= lstate.len: return false
    if x < 0 or x >= lstate[y].len: return false

    if d in lstate[y][x]: return false
    lstate[y][x].incl d
    return true

var lstate: seq[seq[set[Dir]]] = newSeq[seq[set[Dir]]](0)
proc simulateLight(level: seq[string], entryi = 0, entryj = 0, entryd: Dir = Right): seq[seq[set[Dir]]] =

    # Store light dir of every tile
    
    # Zero out lstate:
    if level.len != lstate.len:
        lstate = newSeq[seq[set[Dir]]](level.len)
        for i in 0..<level.len:
            lstate[i] = newSeq[set[Dir]](level[i].len)
    else:
        for i in 0..<lstate.len:
            for j in 0..<lstate[i].len:
                lstate[i][j] = {}

    lstate[entryi][entryj] = {entryd} # top-right, going right.
    var changeOccured = true

    # Update lstate until a steady state is reached.
    var s = 0
    while changeOccured:
        inc s
        changeOccured = false
        for i in 0..<lstate.len:
            for j in 0..<lstate[i].len:
                let rays = lstate[i][j]
                for r in rays:
                    for lbit in processLightBit((i,j), level, r):
                        var (y,x,newd) = lbit
                        if lstate.updateState(y,x,newd):
                            changeOccured = true

    return lstate

proc energized(lstate: seq[seq[set[Dir]]]): int =
    for i in 0..<lstate.len:
        for j in 0..<lstate[i].len:
            if lstate[i][j].len > 0:
                inc result

proc part1(s: string): string = 
    var r = parseInput(s)
    var lstate = simulateLight(r)

    return $energized(lstate)

proc part2(s: string): string = 
    var r = parseInput(s)

    var menergy = 0

    for i in 0..<r.len:
        var lstate = simulateLight(r, i, 0, Right)
        menergy = max(menergy, energized(lstate))

        lstate = simulateLight(r, i, r.len-1, Left)
        menergy = max(menergy, energized(lstate))

    for j in 0..<r[0].len:
        var lstate = simulateLight(r, 0, j, Down)
        menergy = max(menergy, energized(lstate))

        lstate = simulateLight(r, r[0].len-1, j, Up)
        menergy = max(menergy, energized(lstate))

    return $menergy



run(2023, 16, part1, part2)