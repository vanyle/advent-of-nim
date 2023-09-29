import ../../../toolbox

import strutils, strscans

var part1Ready* = true
proc part1(s: string): string = 
    var instructions = s.strip.splitLines

    # derivative array for efficient instruction
    # processing (toggle is fast at least...)
    var larray: array[1000, array[1000, bool]]
    var x1,y1,x2,y2: int

    for ins in instructions:
        if scanf(ins, "toggle $i,$i through $i,$i", x1, y1, x2, y2):
            for x in x1..x2:
                for y in y1..y2:
                    larray[x][y] = not larray[x][y]
        elif scanf(ins, "turn on $i,$i through $i,$i", x1, y1, x2, y2):
            for x in x1..x2:
                for y in y1..y2:
                    larray[x][y] = true
        elif scanf(ins, "turn off $i,$i through $i,$i", x1, y1, x2, y2):
            for x in x1..x2:
                for y in y1..y2:
                    larray[x][y] = false

    # perform integration to retreive the light count.
    var lightsOn = 0
    for i in 0..<1000:
        for j in 0..<1000:
            if larray[i][j]: inc lightsOn

    return $lightsOn

var part2Ready* = true
proc part2(s: string): string = 
    var instructions = s.strip.splitLines

    # derivative array for efficient instruction
    # processing (toggle is fast at least...)
    var larray: seq[array[1000, int]] = newSeq[array[1000,int]](1000)
    var x1,y1,x2,y2: int

    for ins in instructions:
        if scanf(ins, "toggle $i,$i through $i,$i", x1, y1, x2, y2):
            for x in x1..x2:
                for y in y1..y2:
                    larray[x][y] += 2
        elif scanf(ins, "turn on $i,$i through $i,$i", x1, y1, x2, y2):
            for x in x1..x2:
                for y in y1..y2:
                    inc larray[x][y]
        elif scanf(ins, "turn off $i,$i through $i,$i", x1, y1, x2, y2):
            for x in x1..x2:
                for y in y1..y2:
                    larray[x][y] = max(0, larray[x][y]-1)

    # perform integration to retreive the light count.
    var lightsOn = 0
    for i in 0..<1000:
        for j in 0..<1000:
            lightsOn += larray[i][j]

    return $lightsOn

run(2015, 6, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)