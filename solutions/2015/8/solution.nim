import ../../../toolbox

proc countChar(value: string, ch: string): int =
    for i in 0..<value.len - ch.len:
        if value[i..<(i+ch.len)] == ch: inc result

var part1Ready* = true
proc part1(s: string): string = 
    var lines = s.strip.splitLines
    var realCharacterCount = 0
    var representedCharacterCount = 0

    for l in lines:
        realCharacterCount += l.len

        var cline = l.len - 2 # remove the 2 quotes

        # case: "\\" => 4 real, 1 fake.

        cline -= countChar(l, "\\\\") # \\ <=> 2 real for 1 fake (-1)
        cline -= countChar(l, "\\\"") # \\ <=> 2 real for 1 fake (-1)
        # \x12 <=> 4 real char for 1 fake (-2), but not -3 as the \\ was
        # already handled previously.
        cline -= countChar(l, "\\x")*3

        representedCharacterCount += cline

    return $(realCharacterCount - representedCharacterCount)

var part2Ready* = false
proc part2(s: string): string = 
    discard

run(2015, 8, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)