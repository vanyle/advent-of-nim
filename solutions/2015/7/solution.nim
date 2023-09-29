import ../../../toolbox


type Instruction = object
    operator: string
    var1: string
    var2: string # can by "" if operator is NOT.

proc computeValue(label: string, dependencies: Table[string, Instruction], cache: var Table[string, uint16]): uint16 =
    if label[0] in "0987654321":
        return parseInt(label).uint16
    if label in cache: return cache[label]
    
    # Recursively compute values using the dependencies table
    var source = dependencies[label]
    if source.operator == "NOT":
        let v1 = computeValue(source.var1, dependencies, cache)
        cache[label] = not v1
    elif source.operator == "IS":
        cache[label] = computeValue(source.var1, dependencies, cache)
    else:
        let v1 = computeValue(source.var1, dependencies, cache)
        let v2 = computeValue(source.var2, dependencies, cache)

        if source.operator == "RSHIFT":
            cache[label] = v1 shr v2
        elif source.operator == "LSHIFT":
            cache[label] = v1 shl v2            
        elif source.operator == "OR":
            cache[label] = v1 or v2    
        elif source.operator == "AND":
            cache[label] = v1 and v2    
        else:
            assert false, "Unknown instruction: " & source.operator

    return cache[label]

proc parseDependencies(lines: seq[string]): Table[string, Instruction] =
    var dependencies: Table[string, Instruction]

    for l in lines:
        var ins = l.split(" -> ",1)
        var output = ins[1]
        var elements = ins[0].split(" ", 2)
        var i: Instruction
        if elements.len == 3:
            i = Instruction(
                operator: elements[1],
                var1: elements[0],
                var2: elements[2]
            )
        elif elements.len == 2:
            i = Instruction(
                operator: elements[0], #NOT
                var1: elements[1],
            )
        else:
            i = Instruction(
                operator: "IS",
                var1: elements[0]
            )
        dependencies[output] = i
    return dependencies

var part1Ready* = true
proc part1(s: string): string = 
    var lines = s.strip.splitLines

    var cache: Table[string, uint16]
    var dependencies = parseDependencies(lines)

    var val = computeValue("a", dependencies, cache)

    return $val
    

var part2Ready* = true
proc part2(s: string): string = 
    var lines = s.strip.splitLines

    var cache: Table[string, uint16]
    var dependencies = parseDependencies(lines)

    var val = computeValue("a", dependencies, cache)
    cache.clear()
    cache["b"] = val
    
    val = computeValue("a", dependencies, cache)
    return $val


run(2015, 7, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)