import ../../../toolbox


proc parseInput(s: string): seq[seq[char]] = 
    return s.strip.split("\n").map(x => x.map(y => y))

proc isNextTo(a: seq[int], b: int): bool =
    for i in a:
        if abs(b-i) <= 1: return true
    return false
 
proc part1(s: string): string = 
    var r = parseInput(s)

    var ipos: seq[(int,int)] = @[]
    for i in 0..<r.len:
        for j in 0..<r[i].len:
            if not isDigit(r[i][j]) and r[i][j] != '.':
                for iline in -1..1:
                    if i + iline < 0 or i + iline >= r.len: continue
                    var tmppos: seq[int] = @[]
                    for icol in -1..1:
                        if icol == 0 and iline == 0: continue
                        if j + icol < 0 or j + icol >= r[i + iline].len: continue
                        var element = r[i+iline][j+icol]
                        var p = (i+iline, j+icol)
                        if isDigit(element):
                            if not isNextTo(tmppos, p[1]):
                                ipos.add(p)
                            tmppos.add(p[1])

    var digits: seq[int] = @[]
    for p in ipos:
        # grow the digit left and right.
        var si = p[1]
        var ei = p[1]
        while si >= 0 and isDigit(r[p[0]][si]):
            dec si
        inc si

        while ei < r[p[0]].len and isDigit(r[p[0]][ei]):
            inc ei
        dec ei

        digits.add(parseInt(r[p[0]][si..ei].join("")))


    return $digits.foldl(a+b)



proc part2(s: string): string = 
    var r = parseInput(s)

    var ipos: seq[seq[(int,int)]] = @[]
    for i in 0..<r.len:
        for j in 0..<r[i].len:
            if not isDigit(r[i][j]) and r[i][j] == '*':
                var neigh: seq[(int,int)] = @[]
                for iline in -1..1:
                    if i + iline < 0 or i + iline >= r.len: continue
                    var tmppos: seq[int] = @[]
                    for icol in -1..1:
                        if icol == 0 and iline == 0: continue
                        if j + icol < 0 or j + icol >= r[i + iline].len: continue
                        var element = r[i+iline][j+icol]
                        var p = (i+iline, j+icol)
                        if isDigit(element):
                            if not isNextTo(tmppos, p[1]):
                                neigh.add(p)
                            tmppos.add(p[1])
                if neigh.len == 2:
                    ipos.add(neigh)

    var toreturn = 0
    for partnums in ipos:
        var d: seq[int] = @[]
        for p in partnums:
            # grow the digit left and right.
            var si = p[1]
            var ei = p[1]
            while si >= 0 and isDigit(r[p[0]][si]):
                dec si
            inc si

            while ei < r[p[0]].len and isDigit(r[p[0]][ei]):
                inc ei
            dec ei

            d.add(parseInt(r[p[0]][si..ei].join("")))

        toreturn += d[0] * d[1]

    return $toreturn



run(2023, 3, part1, part2)