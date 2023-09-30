import ../../../toolbox

proc isValid(pwd: array[8, int]): bool =
    # requirements
    # 8 letter lowercase (a-z <=> 0-26)
    # cde (3 increasing in a row)
    # no i,o,l
    # 2 different non-overlapping pairs of letters (aa, dd)

    const iL: int = cast[int]('i') - cast[int]('a')
    const oL: int = cast[int]('o') - cast[int]('a')
    const lL: int = cast[int]('l') - cast[int]('a')


    var f = false
    for idx in 0..<pwd.len-2:
        if pwd[idx] - pwd[idx+1] == -1 and pwd[idx+1] - pwd[idx+2] == -1:
            f = true
            break
    
    if not f: return false

    var dC: set[0..26]
    var i = 0
    while i < pwd.len-1:
        if pwd[i] == pwd[i+1] and
            (i == 0 or pwd[i] != pwd[i-1]) and
            (i == pwd.len-2 or pwd[i+1] != pwd[i+2]) and
            pwd[i] notin dC:
            dC.incl pwd[i]
            inc i
        inc i
    if dC.len < 2: return false

    for idx in 0..<pwd.len:
        if pwd[idx] == iL or pwd[idx] == oL or pwd[idx] == lL:
            return false

    return true

proc nextValid(pwd: array[8, int]): array[8, int] =
    var newPwd: array[8,int] = pwd

    while true:
        for i in countdown(pwd.len - 1, 0):
            inc newPwd[i]
            if newPwd[i] >= 26:
                newPwd[i] = 0
            else:
                break
        if isValid(newPwd): break

    return newPwd

var part1Ready* = true
proc part1(s: string): string = 
    var pwd = s.strip
    var npwd: array[8, int]
    for i in 0..<pwd.len:
        npwd[i] = cast[int](pwd[i]) - cast[int]('a')

    npwd = nextValid(npwd)

    for i in 0..<npwd.len:
        result.add(
            cast[char](npwd[i] + cast[int]('a'))
        )


var part2Ready* = true
proc part2(s: string): string = 
    var pwd = s.strip
    var npwd: array[8, int]
    for i in 0..<pwd.len:
        npwd[i] = cast[int](pwd[i]) - cast[int]('a')

    npwd = nextValid(npwd)
    npwd = nextValid(npwd)

    for i in 0..<npwd.len:
        result.add(
            cast[char](npwd[i] + cast[int]('a'))
        )

run(2015, 11, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)