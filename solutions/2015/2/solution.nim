import ../../../toolbox

import strutils, sequtils

var part1Ready* = true
proc part1(s: string): string = 
    let lines = s.strip().splitLines
    var s = 0
    for l in lines:
        var dims = l.split("x",2).map(parseInt)

        let s1 = dims[0]*dims[1]
        let s2 = dims[1]*dims[2]
        let s3 = dims[2]*dims[0]

        s += s1*2
        s += s2*2
        s += s3*2
        s += min(s1,min(s2, s3))


    return $s

var part2Ready* = true
proc part2(s: string): string = 
    let lines = s.strip().splitLines
    var ribbon = 0
    for l in lines:
        var dims = l.split("x",2).map(parseInt)

        var vol = dims[0] * dims[1] * dims[2]
        let s1 = (dims[0]+dims[1]) * 2
        let s2 = (dims[1]+dims[2]) * 2
        let s3 = (dims[2]+dims[0]) * 2

        ribbon += vol + min(s1, min(s2, s3))


    return $ribbon


run(2015, 2, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)