import ../../../toolbox

proc parseInput(s: string): (seq[seq[int]], seq[seq[int]]) = 
    let bothParts = s.strip.split("\n\n")
    let pageOrderingRules = bothParts[0].split("\n").map(x => x.split("|").map(parseInt))
    let updates = bothParts[1].split("\n").map(x => x.split(",").map(parseInt))

    return (pageOrderingRules, updates)

type Nums = 0..99

proc isUpdateCorrect(update: seq[int], afterTable: Table[int, set[Nums]]): bool =
    var seen: set[Nums]
    
    for n in update:
        if n in afterTable and card(seen * afterTable[n]) != 0:
            return false
        seen.incl(n)
    return true

proc part1(s: string): string = 
    var (pageOrderingRules, updates) = parseInput(s)
    var r = 0

    var beforeTable: Table[int, set[Nums]]
    for rule in pageOrderingRules:
        let firstNumber = rule[0]
        if firstNumber in beforeTable:
            beforeTable[firstNumber].incl(rule[1])
        else:
            beforeTable[firstNumber] = {rule[1].Nums}

    for update in updates:
        if isUpdateCorrect(update, beforeTable):
            r += update[update.len div 2]

    return $r

proc fixPageOrder(update: seq[int], afterTable: Table[int, set[Nums]]): seq[int] =
    # Bubble sort style approach to sorting
    
    proc customCmp(a,b: int): int =
        if a in afterTable and b in afterTable[a]:
            return -1
        if b in afterTable and a in afterTable[b]:
            return 1
        return 0

    return update.sorted(customCmp)

proc part2(s: string): string = 
    var (pageOrderingRules, updates) = parseInput(s)
    var r = 0

    var beforeTable: Table[int, set[Nums]]
    for rule in pageOrderingRules:
        let firstNumber = rule[0]
        if firstNumber in beforeTable:
            beforeTable[firstNumber].incl(rule[1])
        else:
            beforeTable[firstNumber] = {rule[1].Nums}

    for update in updates:
        if not isUpdateCorrect(update, beforeTable):
            let orderFixed = fixPageOrder(update, beforeTable)
            r += orderFixed[orderFixed.len div 2]

    return $r

run(2024, 5, part1, part2)