import ../../../toolbox

proc parseInput(s: string): seq[string] = 
    return s.strip.split("\n")

proc isEqualVert(arr: seq[string], col: int, line: int, s: static[string]): bool =
    for i in 0..<s.len:
        if arr[i+line][col] != s[i]: return false
    return true

proc isEqualD(arr: seq[string], col: int, line: int, s: static[string], sgn: static[int]=1): bool =
    for i in 0..<s.len:
        if getArr(arr, col+i*sgn, i+line, '.') != s[i]: return false
    return true


proc part1(s: string): string = 
    var lines = parseInput(s)
    var clen = lines[0].len
    var counter = 0

    # Horizontal
    for j in 0..<lines.len:
        let l = lines[j]
        for i in 0..<(l.len-3):
            if isEqual(l[i..<(i+4)], "XMAS") or isEqual(l[i..<(i+4)], "SAMX"):
                inc counter
    # Vertical
    for j in 0..<clen:
        for i in 0..<(lines.len-3):
            if isEqualVert(lines, j, i, "XMAS") or isEqualVert(lines, j, i, "SAMX"):
                inc counter

    # Diag
    for j in 0..<(lines.len-3):
        for i in 0..<lines[j].len:
            if isEqualD(lines, i, j, "XMAS") or isEqualD(lines, i, j, "SAMX"):
                inc counter
            if isEqualD(lines, i, j, "XMAS", -1) or isEqualD(lines, i, j, "SAMX", -1):
                inc counter

    return $counter

proc isXdashMAS(arr: seq[string], i: int, j: int): bool =
    # (col, line) is the center of the X.
    if arr[i][j] != 'A': return false
    if bToI8(arr[i+1][j+1] == 'M') + bToI8(arr[i-1][j-1] == 'M') + bToI8(arr[i+1][j-1] == 'M') + bToI8(arr[i-1][j+1] == 'M') != 2:
        return false
    if bToI8(arr[i+1][j+1] == 'S') + bToI8(arr[i-1][j-1] == 'S') + bToI8(arr[i+1][j-1] == 'S') + bToI8(arr[i-1][j+1] == 'S') != 2:
        return false
    return arr[i+1][j+1] != arr[i-1][j-1]


proc part2(s: string): string = 
    var lines = parseInput(s)
    var counter = 0

    for j in 1..<(lines.len-1):
        for i in 1..<(lines[j].len-1):
            if isXdashMAS(lines,i,j):
                inc counter
    return $counter



run(2024, 4, part1, part2)