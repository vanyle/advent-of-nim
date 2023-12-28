import ../../../toolbox

var maxCubes = {
    'r': 12,
    'g': 13,
    'b': 14
}.toTable

template parseInput(s: string, gameStart: untyped, inGame: untyped, gameEnd: untyped): untyped = 
    var t: Tokenizer = Tokenizer(s: s, offset: 0)

    while not t.atEnd():
        var eol = t.findNext('\n')

        t.advance(':', eol)
        t.advanceFixed(2) # eat ' :'

        gameStart

        while t.offset < eol:
            # Game 1: 19 blue, 12 red; 19 blue, 2 green, 1 red; 13 red, 11 blue

            var eob = t.findNext(';', eol)

            while t.offset < eob:
                var count {.inject.} = t.eatUnsignedInt()
                t.advanceFixed(1) # eat space.
                var color {.inject.} = t.s[t.offset] # store r,g or b.
                
                inGame

                t.advance(',', eob)
                t.advanceFixed(2) # skip the comma and space

        gameEnd


        t.advanceFixed(1) # skip end of line


proc part1(s: string): string = 
    var t: Tokenizer = Tokenizer(s: s, offset: 0)
    var validIds = 0
    var lineIdx = 1

    while not t.atEnd():
        var eol = t.findNext('\n')
        var isGameValid = true

        t.advance(':', eol)
        t.advanceFixed(2) # eat ' :'

        while t.offset < eol:
            # Game 1: 19 blue, 12 red; 19 blue, 2 green, 1 red; 13 red, 11 blue

            var eob = t.findNext(';', eol)
            var tt: Table[char, int]

            while t.offset < eob:
                var count = t.eatUnsignedInt()
                t.advanceFixed(1) # eat space.
                var color = t.s[t.offset] # store r,g or b.
                tt[color] = count

                # Process game:
                if maxCubes[color] < count:
                    isGameValid = false
                    t.advance('\n')
                    break

                t.advance(',', eob)
                t.advanceFixed(2) # skip the comma and space


        t.advanceFixed(1) # skip end of line

        if isGameValid:
            validIds += lineIdx

        inc lineIdx

    return $validIds



proc part2(s: string): string = 
    var res = 0
    var minVals = {
        'r': 0,
        'g': 0,
        'b': 0
    }.toTable

    parseInput s:
        minVals = {
            'r': 0,
            'g': 0,
            'b': 0
        }.toTable
    do:
        minVals[color] = max(minVals[color], count)
    do:
        var power = minVals['r'] * minVals['g'] *  minVals['b']
        res += power

    return $res


run(2023, 2, part1, part2)