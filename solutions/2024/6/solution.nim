import ../../../toolbox

proc parseInput(s: string): seq[string] = 
    return s.strip.split("\n")

proc getGuardPos(s: seq[string]): (int, int) =
    for i in 0..<s.len:
        for j in 0..<s[i].len:
            if s[i][j] == '^':
                return (j,i)
    return (-1,-1)

proc rotDir(d: (int,int)): (int, int) =
    # Turn right 90° (multiply by -i)
    # (0, -1) -> (1, 0) -> (0, 1) -> (-1, 0)
    return (-d[1], d[0])

proc rotDir(d: (int8,int8)): (int8, int8) =
    # Turn right 90° (multiply by -i)
    # (0, -1) -> (1, 0) -> (0, 1) -> (-1, 0)
    return (-d[1], d[0])

proc part1(s: string): string = 
    # fyi map size is 130x130
    var inp = parseInput(s) # inp[y][x]
    var currPos = getGuardPos(inp)
    var guardDir = (0, -1) # x,y

    var guardPos: HashSet[(int, int)]

    while currPos[0] >= 0 and currPos[1] >= 0 and currPos[1] < inp.len and currPos[0] < inp[0].len:
        if inp[currPos[1]][currPos[0]] == '#':
            currPos[0] -= guardDir[0]
            currPos[1] -= guardDir[1]
            guardDir = rotDir(guardDir)

        guardPos.incl currPos
        currPos[0] += guardDir[0]
        currPos[1] += guardDir[1]


    return $guardPos.len


proc makesLoop(map: var seq[string], obstacle: (int16, int16), startGuardPos: (int16, int16)): bool =
    map[obstacle[1]][obstacle[0]] = '#'
    var guardDir = (0.int8, -1.int8) # x,y
    var currPos = startGuardPos
    var guardPos: HashSet[(int16, int16, int8, int8)]

    while currPos[0] >= 0.int16 and currPos[1] >= 0.int16 and currPos[1] < map.len.int16 and currPos[0] < map[0].len.int16:
        if map[currPos[1]][currPos[0]] == '#':
            currPos[0] -= guardDir[0]
            currPos[1] -= guardDir[1]
            guardDir = rotDir(guardDir)

        let storedPos = (currPos[0],currPos[1], guardDir[0], guardDir[1])
        if storedPos in guardPos:
            map[obstacle[1]][obstacle[0]] = '.'
            return true
        guardPos.incl storedPos

        currPos[0] += guardDir[0]
        currPos[1] += guardDir[1]

    map[obstacle[1]][obstacle[0]] = '.'
    return false


proc part2(s: string): string = 
    var inp = parseInput(s) # inp[y][x]
    let startPos = getGuardPos(inp)
    var currPos = startPos
    var guardDir = (0, -1) # x,y

    var guardPos: HashSet[(int16, int16)]

    while currPos[0] >= 0 and currPos[1] >= 0 and currPos[1] < inp.len and currPos[0] < inp[0].len:
        if inp[currPos[1]][currPos[0]] == '#':
            currPos[0] -= guardDir[0]
            currPos[1] -= guardDir[1]
            guardDir = rotDir(guardDir)

        guardPos.incl (currPos[0].int16,currPos[1].int16)
        currPos[0] += guardDir[0]
        currPos[1] += guardDir[1]

    var loopCount = 0
    for p in guardPos:
        if p[0] == startPos[0] and p[1] == startPos[1]:
            continue
        if makesLoop(inp, p, (startPos[0].int16, startPos[1].int16)):
            inc loopCount

    return $loopCount



run(2024, 6, part1, part2)