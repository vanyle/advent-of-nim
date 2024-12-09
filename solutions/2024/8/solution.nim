import ../../../toolbox

proc parseInput(s: string): seq[string] = 
    return s.strip.split("\n")

proc inBounds(p: (int, int), map: seq[string]): bool =
    return p[0] >= 0 and p[1] >= 0 and p[0] < map.len and p[1] < map[0].len

proc getAntennaPositions(map: seq[string]): Table[char, seq[(int, int)]] =
    for i in 0..<map.len:
        for j in 0..<map[i].len:
            if map[i][j] != '.':
                let freq = map[i][j]
                if freq in result:
                    result[freq].add((i,j))
                else:
                    result[freq] = @[(i,j)]

proc part1(s: string): string = 
    var map = parseInput(s)

    var antiNodePositions: HashSet[(int, int)]
    var antennas = getAntennaPositions(map)

    for freq, positions in antennas:
        for p1 in positions:
            for p2 in positions:
                if p1 != p2:
                    let node1 = (2*p2[0] - p1[0], 2*p2[1] - p1[1])
                    let node2 = (2*p1[0] - p2[0], 2*p1[1] - p2[1])
                    if inBounds(node1, map):
                        antiNodePositions.incl(node1)
                    if inBounds(node2, map):
                        antiNodePositions.incl(node2)

    return $(antiNodePositions.len)




proc part2(s: string): string = 
    var map = parseInput(s)

    var antiNodePositions: HashSet[(int, int)]
    var antennas = getAntennaPositions(map)

    for freq, positions in antennas:
        for p1 in positions:
            for p2 in positions:
                if p1 != p2:
                    var node1 = (p2[0], p2[1])
                    var node2 = (p1[0], p1[1])
                    while inBounds(node1, map):
                        antiNodePositions.incl(node1)
                        node1[0] += p2[0] - p1[0]
                        node1[1] += p2[1] - p1[1]

                    while inBounds(node2, map):
                        antiNodePositions.incl(node2)
                        node2[0] += p1[0] - p2[0]
                        node2[1] += p1[1] - p2[1]

    return $(antiNodePositions.len)


run(2024, 8, part1, part2)