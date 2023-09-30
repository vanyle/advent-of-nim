import ../../../toolbox

proc corner(i,j: int): bool =
    return (i == 0 and j == 0) or (i == 0 and j == 99) or
        (i == 99 and j == 0) or (i == 99 and j == 99)

proc getp(stuck: bool, g: seq[string], i,j: int): char =
    if stuck and corner(i,j):
        return '#'
    if i >= 0 and j >= 0 and i < 100 and j < 100:
        return g[i][j]
    return '.'

proc step(g: seq[string], stuck: bool = false): seq[string] =
    var newGrid: seq[string] = g

    for i in 0..<g.len:
        for j in 0..<g[i].len:
            if stuck and corner(i,j):
                continue

            var onN = 0
            onN += ( if getp(stuck, g,i+1,j+1) == '#': 1 else: 0)
            onN += ( if getp(stuck, g,i,j+1) == '#': 1 else: 0)
            onN += ( if getp(stuck, g,i-1,j+1) == '#': 1 else: 0)
            onN += ( if getp(stuck, g,i+1,j-1) == '#': 1 else: 0)
            onN += ( if getp(stuck, g,i,j-1) == '#': 1 else: 0)
            onN += ( if getp(stuck, g,i-1,j-1) == '#': 1 else: 0)
            onN += ( if getp(stuck, g,i+1,j) == '#': 1 else: 0)
            onN += ( if getp(stuck, g,i-1,j) == '#': 1 else: 0)

            if g[i][j] == '#':
                if onN == 2 or onN == 3:
                    newGrid[i][j] = '#'
                else:
                    newGrid[i][j] = '.'
            else:
                if onN == 3:
                    newGrid[i][j] = '#'
                else:
                    newGrid[i][j] = '.'
    return newGrid


var part1Ready* = true
proc part1(s: string): string = 
    var grid = s.strip.splitLines
    # # = on, . = off
    for i in 0..<100:
        grid = step(grid)

    var lightsOn = 0
    for i in 0..<grid.len:
        for j in 0..<grid[i].len:
            if grid[i][j] == '#': inc lightsOn

    return $lightsOn


var part2Ready* = true
proc part2(s: string): string = 
    var grid = s.strip.splitLines
    # # = on, . = off
    for i in 0..<100:
        grid = step(grid, true)

    var lightsOn = 0
    for i in 0..<grid.len:
        for j in 0..<grid[i].len:
            if getp(true,grid,i,j) == '#': inc lightsOn

    return $lightsOn

run(2015, 18, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)