import ../../../toolbox

proc parseInput(s: string): seq[seq[int]] = 
    return s.strip.split("\n").map(ints)

proc spaceAvailable(br: seq[HashSet[(int, int, int)]], p: (int,int,int)): bool =
    for b in br:
        if p in b:
            return false
    return true

proc belongsTo(br: seq[HashSet[(int, int, int)]], p: (int, int, int)): int =
    for i in 0..<br.len:
        let b = br[i]
        if p in b:
            return i
    return -1 

proc part1(s: string): string = 
    var r = parseInput(s)
    var bricks: seq[HashSet[(int,int,int)]]
    for b in r:
        var br: HashSet[(int,int,int)]
        for x in b[0]..b[3]:
            for y in b[1]..b[4]:
                for z in b[2]..b[5]:
                    br.incl((x,y,z))
        bricks.add(br)

    var isUpdate = true
    while isUpdate:
        isUpdate = false

        for i in 0..<bricks.len:
            let b = bricks[i]
            var minPosZ = 999999
            for p in b:
                minPosZ = min(minPosZ, p[2])
            if minPosZ > 1:
                # b is a fall candidate.
                var xyPrint: HashSet[(int, int)]
                for p in b:
                    xyPrint.incl (p[0], p[1])

                var canFall = true
                for (x,y) in xyPrint:
                    if not bricks.spaceAvailable((x,y, minPosZ-1)):
                        canFall = false
                        break

                if canFall:
                    var newBrick: HashSet[(int, int, int)]
                    for p in b:
                        newBrick.incl (p[0],p[1],p[2]-1)
                    bricks[i] = newBrick
                    isUpdate = true

    # The bricks have settled.
    # Compute what holds what.
    # Bricks are represented by their indicies.
    var hold: Table[int, HashSet[int]]
    for i in 0..<bricks.len:
        let b = bricks[i]
        hold[i] = initHashSet[int]()
        var maxPosZ = 1
        for p in b:
            maxPosZ = max(maxPosZ, p[2])
        var xyPrint: HashSet[(int, int)]
        for p in b:
            xyPrint.incl (p[0], p[1])

        for (x,y) in xyPrint:
            var above = (x,y,maxPosZ+1)
            var bel = bricks.belongsTo(above)
            if bel != -1:
                hold[i].incl (bel)

    var held: Table[int, HashSet[int]]
    for bid, holding in hold:
        for b in holding:
            if b notin held:
                held[b] = initHashSet[int]()
            held[b].incl bid

    var res = 0
    for bid, holding in hold:
        # what happens when we remove bid ?
        # is there a brick that falls?
        var isOk = true
        for b in holding:
            if held[b].len == 1: # only bid holds b!
                isOk = false
                break

        if isOk:
            inc res

    return $res

proc subset(a,b: HashSet[int]): bool =
    return (a - b).len == a.len - b.len

proc part2(s: string): string = 
    var r = parseInput(s)
    var bricks: seq[HashSet[(int,int,int)]]
    for b in r:
        var br: HashSet[(int,int,int)]
        for x in b[0]..b[3]:
            for y in b[1]..b[4]:
                for z in b[2]..b[5]:
                    br.incl((x,y,z))
        bricks.add(br)

    var isUpdate = true
    while isUpdate:
        isUpdate = false

        for i in 0..<bricks.len:
            let b = bricks[i]
            var minPosZ = 999999
            for p in b:
                minPosZ = min(minPosZ, p[2])
            if minPosZ > 1:
                # b is a fall candidate.
                var xyPrint: HashSet[(int, int)]
                for p in b:
                    xyPrint.incl (p[0], p[1])

                var canFall = true
                for (x,y) in xyPrint:
                    if not bricks.spaceAvailable((x,y, minPosZ-1)):
                        canFall = false
                        break

                if canFall:
                    var newBrick: HashSet[(int, int, int)]
                    for p in b:
                        newBrick.incl (p[0],p[1],p[2]-1)
                    bricks[i] = newBrick
                    isUpdate = true
    var hold: Table[int, HashSet[int]]
    for i in 0..<bricks.len:
        let b = bricks[i]
        hold[i] = initHashSet[int]()
        var maxPosZ = 1
        for p in b:
            maxPosZ = max(maxPosZ, p[2])
        var xyPrint: HashSet[(int, int)]
        for p in b:
            xyPrint.incl (p[0], p[1])

        for (x,y) in xyPrint:
            var above = (x,y,maxPosZ+1)
            var bel = bricks.belongsTo(above)
            if bel != -1:
                hold[i].incl (bel)

    var held: Table[int, HashSet[int]]
    for bid, holding in hold:
        for b in holding:
            if b notin held:
                held[b] = initHashSet[int]()
            held[b].incl bid

    var res = 0
    for bid, holding in hold:
        var movesDown = [bid].toHashSet
        var isUpdate = true

        while isUpdate:
            isUpdate = false
            for b,_ in held:
                if b notin movesDown and subset(movesDown, held[b]):
                    movesDown.incl b
                    isUpdate = true

        res += (movesDown.len - 1)


    return $res

# Written in 31 minutes, got 105 place on leaderboard.
# Code is shit thou xD.


run(2023, 22, part1, part2)