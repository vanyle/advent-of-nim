import ../../../toolbox

proc parseInput(s: string): seq[string] = 
    return s.strip.split("\n")

proc isColumnEmpty(r: seq[string], col: int): bool =
    for i in 0..<r.len:
        if r[i][col] != '.':
            return false
    return true

proc part1(s: string): string = 
    var r = parseInput(s)
    # expand the space ...
    var emptyLine = ""
    for j in 0..<r[0].len:
        emptyLine.add "." 

    # add empty columns
    block:
        var i = 0
        while i < r[0].len:
            if r.isColumnEmpty(i):
                for j in 0..<r.len:
                    r[j].insert(".", i + 1)
                inc i
            inc i

    # add empty lines
    block:
        var i = 0
        while i < r.len:
            if "#" notin r[i]:
                r.insert(emptyLine, i + 1)
                inc i
            inc i

    var galaxyPos: seq[(int, int)] = @[]

    for i in 0..<r.len:
        for j in 0..<r[i].len:
            if r[i][j] == '#':
                galaxyPos.add((i,j))

    var s = 0
    for i in 0..<galaxyPos.len:
        for j in 0..<i:
            var p1 = galaxyPos[i]
            var p2 = galaxyPos[j]
            var d = abs(p1[0] - p2[0]) + abs(p1[1] - p2[1])
            if i == 6 and j == 0:
                echo p1, " ; ",p2, " => ",d
            s += d

    return $s


proc part2(s: string): string = 
    var r = parseInput(s)

    var galaxyPos: seq[(int, int)] = @[]

    for i in 0..<r.len:
        for j in 0..<r[i].len:
            if r[i][j] == '#':
                galaxyPos.add((i,j))


    var emptyCol = @[0]
    block:
        for i in 0..<r[0].len:
            if r.isColumnEmpty(i):
                emptyCol.add(emptyCol[emptyCol.len-1] + 1)
            else:
                emptyCol.add(emptyCol[emptyCol.len-1])

    var emptyLine = @[0]
    block:
        for i in 0..<r.len:
            if "#" notin r[i]:
                emptyLine.add(emptyLine[emptyLine.len-1] + 1)
            else:
                emptyLine.add(emptyLine[emptyLine.len-1])

    const offsetAmount = 1000000 - 1 # lensing

    echo emptyCol
    echo emptyLine

    var s = 0
    for i in 0..<galaxyPos.len:
        for j in 0..<i:
            var p1 = galaxyPos[i]
            var p2 = galaxyPos[j]

            var p10 = p1[0] + emptyLine[p1[0]] * offsetAmount
            var p11 = p1[1] + emptyCol[p1[1]] * offsetAmount
            var p20 = p2[0] + emptyLine[p2[0]] * offsetAmount
            var p21 = p2[1] + emptyCol[p2[1]] * offsetAmount

            var d = abs(p10 - p20) + abs(p11 - p21)
            s += d

    return $s


run(2023, 11, part1, part2)