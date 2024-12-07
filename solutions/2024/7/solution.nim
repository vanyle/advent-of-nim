import ../../../toolbox

proc parseInput(s: string): seq[(int, seq[int])] = 
    let lines = s.strip.split("\n")
    for l in lines:
        let integers = ints(l, 10)
        result.add((integers[0], integers[1..<integers.len]))


proc canGenerateNumber(target: int, currentResult: int, currentNumIdx: int, nums: seq[int]): bool =
    if currentResult > target:
        return false
    if nums.len <= currentNumIdx:
        return currentResult == target

    let p1 = canGenerateNumber(target, currentResult + nums[currentNumIdx],currentNumIdx + 1, nums)
    let p2 = canGenerateNumber(target, currentResult * nums[currentNumIdx],currentNumIdx + 1, nums)
    return p1 or p2


proc canEquationBeTrue(equation: (int, seq[int])): bool =
    return canGenerateNumber(equation[0], equation[1][0], 1, equation[1])

proc part1(s: string): string = 
    var equations = parseInput(s)
    var count = 0

    for equation in equations:
        if canEquationBeTrue(equation):
            count += equation[0]

    return $count

proc canGenerateNumber2(target: int, currentResult: int, currentNumIdx: int, nums: seq[int]): bool =
    if currentResult > target:
        return false
    if nums.len <= currentNumIdx:
        return currentResult == target

    let p1 = canGenerateNumber2(target, currentResult + nums[currentNumIdx],currentNumIdx + 1, nums)
    let p2 = canGenerateNumber2(target, currentResult * nums[currentNumIdx],currentNumIdx + 1, nums)
    let p3 = canGenerateNumber2(target, parseInt($currentResult & $nums[currentNumIdx]),currentNumIdx + 1, nums)
    return p1 or p2 or p3


proc canEquationBeTrue2(equation: (int, seq[int])): bool =
    return canGenerateNumber2(equation[0], equation[1][0], 1, equation[1])

proc part2(s: string): string = 
    var equations = parseInput(s)
    var count = 0

    for equation in equations:
        if canEquationBeTrue2(equation):
            count += equation[0]

    return $count


run(2024, 7, part1, part2)