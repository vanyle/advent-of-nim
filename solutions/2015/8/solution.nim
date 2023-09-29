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

        var cline = 0 # l.len - 2 # remove the 2 quotes

        var idx = 1
        while idx < l.len-1:
            if l[idx..idx+1] == "\\\\":
                inc idx
            elif l[idx..idx+1] == "\\x":
                idx += 3
            elif l[idx..idx+1] == "\\\"":
                inc idx
            inc cline
            inc idx

        representedCharacterCount += cline

    return $(realCharacterCount - representedCharacterCount)

var part2Ready* = true
proc part2(s: string): string =
    var lines = s.strip.splitLines
    var realCharacterCount = 0
    var encodedCharacterCount = 0

    for l in lines:
        realCharacterCount += l.len

        var cline = 2 # 2 for starting and end quote
        for c in l:
            if c == '\\':
                inc cline
            elif c == '"':
                inc cline
            inc cline
        encodedCharacterCount += cline

    return $(encodedCharacterCount - realCharacterCount)

run(2015, 8, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)