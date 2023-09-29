import ../../../toolbox

import md5, strutils

var part1Ready* = true
proc part1(s: string): string = 
    var counter = 1
    var inpt = s.strip()

    while true:
        var toHash = inpt & $counter
        var hashed = $toHash.toMD5()
        if hashed.startswith("00000"):
            return $counter
        inc counter

var part2Ready* = true
proc part2(s: string): string = 
    var counter = 1
    var inpt = s.strip()

    while true:
        var toHash = inpt & $counter
        var hashed = $toHash.toMD5()
        if hashed.startswith("000000"):
            return $counter
        inc counter

run(2015, 4, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)