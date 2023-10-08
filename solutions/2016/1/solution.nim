import ../../../toolbox

proc parseInput(s: string): seq[string] = 
    return s
        .strip
        .split(",")
        .map((x) => x.strip)

proc part1(s: string): string = 
    var r = parseInput(s)
    var px = 0
    var py = 0
    var dir = 0
    # N => E => S => W
    # 0 => 1 => 2 => 3
    # R => dir++

    for i in r:
        if i[0] == 'L':
            dec dir
        if i[0] == 'R':
            inc dir
        dir = (dir + 4) mod 4
        if dir == 0:
            py -= parseInt($i[1..<i.len])
        if dir == 2:
            py += parseInt($i[1..<i.len])
        if dir == 1:
            px += parseInt($i[1..<i.len])
        if dir == 3:
            px -= parseInt($i[1..<i.len])

    echo px," ; ",py
    return $(abs(px)+abs(py))




proc part2(s: string): string = 
    var r = parseInput(s)


run(2016, 1, part1, part2)