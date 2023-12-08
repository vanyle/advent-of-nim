import ../../../toolbox

proc parseInput(s: string): seq[(seq[int], seq[int])] = 
    var lines = s.strip.split("\n")
    for l in lines:
        let p = l.split(": ")[1]
        let seg = p.split(" | ")
        let s1 = seg[0].split(" ").filter(x => x.strip.len != 0).map(x => x.strip.parseInt)
        let s2 = seg[1].split(" ").filter(x => x.strip.len != 0).map(x => x.strip.parseInt)
        result.add((s1, s2))


proc part1(s: string): string = 
    var r = parseInput(s)
    var points = 0

    for card in r:
        let sh = card[0].toHashSet
        var matches = 0

        for num in card[1]:
            if num in sh:
                inc matches

        if matches > 0:
            var toAdd = 1
            for i in 1..<matches:
                toAdd *= 2
            points += toAdd

    return $points


proc part2(s: string): string = 
    var r = parseInput(s)

    var wTable: seq[int] = @[]
    for i in 0..<r.len:
        var card = r[i]
        let sh = card[0].toHashSet
        var matches = 0

        for num in card[1]:
            if num in sh:
                inc matches

        wTable.add(matches) # card i makes you win 'matches' cards

    var cardsOwned: seq[int] = newSeq[int](r.len)
    for i in 0..<cardsOwned.len:
        cardsOwned[i] = 1

    for i in 0..<cardsOwned.len:
        var w = wTable[i]
        for j in (i+1) ..< (i + 1 + w):
            cardsOwned[j] += cardsOwned[i]   

    return $cardsOwned.foldl(a + b)



run(2023, 4, part1, part2)