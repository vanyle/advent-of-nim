import ../../../toolbox

proc nextCode(s: int): int =
    return (s * 252533) mod 33554393

proc posToInt(x,y: int): int =
    # start by computing the number at
    # (x+y-1, 0)
    
    var xy0 = (x+y-1) * (x+y) div 2
    return xy0 - y + 1

proc parseInput(s: string): seq[int] = 
    return ints(s)

proc part1(s: string): string = 
    var r = parseInput(s)
    var n = posToInt(r[1],r[0])

    echo "Code #",n

    var s = 20151125
    for i in 1..<n:
        s = nextCode(s)
    return $s


proc part2(s: string): string = 
    return $0 # Merry Christmas !

run(2015, 25, part1, part2)