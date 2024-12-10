import ../../../toolbox

proc parseInput(s: string): seq[string] = 
    return s.strip.split("\n")

iterator neighFour*(a: openarray[string], y,x: int): (char, (int, int)) =
    if x+1 < a[y].len:
        yield (a[y][x+1], (y, x+1))
    if x-1 >= 0:
        yield (a[y][x-1], (y, x-1))
    if y-1 >= 0:
        yield (a[y-1][x], (y-1, x))
    if y+1 < a.len:
        yield (a[y+1][x], (y+1, x))

proc reachableNines(map: seq[string], pos: (int, int)): HashSet[(int,int)] =
    let v = map[pos[0]][pos[1]]
    if v == '9':
        return [pos].toHashSet

    for val, pos in neighFour(map, pos[0], pos[1]):
        if toDigit(val) == toDigit(v)+1:
            result = result + reachableNines(map, pos)


proc countPaths(map: seq[string], pos: (int, int)): int =
    let v = map[pos[0]][pos[1]]
    if v == '9':
        return 1

    for val, pos in neighFour(map, pos[0], pos[1]):
        if toDigit(val) == toDigit(v)+1:
            result += countPaths(map, pos)


proc part1(s: string): string = 
    var r = parseInput(s)

    var s = 0
    for i in 0..<r.len:
        for j in 0..<r[i].len:
            if r[i][j] == '0':
                var score = r.reachableNines((i,j)).len
                s += score
    return $s



proc part2(s: string): string = 
    var r = parseInput(s)

    var s = 0
    for i in 0..<r.len:
        for j in 0..<r[i].len:
            if r[i][j] == '0':
                var score = r.countPaths((i,j))
                s += score
    return $s


run(2024, 10, part1, part2)