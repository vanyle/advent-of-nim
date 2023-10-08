import ../../../toolbox


# shop info
# (price, dmg buff, armor buff)
var weapons = [(8, 4, 0), (10, 5, 0), (25, 6, 0), (40, 7, 0), (74, 8, 0)]
var armors = [(0,0,0), (13, 0, 1), (31, 0, 2), (53, 0, 3), (75, 0, 4), (102, 0, 5)]
var rings = [(25, 1, 0), (50, 2, 0), (100, 3, 0), (20, 0, 1), (40, 0, 2), (80, 0, 3)]

proc doesPlayerWin(
    hpP: int,
    dmgP: int,
    armP: int,
    hpB: int,
    dmgB: int,
    armB: int
): bool =
    if hpP <= 0: return false
    if hpB <= 0: return true

    var hpB2 = hpB - max(1, dmgP - armB)
    if hpB2 <= 0: return true
    var hpP2 = hpP - max(1, dmgB - armP)

    return doesPlayerWin(hpP2, dmgP, armP, hpB2, dmgB, armB)

proc part1(s: string): string = 
    # doesPlayerWin is a monotonous function.
    # it is increasing in hpP, dmgP and armP
    # it is decreasing in hpB, dmgB and armB.
    var integers = ints(s)
    var hpB = integers[0]
    var dmgB = integers[1]
    var armB = integers[2]

    let hpP = 100

    # Let's consider all possibilities!
    var lowestCost = int.high

    for weapon in weapons:
        for armor in armors:
            var dmgP = weapon[1] + armor[1]
            var armP = weapon[2] + armor[2]
            if doesPlayerWin(hpP, dmgP, armP, hpB, dmgB, armB):
                lowestCost = min(lowestCost, weapon[0] + armor[0])

            for ring1 in rings:
                if doesPlayerWin(
                    hpP, dmgP + ring1[1], armP + ring1[2],
                    hpB, dmgB, armB
                ):
                    lowestCost = min(lowestCost, weapon[0] + armor[0] + ring1[0])

                for ring2 in rings:
                    if ring1 == ring2: continue
                    if doesPlayerWin(
                        hpP,
                        dmgP + ring1[1] + ring2[1],
                        armP + ring1[2] + ring2[2],
                        hpB, dmgB, armB
                    ):
                        lowestCost = min(lowestCost,
                            weapon[0] + armor[0] + ring1[0] + ring2[0]
                        )

    return $lowestCost


proc part2(s: string): string = 
    var integers = ints(s)
    var hpB = integers[0]
    var dmgB = integers[1]
    var armB = integers[2]

    let hpP = 100

    var highestCost = int.low
    for weapon in weapons:
        for armor in armors:
            var dmgP = weapon[1] + armor[1]
            var armP = weapon[2] + armor[2]
            if not doesPlayerWin(hpP, dmgP, armP, hpB, dmgB, armB):
                highestCost = max(highestCost, weapon[0] + armor[0])

            for ring1 in rings:
                if not doesPlayerWin(
                    hpP, dmgP + ring1[1], armP + ring1[2],
                    hpB, dmgB, armB
                ):
                    highestCost = max(highestCost, weapon[0] + armor[0] + ring1[0])

                for ring2 in rings:
                    if ring1 == ring2: continue
                    if not doesPlayerWin(
                        hpP,
                        dmgP + ring1[1] + ring2[1],
                        armP + ring1[2] + ring2[2],
                        hpB, dmgB, armB
                    ):
                        highestCost = max(highestCost,
                            weapon[0] + armor[0] + ring1[0] + ring2[0]
                        )

    return $highestCost

run(2015, 21, part1, part2)