import ../../../toolbox

import sets

var part1Ready* = true
proc part1(s: string): string = 
    var visited: HashSet[(int,int)]
    var px = 0
    var py = 0

    for i in s:
        visited.incl((px,py))
        if i == 'v': dec py
        elif i == '^': inc py
        elif i == '>': inc px
        elif i == '<': dec px

    return $visited.len

var part2Ready* = true
proc part2(s: string): string = 
    var visited: HashSet[(int,int)]
    var px = [0, 0]
    var py = [0, 0]

    for idx in 0..<s.len:
        var i = s[idx]
        visited.incl((px[0],py[0]))
        visited.incl((px[1],py[1]))

        if i == 'v': dec py[idx mod 2]
        elif i == '^': inc py[idx mod 2]
        elif i == '>': inc px[idx mod 2]
        elif i == '<': dec px[idx mod 2]

    visited.incl((px[0],py[0]))
    visited.incl((px[1],py[1]))

    return $visited.len

run(2015, 3, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)