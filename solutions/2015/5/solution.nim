import ../../../toolbox

import strutils, sets

var part1Ready* = true
proc part1(s: string): string = 
    var lines = s.strip.splitLines
    var niceCount = 0
    for l in lines:
        var vowelCount = 0
        var vowels = "aeiou"
        for i in l:
            if i in vowels: inc vowelCount

        var p1 = vowelCount >= 3

        var p2 = false
        for i in 0..<l.len-1:
            if l[i] == l[i+1]:
                p2 = true
                break

        var p3 = "ab" notin l and "cd" notin l and "pq" notin l and "xy" notin l

        if p1 and p2 and p3:
            inc niceCount

    return $niceCount

var part2Ready* = true
proc part2(s: string): string = 
    var lines = s.strip.splitLines
    var niceCount = 0
    for l in lines:
        var p1 = false
        for i in 0..<l.len-2: # aba
            if l[i] == l[i+2]:
                p1 = true
                break

        var p2 = false
        var pairs: HashSet[string]
        var lastPair: string

        for i in 0..<l.len-1:
            var d = l[i] & l[i+1]
            if d in pairs:
                p2 = true
                break
            pairs.incl(lastPair)
            lastPair = d.strip() # copy

        if p1 and p2:
            inc niceCount


    return $niceCount

run(2015, 5, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)