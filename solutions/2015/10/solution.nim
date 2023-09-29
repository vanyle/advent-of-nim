import ../../../toolbox

proc lookAndSay(input: string): string =
    var count = 1
    for i in 0..<input.len:
        if i + 1 < input.len and input[i] == input[i + 1]:
            count += 1
        else:
            result.add($count & input[i])
            count = 1
    return result

var part1Ready* = true
proc part1(s: string): string = 
    var ss = s.strip

    for i in 0..<40:
        ss = lookAndSay(ss)
    
    return $ss.len


var part2Ready* = true
proc part2(s: string): string = 
    var ss = s.strip

    for i in 0..<50:
        ss = lookAndSay(ss)
    # Done in: 1.992s
    # I love compiled languages!

    return $ss.len

run(2015, 10, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)