import ../../../toolbox


#[

This is the kind of problems picat shines at...
Minimization of a value given choices...

]#


type Effect = enum
    # Can also represent an action
    Shield = 0
    Poison = 1
    Recharge = 2
    Drain = 3
    MagicMissile = 4

var dmgB = 0 # global (for perf)
const TurnPlayer = true
const TurnBoss = false


proc simulateGame(
    mp: int,
    hpP: int,
    effects: array[3, int],
    hpB: int,
    turn: bool
): (int, seq[Effect]) {.memoized.} =
    # Player loses => max mana spent.
    if hpP <= 0: return (999999999, @[])
    if hpB <= 0: return (0, @[])

    # Simulate all possible games where the player wins.
    # Return the minimum amount of mana that can be used.

    # Apply the effects
    var eff = effects # copy the effects
    var mpNew = mp
    var hpBNew = hpB
    var armor = 0

    if eff[Shield.int] > 0:
        armor = 7
        dec eff[Shield.int]
    if eff[Poison.int] > 0:
        hpBNew -= 3
        dec eff[Poison.int]
    if eff[Recharge.int] > 0:
        mpNew += 101
        dec eff[Recharge.int]

    if hpB <= 0: return (0, @[])

    # Make the player play.
    if turn == TurnPlayer:
        if mp < 53: return (999999999, @[]) 
        
        # MagicMissile
        var (res, at1) = simulateGame(
            mpNew - 53,
            hpP,
            eff,
            hpBNew - 4,
            TurnBoss
        )
        res += 53
        at1.add MagicMissile

        # Drain
        if mpNew >= 73:
            var (m, at2) = simulateGame(
                mpNew - 73,
                hpP + 2,
                eff,
                hpBNew - 2,
                TurnBoss
            )
            m += 73
            if m < res:
                at2.add Drain
                at1 = at2
            res = min(m, res)

        if mpNew >= 113 and eff[Shield.int] == 0:
            var eff2 = eff
            eff2[Shield.int] = 6
            var (m, at2) = simulateGame(
                mpNew - 113,
                hpP,
                eff2,
                hpBNew,
                TurnBoss
            )
            m += 113
            if m < res:
                at2.add Shield
                at1 = at2
            res = min(m, res)

        if mpNew >= 173 and eff[Poison.int] == 0:
            var eff2 = eff
            eff2[Poison.int] = 6
            var (m, at2) = simulateGame(
                mpNew - 173,
                hpP,
                eff2,
                hpBNew,
                TurnBoss
            )
            m += 173
            if m < res:
                at2.add Poison
                at1 = at2
            res = min(m, res)

        if mpNew >= 229 and eff[Recharge.int] == 0:
            var eff2 = eff
            eff2[Recharge.int] = 5
            var (m, at2) = simulateGame(
                mpNew - 229,
                hpP,
                eff2,
                hpBNew,
                TurnBoss
            )
            m += 229
            if m < res:
                at2.add Recharge
                at1 = at2
            res = min(m, res)

        return (res, at1)


    # Make the boss play
    if turn == TurnBoss:
        return simulateGame(
            mpNew,
            hpP - max(1, dmgB - armor),
            eff,
            hpBNew,
            TurnPlayer
        )

proc parseInput(s: string): seq[int] = 
    return ints(s)

proc part1(s: string): string = 
    var r = parseInput(s)
    var hpB = r[0]
    dmgB = r[1]

    let (res, actions) = simulateGame(
        500,
        50,
        [0,0,0],
        hpB,
        TurnPlayer
    )
    # higher than 458
    echo actions

    return $res



proc part2(s: string): string = 
    var r = parseInput(s)

    return ""

run(2015, 22, part1, part2)