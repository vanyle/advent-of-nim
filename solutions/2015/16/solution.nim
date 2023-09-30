import ../../../toolbox


proc parseInput(s: string): Table[int, (string, int, string, int, string, int)] =
    # Might do a template for this ??
    var lines = s.strip.splitLines
    for l in lines:
        var s1,s2,s3: string
        var id,n1,n2,n3: int
        if scanf(l,
            "Sue $i: $w: $i, $w: $i, $w: $i",
            id, s1, n1, s2, n2, s3, n3
            ):
            result[id] = (s1, n1, s2, n2, s3, n3)

var part1Ready* = true
proc part1(s: string): string = 
    var input = parseInput(s)

    var known: Table[string, int] = {
        "children": 3,
        "cats": 7,
        "samoyeds": 2,
        "pomeranians": 3,
        "akitas": 0,
        "vizslas": 0,
        "goldfish": 5,
        "trees": 3,
        "cars": 2,
        "perfumes": 1,
    }.toTable

    for id, vals in input:
        if known[vals[0]] == vals[1] and
            known[vals[2]] == vals[3] and
            known[vals[4]] == vals[5]:
                return $id

    return "-1"



var part2Ready* = true
proc part2(s: string): string = 
    var input = parseInput(s)

    var reading: Table[string, int] = {
        "children": 3,
        "cats": 7,
        "samoyeds": 2,
        "pomeranians": 3,
        "akitas": 0,
        "vizslas": 0,
        "goldfish": 5,
        "trees": 3,
        "cars": 2,
        "perfumes": 1,
    }.toTable

    for id, vals in input:
        var vars = [vals[0], vals[2], vals[4]]
        var valu = [vals[1], vals[3], vals[5]]
        var isOk = true

        for j in 0..<vars.len:
            if vars[j] == "cats" or vars[j] == "trees":
                if not (valu[j] > reading[vars[j]]):
                    isOk = false
                    break
            elif vars[j] == "pomeranians" or vars[j] == "goldfish":
                if not (valu[j] < reading[vars[j]]):
                    isOk = false
                    break
            else:
                if not (valu[j] == reading[vars[j]]):
                    isOk = false
                    break
        if isOk:
            return $id


    return "-1"

run(2015, 16, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)