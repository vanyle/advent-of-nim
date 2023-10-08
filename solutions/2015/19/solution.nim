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
    var tmp = ""
    for i in elements:
        if isUpperAscii(i) and tmp.len > 0:
            result.add tmp
            tmp = $i
        else:
            tmp.add i
    if tmp.len > 0:
        result.add tmp



iterator neighbors*(rt: Table[seq[string], string], s: seq[string]): seq[string] =
    # list all possible substitutions
    for i in 0..<s.len:
        for k,e in rt:
            if s.len >= i + k.len and s[i..<(i + k.len)] == k:
                yield concat(s[0..<i],@[e],s[(i+k.len)..<s.len])


proc heuristic*(replacements: Table[seq[string], string], s: seq[string], goal: seq[string]): int =
    # use a string distance function
    return s.len
    # return editDistance(s, goal)

proc cost*(replacements: Table[seq[string], string], a: seq[string], b: seq[string]): int =
    return 1

proc part2(s: string): string = 
    var (replacements, destination) = parseInput(s)

    var elements = elementalSpliter(destination)
    var atoms: HashSet[string]

    var rtable: Table[seq[string], string] # molecule -> simplification

    for k,v in replacements:
        atoms.incl k
        for molecule in v:
            var splitted = elementalSpliter(molecule)
            if splitted notin rtable:
                rtable[splitted] = k
            # rtable[splitted].add k

    for i in elements:
        atoms.incl i


    var start = @["e"]
    var pathLength = 0

    while elements.len > 0:
        var f = false
        var ns = @[""]
        var bestLength = 999999
        for n in neighbors(rtable, elements):
            # take the n with the smallest length
            if n.len < bestLength:
                bestLength = n.len
                ns = n
            f = true
        
        if f:
            elements = ns

        if not f:
            if elements == start:
                break
            echo "stuck at: ",elements
            break
        inc pathLength
        echo elements.len

    echo "Final element: ", elements

    return $pathLength

run(2015, 19, part1, part2)