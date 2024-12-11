import ../../../toolbox

proc parseInput(s: string): seq[int] = 
    return s.ints()

# memoize nextArrangement.
proc nextArrangement(stones: Table[int, int]): Table[int, int] =
    for stone, stoneCount in stones:
        if stone == 0:
            if 1 in result:
                result[1] += stoneCount
            else:
                result[1] = stoneCount
        else:
            var sstone = $stone
            if sstone.len mod 2 == 0:
                let n1 = parseUnsignedInt(sstone[0..<(sstone.len div 2)])
                let n2 = parseUnsignedInt(sstone[(sstone.len div 2)..<sstone.len])
                if n1 in result:
                    result[n1] += stoneCount
                else:
                    result[n1] = stoneCount
                if n2 in result:
                    result[n2] += stoneCount
                else:
                    result[n2] = stoneCount
            else:
                let n = stone * 2024
                if n in result:
                    result[n] += stoneCount
                else:
                    result[n] = stoneCount



proc part1(s: string): string = 
    var stones = parseInput(s)
    
    var t: Table[int, int]
    for s in stones:
        if s in t:
            inc t[s]
        else:
            t[s] = 1


    for i in 0..<25:
        t = nextArrangement(t)

    var sum = 0
    for _, count in t:
        sum += count

    return $sum



proc part2(s: string): string = 
    var stones = parseInput(s)

    var t: Table[int, int]
    for s in stones:
        if s in t:
            inc t[s]
        else:
            t[s] = 1

    for i in 0..<75:
        t = nextArrangement(t)

    var sum = 0
    for _, count in t:
        sum += count

    return $sum


run(2024, 11, part1, part2)