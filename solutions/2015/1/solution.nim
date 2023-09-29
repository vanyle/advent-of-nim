import ../../../toolbox

var part1Ready* = true
proc part1(s: string): string =
    var r = 0
    for i in s:
        if i == '(':
            inc r
        elif i == ')':
            dec r
    return $r

var part2Ready* = true
proc part2(s: string): string =
    var r = 0
    for i in 0..<s.len:
        if s[i] == '(':
            inc r
        elif s[i] == ')':
            dec r
        if r == -1:
            return $(i+1)
    return "-1"

run(2015, 1, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)
