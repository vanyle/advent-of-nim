import ../../../toolbox

proc parseInput(s: string): seq[string] = 
    return s.strip.split(",")

proc hashS(s: string): int =
    var h = 0
    for j in 0..<s.len:
        var ascii = cast[int](s[j])
        h += ascii
        h = h * 17
        h = h mod 256
    return h

proc part1(s: string): string = 
    var r = parseInput(s)

    var res = 0
    for i in 0..<r.len:
        var s = r[i]
        res += hashS(r[i])

    return $res


proc part2(s: string): string = 
    var r = parseInput(s)
    var boxes: seq[OrderedTable[string, int]] = newSeq[OrderedTable[string, int]](256)

    for i in 0..<r.len:
        var s = r[i]
        var label = ""
        var rest = ""
        if "-" in s:
            var spli = s.split("-",1)
            label = spli[0]
            rest = spli[1]
        elif "=" in s:
            var spli = s.split("=",1)
            label = spli[0]
            rest = spli[1]

        var boxId = hashS(label)
        if "=" in s:
            var focLength = parseInt(rest)
            boxes[boxId][label] = focLength
        elif "-" in s:
            boxes[boxId].del(label)

    var res = 0
    for b in 0..<256:
        var i = 1
        for k,v in boxes[b]:
            var power = (b+1) * i * v
            res += power
            inc i

    return $res


run(2023, 15, part1, part2)