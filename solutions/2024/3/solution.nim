import ../../../toolbox

proc part1(s: string): string = 
    var acc = 0

    var i = 0
    var firstNumber = false
    var secondNumber = false
    
    var n1 = 0
    var n2 = 0

    while i < s.len:
        if i+4 <= s.len and isEqual(s[i..<i+4], "mul("):
            firstNumber = true
            n1 = 0
            n2 = 0
            i += 4
            continue
        elif firstNumber:
            if isDigit(s[i]):
                n1 *= 10
                n1 += toDigit(s[i])
                inc i
                continue
            elif s[i] == ',':
                firstNumber = false
                secondNumber = true
                inc i
            else:
                firstNumber = false
                secondNumber = false
        elif secondNumber:
            if isDigit(s[i]):
                n2 *= 10
                n2 += toDigit(s[i])
                inc i
                continue
            elif s[i] == ')':
                acc += n1 * n2
                inc i
            firstNumber = false
            secondNumber = false
        else:
            inc i

    return $acc

proc part2(s: string): string = 
    var acc = 0

    var i = 0
    var firstNumber = false
    var secondNumber = false
    var enabled = true

    var n1 = 0
    var n2 = 0

    while i < s.len:
        if not enabled:
            while i < s.len and s[i] != 'd':
                inc i
            if i+4 <= s.len and isEqual(s[i..<i+4], "do()"):
                i += 4
                enabled = true
                continue

        if enabled:
            if i+7 <= s.len and isEqual(s[i..<i+7], "don't()"):
                i += 7
                enabled = false
                continue

        if enabled:
            if i+4 <= s.len and isEqual(s[i..<i+4], "mul("):
                firstNumber = true
                n1 = 0
                n2 = 0
                i += 4
                continue
            elif firstNumber:
                if isDigit(s[i]):
                    n1 *= 10
                    n1 += toDigit(s[i])
                    inc i
                    continue
                elif s[i] == ',':
                    firstNumber = false
                    secondNumber = true
                    inc i
                else:
                    firstNumber = false
                    secondNumber = false
            elif secondNumber:
                if isDigit(s[i]):
                    n2 *= 10
                    n2 += toDigit(s[i])
                    inc i
                    continue
                elif s[i] == ')':
                    acc += n1 * n2
                    inc i
                firstNumber = false
                secondNumber = false
            else:
                inc i
        else:
            inc i


    return $acc


run(2024, 3, part1, part2)