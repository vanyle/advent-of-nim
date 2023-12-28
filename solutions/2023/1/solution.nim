import ../../../toolbox

var sdigits = @["zero","one","two","three","four","five","six","seven","eight","nine"]

proc parseInput(s: string): seq[seq[int]] = 
    var c = s.strip.split("\n")
    var r: seq[seq[int]] = @[]
    for i in 0..<c.len:
        var t: seq[int] = @[]
        for j in 0..<c[i].len:
            if c[i][j].isDigitFast:
                t.add parseInt($c[i][j])
        r.add t
    return r

proc parseInput2(s: string): seq[seq[int]] =
    var c = s.strip.split("\n")
    var r: seq[seq[int]] = @[]
    for i in 0..<c.len:
        var t: seq[int] = @[]
        var j = 0
        while j < c[i].len:
            if c[i][j].isDigitFast:
                t.add parseInt($c[i][j])
            else:
                for k in 0..<sdigits.len:
                    var dd = sdigits[k]
                    if c[i].len >= (j+dd.len):
                        if c[i][j..<(j+dd.len)] == dd:
                            t.add k
                            # j += dd.len - 1
                            break
            inc j

        r.add t
    return r

proc part1(s: string): string = 
    var r = parseInput(s)

    var cv = 0
    for l in r:
        if l.len == 0: continue
        cv += l[0]*10 + l[l.len - 1]

    return $(cv)


proc part2(s: string): string = 
    var r = parseInput2(s)

    var cv = 0
    for l in r:
        cv += l[0]*10 + l[l.len - 1]

    return $(cv)


run(2023, 1, part1, part2)