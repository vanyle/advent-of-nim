import ../../../toolbox

import parseutils

iterator arraySplit(s: openarray[char], c: char): auto =
    var i = 0
    var prev = 0
    while i < s.len:
        if s[i] == c:
            yield s.toOpenArray(prev, i - 1)
            prev = i + 1 
        inc i
    yield s.toOpenArray(prev, s.len)

proc extractSecond(s: openarray[char]): int =
    for i in 0..<s.len:
        var d = cast[int](s[i]) - cast[int]('0')
        if d >= 0 and d <= 9:
            result *= 10
            result += d
        if s[i] == ' ':
            break

proc movePos(pos: (int,int), dir: char, amount: int = 1): (int, int) =
    if dir == 'U':
        return (pos[0]-amount, pos[1])
    elif dir == 'D':
        return (pos[0]+amount, pos[1])
    elif dir == 'R':
        return (pos[0], pos[1]+amount)
    elif dir == 'L':
        return (pos[0], pos[1]-amount)

proc part1(s: string): string = 
    var res = 0
    var boundary = 0
    var pos = (0,0)
    
    for l in s.arraySplit('\n'):
        var dir = l[0]
        var size = extractSecond(l.toOpenArray(2, l.len-1))
        var newpos = movePos(pos, dir, size)
        boundary += size
    
        res += pos[1]*newpos[0] - newpos[1]*pos[0]
        pos = newpos

    var area = res div 2
    var corrected = area + boundary div 2 + 1

    return $corrected.int

proc takeHex(s: openarray[char]): array[6,char] =
    var i = 0
    while s[i] != '(':
        inc i
    i += 2 # skip ( and #
    for j in 0..<6:
        result[j] = s[i+j]

proc part2(s: string): string = 
    var res = 0
    var boundary = 0
    var pos = (0,0)
    for l in s.arraySplit('\n'):
        var c = takeHex(l)
        var dirIndication = c[5]
        var dir = ' '
        var size = 0

        if dirIndication == '0':
            dir = 'R'
        elif dirIndication == '1':
            dir = 'D'
        elif dirIndication == '2':
            dir = 'L'
        elif dirIndication == '3':
            dir = 'U'
        discard parseHex(c.toOpenArray(0, 4), size)

        var newpos = movePos(pos, dir, size)
        boundary += size
    
        # Shoelace formula
        res += pos[1]*newpos[0] - newpos[1]*pos[0]
        pos = newpos

    var area = res div 2
    # pick's theorem, solve for "i", interior points.
    var corrected = area + boundary div 2 + 1

    return $corrected.int


run(2023, 18, part1, part2)