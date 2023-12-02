import ../../../toolbox

var maxCubes = {
    "red": 12,
    "green": 13,
    "blue": 14
}.toTable

proc parseInput(s: string): seq[seq[Table[string, int]]] = 
    var l = s.strip().split("\n")

    for line in l:
        var game = line.split(":")[1]
        var draws = game.strip.split(";")
        var cgame: seq[Table[string,int]]
        for d in draws:
            var cc = d.strip.split(",")
            var tt: Table[string, int]
            for el in cc:
                var pair = el.strip.split(" ",2)
                tt[pair[1]] = parseInt(pair[0])
            cgame.add(tt)
        result.add cgame


proc part1(s: string): string = 
    var r = parseInput(s)

    var validIds = 0
    for i in 0..<r.len:
        var game = r[i]
        var isGameValid = true
        for draws in game:
            var isDrawValid = true
            for color, count in draws:
                if maxCubes[color] < count:
                    isDrawValid = false
                    break
            if not isDrawValid:
                isGameValid = false
                break
        if isGameValid:
            validIds += (i+1)

    return $validIds



proc part2(s: string): string = 
    var r = parseInput(s)
    var s = 0

    for i in 0..<r.len:
        var game = r[i]
        var minVals = {
            "red": 0,
            "green": 0,
            "blue": 0
        }.toTable

        for draws in game:
            for color, count in draws:
                minVals[color] = max(minVals[color], count)

        var power = minVals["red"] * minVals["green"] *  minVals["blue"]
        s += power
    return $s


run(2023, 2, part1, part2)