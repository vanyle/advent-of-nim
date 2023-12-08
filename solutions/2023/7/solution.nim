import ../../../toolbox

var order = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2']

var rorder = reverseTable(order.toSeq)

proc parseInput(s: string): seq[(string, int)] = 
    var lines = s.strip.split("\n")
    
    for l in lines:
        var dd = l.split(" ")
        result.add((dd[0], dd[1].parseInt))

proc profileKind(a: string): array[5, int] =
    # Return the win profile of the card: 2,2 ; 3,2 , etc...
    var ct: CountTable[char]
    for i in 0..<a.len:
        ct.inc(a[i])
    var profile: array[5, int]
    var i = 0
    for v in ct.values():
        profile[i] = v
        inc i
    profile.sort(SortOrder.Descending)
    return profile

proc isHighestCardStronger(a, b: string): bool =
    for i in 0..<a.len:
        if rorder[a[i]] < rorder[b[i]]:
            return true
        elif rorder[b[i]] < rorder[a[i]]:
            return false
        # both a and b have this card, continue.

    assert false # a == b ??

proc isGreater(a, b: string, pk: proc(a: string): array[5,int]): bool =
    let pa = pk(a)
    let pb = pk(b)

    if pa[0] == 5:
        if pb[0] == 5:
            return isHighestCardStronger(a,b)
        return true
    if pb[0] == 5: return false

    if pa[0] == 4:
        if pb[0] == 4:
            return isHighestCardStronger(a,b)
        return true
    if pb[0] == 4: return false

    if pa[0] == 3 and pa[1] == 2:
        if pb[0] == 3 and pb[1] == 2:
            return isHighestCardStronger(a,b)
        return true
    if pb[0] == 3 and pb[1] == 2: return false

    if pa[0] == 3:
        if pb[0] == 3:
            return isHighestCardStronger(a,b)
        return true
    if pb[0] == 3: return false

    if pa[0] == 2 and pa[1] == 2:
        if pb[0] == 2 and pb[1] == 2:
            return isHighestCardStronger(a,b)
        return true
    if pb[0] == 2 and pb[1] == 2: return false

    if pa[0] == 2:
        if pb[0] == 2:
            return isHighestCardStronger(a,b)
        return true
    if pb[0] == 2: return false

    # high card:
    var ma = order.len
    for i in a:
        ma = min(ma, rorder[i])

    var mb = order.len
    for i in a:
        mb = min(mb, rorder[i])

    if ma == mb: return isHighestCardStronger(a, b)
    if ma < mb: return true
    return false



proc part1(s: string): string = 
    var r = parseInput(s)

    proc myCmp(a,b: (string, int)): int =
        if isGreater(a[0], b[0], profileKind): return 1
        return -1

    r.sort(myCmp)

    var score = 0
    for i in 0..<r.len:
        score += (i+1) * r[i][1]

    return $score


proc profileKind2(a: string): array[5, int] =
    # Return the win profile of the card: 2,2 ; 3,2 , etc...
    var ct: CountTable[char]
    for i in 0..<a.len:
        ct.inc(a[i])
    var profile: array[5, int]

    var jCount = ct['J']
    ct['J'] = 0

    var i = 0
    for v in ct.values():
        profile[i] = v
        inc i
    profile.sort(SortOrder.Descending)
    profile[0] += jCount

    return profile

proc part2(s: string): string = 
    var r = parseInput(s)
    rorder['J'] = rorder.len + 1 # J is the weakest card.

    proc myCmp(a,b: (string, int)): int =
        if isGreater(a[0], b[0], profileKind2): return 1
        return -1

    r.sort(myCmp)

    var score = 0
    for i in 0..<r.len:
        score += (i+1) * r[i][1]

    return $score


run(2023, 7, part1, part2)