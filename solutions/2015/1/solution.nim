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

var part2Ready* = false
proc part2(s: string): string =
    discard

run(2015, 1, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)
