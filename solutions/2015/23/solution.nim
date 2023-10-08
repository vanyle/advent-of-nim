import ../../../toolbox

proc parseInput(s: string): seq[(string, string, string)] = 
    var lines = s.strip.splitLines
    var instructions: seq[(string, string, string)] = @[]
    for l in lines:
        var arr = l.split(" ",1)
        var arr2 = arr[1].split(",")

        instructions.add((
            arr[0],
            arr2[0],
            if arr2.len > 1: arr2[1].strip else: ""
        ))

    return instructions

proc part1(s: string): string = 
    var instructions = parseInput(s)

    var reg: Table[string, int]
    reg["a"] = 0
    reg["b"] = 0
    var aptr = 0

    while aptr < instructions.len:
        var (insName, arg1, arg2) = instructions[aptr]
        if insName == "hlf":
            reg[arg1] = reg[arg1] div 2 
        if insName == "tpl":
            reg[arg1] = reg[arg1] * 3
        if insName == "inc":
            inc reg[arg1]
        if insName == "jmp":
            aptr += parseInt(arg1[1..<arg1.len]) *  (if arg1[0] == '+': 1 else: -1)
            echo aptr
            continue
        if insName == "jie":
            if reg[arg1] mod 2 == 0:
                aptr += parseInt(arg2[1..<arg2.len]) * (if arg2[0] == '+': 1 else: -1)
                continue
        if insName == "jio":
            if reg[arg1] == 1:
                aptr += parseInt(arg2[1..<arg2.len]) * (if arg2[0] == '+': 1 else: -1)
                continue

        inc aptr

    return $(reg["b"])


proc part2(s: string): string = 
    var instructions = parseInput(s)

    var reg: Table[string, int]
    reg["a"] = 1
    reg["b"] = 0
    var aptr = 0

    while aptr < instructions.len:
        var (insName, arg1, arg2) = instructions[aptr]
        if insName == "hlf":
            reg[arg1] = reg[arg1] div 2 
        if insName == "tpl":
            reg[arg1] = reg[arg1] * 3
        if insName == "inc":
            inc reg[arg1]
        if insName == "jmp":
            aptr += parseInt(arg1[1..<arg1.len]) *  (if arg1[0] == '+': 1 else: -1)
            continue
        if insName == "jie":
            if reg[arg1] mod 2 == 0:
                aptr += parseInt(arg2[1..<arg2.len]) * (if arg2[0] == '+': 1 else: -1)
                continue
        if insName == "jio":
            if reg[arg1] == 1:
                aptr += parseInt(arg2[1..<arg2.len]) * (if arg2[0] == '+': 1 else: -1)
                continue

        inc aptr

    return $(reg["b"])


run(2015, 23, part1, part2)