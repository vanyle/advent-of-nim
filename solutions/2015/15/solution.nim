import ../../../toolbox

proc parseInput(s: string): Table[string, (int, int, int, int, int)] =
    var lines = s.strip.splitLines
    for l in lines:
        var w: string
        var cap,d,f,t,cal: int
        if scanf(l,
            "$w: capacity $i, durability $i, flavor $i, texture $i, calories $i",
            w, cap, d, f, t, cal
            ):
            result[w] = (cap,d,f,t,cal)


var part1Ready* = true
proc part1(s: string): string = 
    # oh boy, a linear optimization problem ...
    var things = parseInput(s)
    # pick 100 things so that:
    # the product of the capacities is maximized.
    # we ignore calories for now.

    # Let's try every possibility of 4 ingredients!
    var ingredients: seq[string] = things.keys.toSeq
    assert ingredients.len == 4
    var bestScore = 0

    for a1 in 0..100:
        let rest = 100-a1
        for a2 in 0..rest:
            let rest2 = rest-a2
            for a3 in 0..rest2:
                let a4 = rest2 - a3

                var cap = things[ingredients[0]][0] * a1
                cap += things[ingredients[1]][0] * a2
                cap += things[ingredients[2]][0] * a3
                cap += things[ingredients[3]][0] * a4
                cap = max(cap, 0)

                var dur = things[ingredients[0]][1] * a1
                dur += things[ingredients[1]][1] * a2
                dur += things[ingredients[2]][1] * a3
                dur += things[ingredients[3]][1] * a4
                dur = max(dur, 0)

                var fla = things[ingredients[0]][2] * a1
                fla += things[ingredients[1]][2] * a2
                fla += things[ingredients[2]][2] * a3
                fla += things[ingredients[3]][2] * a4
                fla = max(fla, 0)

                var tex = things[ingredients[0]][3] * a1
                tex += things[ingredients[1]][3] * a2
                tex += things[ingredients[2]][3] * a3
                tex += things[ingredients[3]][3] * a4                    
                tex = max(tex, 0)

                bestScore = max(
                    bestScore,
                    tex * cap * dur * fla
                )
    return $bestScore


var part2Ready* = true
proc part2(s: string): string = 
    var things = parseInput(s)
    # pick 100 things so that:
    # the product of the capacities is maximized.
    # we ignore calories for now.

    # Let's try every possibility of 4 ingredients!
    var ingredients: seq[string] = things.keys.toSeq
    assert ingredients.len == 4
    var bestScore = 0

    for a1 in 0..100:
        let rest = 100-a1
        for a2 in 0..rest:
            let rest2 = rest-a2
            for a3 in 0..rest2:
                let a4 = rest2 - a3

                var cal = things[ingredients[0]][4] * a1
                cal += things[ingredients[1]][4] * a2
                cal += things[ingredients[2]][4] * a3
                cal += things[ingredients[3]][4] * a4
                if cal != 500: continue # new constraint!

                var cap = things[ingredients[0]][0] * a1
                cap += things[ingredients[1]][0] * a2
                cap += things[ingredients[2]][0] * a3
                cap += things[ingredients[3]][0] * a4
                cap = max(cap, 0)

                var dur = things[ingredients[0]][1] * a1
                dur += things[ingredients[1]][1] * a2
                dur += things[ingredients[2]][1] * a3
                dur += things[ingredients[3]][1] * a4
                dur = max(dur, 0)

                var fla = things[ingredients[0]][2] * a1
                fla += things[ingredients[1]][2] * a2
                fla += things[ingredients[2]][2] * a3
                fla += things[ingredients[3]][2] * a4
                fla = max(fla, 0)

                var tex = things[ingredients[0]][3] * a1
                tex += things[ingredients[1]][3] * a2
                tex += things[ingredients[2]][3] * a3
                tex += things[ingredients[3]][3] * a4                    
                tex = max(tex, 0)

                bestScore = max(
                    bestScore,
                    tex * cap * dur * fla
                )
    return $bestScore
    

run(2015, 15, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)