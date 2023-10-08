import ../../../toolbox

import math

proc getDeliveryCount(houseId: int): int =
    var s = math.sqrt(houseId.float)
    for i in 1..floor(s).int:
        if houseId mod i == 0:
            result += i * 10
            if i.float != s:
                result += (houseId div i) * 10

var part1Ready* = false
proc part1(s: string): string = 
    var n = parseInt(s.strip)
    var h = 1
    while getDeliveryCount(h) < n:
        inc h

    return $h


proc getDeliveryCount2(houseId: int): int =
    var s = math.sqrt(houseId.float)
    for i in 1..floor(s).int:
        if houseId mod i == 0:
            var j = houseId div i
            if i == j:
                result += i * 11
            else:
                if j < 50:
                    result += i * 11
                if i < 50:
                    result += j * 11

var part2Ready* = false
proc part2(s: string): string = 
    var n = parseInt(s.strip)
    var h = 1
    while getDeliveryCount2(h) < n:
        inc h

    return $h

run(2015, 20, part1, part2)