import ../../../toolbox


proc searchMostest(
    dist: Table[(string,string), int],
    cityNames: seq[string],
    cities: var seq[bool],
    position: int,
    distanceTraveled: int,
    associativeFunction: proc(a: int,b: int): int
    ): int =

    var mostestFound: int = 0
    for c in 0..<cities.len:
        if cities[c]: continue
        cities[c] = true
        
        var v = searchMostest(dist, cityNames, cities,
            c,
            distanceTraveled + dist[(cityNames[c], cityNames[position])],
            associativeFunction
        )
        if mostestFound == 0: mostestFound = v
        else: mostestFound = associativeFunction(mostestFound, v) 
        
        cities[c] = false
    if mostestFound == 0: return distanceTraveled

    return mostestFound

var part1Ready* = true
proc part1(s: string): string = 
    var lines = s.strip.splitLines

    # Traveling salesman (almost)
    # start and finish can be different.
    var dist: Table[(string, string), int]
    var cities: seq[string]

    for l in lines:
        var start, finish: string
        var d: int
        if scanf(l, "$w to $w = $i", start, finish, d):
            dist[(start, finish)] = d
            dist[(finish, start)] = d
            if start notin cities:
                cities.add(start)
            if finish notin cities:
                cities.add(finish)

    # There are not a lot of paths, we can be exhaustive in our search.
    # This is still a bit slow :'(
    var smallestFound: int = high(int)

    proc mmin(a: int, b: int): int = min(a,b)

    for c in 0..<cities.len:
        var toVisit: seq[bool] = newSeq[bool](cities.len)
        toVisit[c] = true

        smallestFound = min(
            smallestFound,
            searchMostest(
                dist,
                cities,
                toVisit,
                c,
                0,
                mmin
            )
        )
        toVisit[c] = false

    return $smallestFound


var part2Ready* = true
proc part2(s: string): string = 
    var lines = s.strip.splitLines

    # Traveling salesman (almost)
    # start and finish can be different.
    var dist: Table[(string, string), int]
    var cities: seq[string]

    for l in lines:
        var start, finish: string
        var d: int
        if scanf(l, "$w to $w = $i", start, finish, d):
            dist[(start, finish)] = d
            dist[(finish, start)] = d
            if start notin cities:
                cities.add(start)
            if finish notin cities:
                cities.add(finish)

    # There are not a lot of paths, we can be exhaustive in our search.
    # This is still a bit slow :'(
    var biggestFound: int = low(int)

    proc mmax(a: int, b: int): int = max(a,b)

    for c in 0..<cities.len:
        var toVisit: seq[bool] = newSeq[bool](cities.len)
        toVisit[c] = true

        biggestFound = max(
            biggestFound,
            searchMostest(
                dist,
                cities,
                toVisit,
                c,
                0,
                mmax
            )
        )
        toVisit[c] = false

    return $biggestFound

run(2015, 9, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)