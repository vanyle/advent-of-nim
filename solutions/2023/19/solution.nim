import ../../../toolbox

type Rule = object
    # vari is '0' => always send to loca.
    vari: char # if vari cmpC n, send to loca
    cmpC: char
    n: int
    loca: string

# order is always x,m,a,s

proc cToI(c: char): int =
    if c == 'x': return 0
    if c == 'm': return 1
    if c == 'a': return 2
    if c == 's': return 3
    assert false

proc parseInput(s: string): (seq[(string, seq[Rule])], seq[array[4, int]]) = 
    var sol = s.strip.split("\n\n", 1)
    var lines = sol[0].split("\n")
    var parts = sol[1].split("\n")

    var r1: seq[(string, seq[Rule])]
    var r2: seq[array[4, int]]

    for l in lines:
        var spli = l.split("{", 1)
        var workflowName = spli[0]
        var instructions = spli[1][0..<spli[1].len-1].split(",")
        
        var ruleList: seq[Rule]
        for ins in instructions:
            if ":" notin ins:
                ruleList.add Rule(vari: '0', loca: ins)
            else:
                var insParts = ins.split(":",1)
                var condi = insParts[0]
                var cmpC = '<'
                if '>' in condi:
                    cmpC = '>'

                var condiElements = condi.split(cmpC,1)

                ruleList.add Rule(
                    loca: insParts[1],
                    cmpC: cmpC,
                    n: parseInt(condiElements[1]),
                    vari: condiElements[0][0]
                )

        r1.add((workflowName, ruleList))


    for p in parts:
        var i = ints(p)
        var toadd: array[4, int]
        for j in 0..3:
            toadd[j] = i[j]
        r2.add toadd

    return (r1, r2)


proc part1(s: string): string = 
    var (workflows, parts) = parseInput(s)

    var workflowTable: Table[string, seq[Rule]]
    for (wname, wrule) in workflows:
        workflowTable[wname] = wrule

    var goodBoys: seq[array[4, int]]

    for p in parts:
        var cworkflow = "in"
        while cworkflow != "A" and cworkflow != "R":
            var rules = workflowTable[cworkflow]

            for r in rules:
                if r.vari == '0':
                    cworkflow = r.loca
                    break

                var rIdx = cToI(r.vari)
                var a = p[rIdx]
                if r.cmpC == '<' and a < r.n:
                    cworkflow = r.loca
                    break
                if r.cmpC == '>' and a > r.n:
                    cworkflow = r.loca
                    break

        if cworkflow == "A":
            goodBoys.add p

    var res = 0
    for p in goodBoys:
        for j in 0..3:
            res += p[j]

    return $res

proc countLeaves(wt: Table[string, (Rule, Rule)], rule: string, inter: array[4, (int,int)]): int =
    for (a,b) in inter:
        if a > b: return 0

    if rule == "A":
        var res = 1
        for (a,b) in inter: res *= (b-a+1)
        return res
    elif rule == "R":
        return 0

    var (r1, r2) = wt[rule]
    var el = cToI(r1.vari)

    var i1 = inter
    var i2 = inter

    if r1.cmpC == '<':
        i1[el] = (inter[el][0], r1.n-1) # pass
        i2[el] = (r1.n, inter[el][1]) # else
        return countLeaves(wt, r1.loca, i1) + countLeaves(wt, r2.loca, i2)
    elif r1.cmpC == '>':
        i1[el] = (inter[el][0], r1.n) # else
        i2[el] = (r1.n+1, inter[el][1]) # pass
        return countLeaves(wt, r1.loca, i2) + countLeaves(wt, r2.loca, i1)
    else:
        assert false


proc part2(s: string): string = 
    var (workflows, _) = parseInput(s)

    var workflowTable: Table[string, (Rule, Rule)]
    for (wname, wrule) in workflows:
        # Rule deduplication.
        # The seq is always of length 2.
        for i in 0..<(wrule.len - 1):
            var tmpRule = wname
            if i != 0:
                tmpRule = wname & $i

            var r: Rule = wrule[i]
            var elseClause: Rule = Rule(vari: '0')

            if i < wrule.len-2:
                elseClause.loca = wname & $(i+1)
            else: # i == wrule.len-2
                elseClause.loca = wrule[wrule.len-1].loca

            workflowTable[tmpRule] = (r, elseClause)

    # Count the leaves reaching
    var res = workflowTable.countLeaves("in", [(1,4000),(1,4000),(1,4000),(1,4000)])
    return $res 


run(2023, 19, part1, part2)