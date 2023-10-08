import ../../../toolbox

proc parseInput(s: string): seq[int] = 
    return ints(s)


proc part1(s: string): string = 
    var r = parseInput(s)
    var cmass = foldl(r, a+b, 0) div 3

    # split r into 3 groups of the same weight
    # 1 group needs to have the smallest amount of objects
    # minimize the product of group 1.

    # We only consider the first group.
    # We need to pick elements to reach cmass
    echo "Mass target: ",cmass
    r.sort()

    # Start by finding a lower bound on the amount of objects to pick.
    var elements = 0
    for i in product([0, 1], repeat = r.len):
        var m = 0
        elements = 0
        for j in 0..<i.len:
            if i[j] == 1:
                inc elements
                m += r[j]
        if m == cmass:
            break

    echo "Items: ",elements

    var prod = int.high
    for i in combinations(r, elements):
        var m = 0
        var p = 1
        for j in i:
            p *= j
            m += j
        if m == cmass:
            prod = min(prod, p)


    return $prod

proc part2(s: string): string = 
    var r = parseInput(s)
    var cmass = foldl(r, a+b, 0) div 4
    echo "Mass target: ",cmass
    r.sort()

    # Start by finding a lower bound on the amount of objects to pick.
    var elements = 0
    for i in product([0, 1], repeat = r.len):
        var m = 0
        elements = 0
        for j in 0..<i.len:
            if i[j] == 1:
                inc elements
                m += r[j]
        if m == cmass:
            break

    echo "Items: ",elements

    var prod = int.high
    for i in combinations(r, elements):
        var m = 0
        var p = 1
        for j in i:
            p *= j
            m += j
        if m == cmass:
            prod = min(prod, p)


    return $prod

run(2015, 24, part1, part2)