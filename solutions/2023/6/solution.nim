import ../../../toolbox

from math import sqrt, floor, ceil

proc isDigi(c: char): bool = c >= '0' and c <= '9'

proc parseInput(s: string, idx: int): (seq[int], int) = 
    var r: seq[int] = @[]
    var i = idx
    var n = 0
    while i < s.len and s[i] != '\n':
        if isDigi(s[i]):
            n *= 10
            n += cast[int](s[i]) - cast[int]('0')
        elif n != 0:
            r.add n
            n = 0
        inc i
    if n != 0:
        r.add n
    return (r, i)

proc part1(s: string): string = 
    var (times, idx) = parseInput(s, 0)
    var (distances, _) = parseInput(s, idx+1)
    
    var res = 1

    for i in 0..<times.len:
        var delta = sqrt((times[i]*times[i] - 4 * distances[i]).float)
        var x1 = ((times[i].float + delta) / 2).floor
        var x2 = ((times[i].float - delta) / 2).ceil

        res *= (x1 - x2 + 1).int

    return $res

proc parseInput2(s: string, idx: int): (int, int) = 
    var i = idx
    var n = 0
    while i < s.len and s[i] != '\n':
        if isDigi(s[i]):
            n *= 10
            n += cast[int](s[i]) - cast[int]('0')
        inc i
    return (n, i)

proc part2(s: string): string = 
    let (time, idx) = parseInput2(s, 0)
    let (distance, _) = parseInput2(s, idx+1)

    var delta = sqrt((time*time - 4 * distance).float)
    var x1 = ((time.float + delta) / 2).floor
    var x2 = ((time.float - delta) / 2).ceil
    var ways = (x1 - x2 + 1).int

    return $ways


run(2023, 6, part1, part2)