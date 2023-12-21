import ../../../toolbox

import deques, math

proc parseInput(s: string): Table[string, (char, seq[string])] = 
    let lines = s.split("\n")
    for l in lines:
        var p = l.split(" -> ",1)
        var t = p[0][0]
        var r = p[0][1..<p[0].len]
        if t == 'b':
            r = "broadcaster"
        result[r] = (t, p[1].split(", "))

var lowPulseCounter = 0
var highPulseCounter = 0

proc simulateButtonPress(
        modules: Table[string, (char, seq[string])],
        moduleInputCount: CountTable[string], # store input count and module type
        moduleState: var Table[string, HashSet[string]],
        rxHook: static[bool] = false
    ): bool {.discardable.} =

    # true => high, false => low
    var pulseStack = @[("broadcaster", "button", false)]

    while pulseStack.len > 0:
        let (dest, src, pulseType) = pulseStack.pop()

        if pulseType:
            inc highPulseCounter
        else:
            inc lowPulseCounter

        if dest notin modules:
            continue # dest is a debugging module.

        when rxHook:
            if dest == "rx" and not pulseType:
                return true

        var mType = modules[dest][0]

        if mType == '%':
            if pulseType: continue # flip flip ignores high pulse
            if "t" in moduleState[dest]:
                moduleState[dest].excl "t"
                for i in modules[dest][1]:
                    pulseStack.add((i, dest, false))
            else:
                moduleState[dest].incl "t"
                for i in modules[dest][1]:
                    pulseStack.add((i, dest, true))

        elif mType == '&':
            if not pulseType:
                moduleState[dest].excl src
            else:
                moduleState[dest].incl src

            if moduleState[dest].len == moduleInputCount[dest]:
                for i in modules[dest][1]:
                    pulseStack.add((i, dest, false))
            else:
                for i in modules[dest][1]:
                    pulseStack.add((i, dest, true))

        elif mType == 'b': # broadcaster
            for i in modules[dest][1]:
                pulseStack.add((i, dest, pulseType))

    return false


proc part1(s: string): string = 
    var r = parseInput(s)
    highPulseCounter = 0
    lowPulseCounter = 0

    var moduleState: Table[string, HashSet[string]]
    var moduleInputCount: CountTable[string]

    for k, v in r:
        moduleState[k] = initHashSet[string]()
        for i in v[1]:
            moduleInputCount.inc i # i has k as an input             

    for _ in 0..<1000:
        r.simulateButtonPress(moduleInputCount, moduleState)

    var res = lowPulseCounter * highPulseCounter
    return $res



## --------------------------------------------------------------------------
# PART 2 !!!


type Module = ref object
    name: string
    kind: char
    outputs: seq[string]
    memory: Table[string, bool]
    state: bool

proc part2(s: string): string = 
    let r = parseInput(s)
    var modules: Table[string, Module]

    for k,v in r:
        modules[k] = Module(
            name: k,
            kind: v[0],
            outputs: v[1],
            memory: initTable[string, bool]()
        )

    let broadcastTargets = modules["broadcaster"].outputs

    for name, module in modules:
        for output in module.outputs:
            if output in modules and modules[output].kind == '&':
                modules[output].memory[name] = false

    var feed: string
    for name, module in modules:
        if "rx" in module.outputs:
            feed = name
            break

    var cycleLengths: Table[string, int]
    var seen: Table[string, int]

    for name, module in modules:
        if feed in module.outputs:
            seen[name] = 0

    var presses = 0

    while true:
        inc presses

        var q: Deque[(string, string, bool)]
        for x in broadcastTargets:
            q.addLast((x, "broadcaster", false))

        while q.len > 0:
            let (target, origin, pulseType) = q.popFirst()
            if target notin modules:
                continue
            var module = modules[target]
            if module.name == feed and pulseType:
                inc seen[origin]

                if origin notin cycleLengths:
                    cycleLengths[origin] = presses
                else:
                    assert presses == seen[origin] * cycleLengths[origin]

            var isSeenAll = true
            for _,k in seen:
                if k == 0:
                    isSeenAll = false
                    break

            if isSeenAll:
                var x = 1
                for _, cycleLen in cycleLengths:
                    x *= cycleLen div math.gcd(x, cycleLen)
                # found!
                return $x

            if module.kind == '%':
                if not pulseType:
                    module.state = not module.state
                    for x in module.outputs:
                        q.addLast((x, module.name, module.state))
            else:
                module.memory[origin] = pulseType
                var outgoing = false
                for _, x in module.memory:
                    if not x:
                        outgoing = true
                        break
                for x in module.outputs:
                    q.addLast((x, module.name, outgoing))

    # unreachable.
    return "0"

run(2023, 20, part1, part2)