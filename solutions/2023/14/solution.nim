import ../../../toolbox

proc parseInput(s: string): seq[string] = 
    return s.strip.split("\n")

proc tiltNorth(s: var seq[string]) =
    var isUpdate = true
    while isUpdate:
        isUpdate = false
        for i in 1..<s.len:
            for j in 0..<s[i].len:
                if s[i][j] == 'O' and s[i-1][j] == '.':
                    s[i-1][j] = 'O'
                    s[i][j] = '.'
                    isUpdate = true

proc tiltWest(s: var seq[string]) =
    var isUpdate = true
    while isUpdate:
        isUpdate = false
        for i in 0..<s.len:
            for j in 1..<s[i].len:
                if s[i][j] == 'O' and s[i][j-1] == '.':
                    s[i][j-1] = 'O'
                    s[i][j] = '.'
                    isUpdate = true

proc tiltSouth(s: var seq[string]) =
    var isUpdate = true
    while isUpdate:
        isUpdate = false
        for i in countdown(s.len-2, 0):
            for j in 0..<s[i].len:
                if s[i][j] == 'O' and s[i+1][j] == '.':
                    s[i+1][j] = 'O'
                    s[i][j] = '.'
                    isUpdate = true


proc tiltEast(s: var seq[string]) =
    var isUpdate = true
    while isUpdate:
        isUpdate = false
        for i in 0..<s.len:
            for j in countdown(s[0].len-2, 0):
                if s[i][j] == 'O' and s[i][j+1] == '.':
                    s[i][j+1] = 'O'
                    s[i][j] = '.'
                    isUpdate = true

var cycleFinder: Table[seq[string], int]
var callCounter = 0
proc cycle(s: var seq[string]): int =
    if s in cycleFinder:
        result = callCounter - cycleFinder[s]
    else:
        result = -1
    cycleFinder[s] = callCounter

    s.tiltNorth()
    s.tiltWest()
    s.tiltSouth()
    s.tiltEast()
    
    inc callCounter


proc part1(s: string): string = 
    var r = parseInput(s)
    r.tiltNorth()

    var res = 0
    for i in 0..<r.len:
        for j in 0..<r[i].len:
            if r[i][j] == 'O':
                res += r.len - i

    return $res


proc part2(s: string): string = 
    var r = parseInput(s)
    var cycleLength = 0

    for _ in 0..<1000000000:
        var c = cycle(r)
        if c != -1:
            cycleLength = c
            break

    var remaining = 1000000000 - callCounter
    # how many transformation are left to apply?
    var toApply = remaining mod cycleLength

    for _ in 0..<toApply:
        discard cycle(r)

    var res = 0
    for i in 0..<r.len:
        for j in 0..<r[i].len:
            if r[i][j] == 'O':
                res += r.len - i

    return $res


run(2023, 14, part1, part2)