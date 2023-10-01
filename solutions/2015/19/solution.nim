import ../../../toolbox

proc parseInput(s: string): (Table[string, seq[string]], string) =
    var e = s.strip.split("\n\n",1)
    var t = e[0].splitLines.map(x => x.split(" => ",1))
    var starting = e[1]
    var table: Table[string, seq[string]]

    for i in t:
        if i[0] notin table: table[i[0]] = @[]
        table[i[0]].add i[1]

    return (table, starting)

proc part1(s: string): string = 
    var (replacements, starting) = parseInput(s)
    
    var molecules: HashSet[string]

    for s1, vals in replacements:

        for i in 0..<(starting.len - s1.len + 1):
            if starting[i..<(i+s1.len)] == s1:
                for j in 0..<vals.len:
                    var replaced = starting[0..<i] & vals[j] & starting[(i+s1.len)..<starting.len]
                    molecules.incl replaced


    return $molecules.len

proc elementalSpliter(elements: string): seq[string] =
    # split MgCa => [Mg,Ca]
    discard

proc part2(s: string): string = 
    var (replacements, destination) = parseInput(s)

    var start = "e"
    # steps to get from start to destination
    # This is a path-finding problem.
    # Notice that every steps
    # grows start, so if there are too many elements,
    # we know it's a dead end.

run(2015, 19, part1, part2)