import ../../../toolbox

proc partition[T](a: var openArray[T], low, high: int): int =
    var i = low - 1
    let pivot = a[high]
    for j in low .. high:
        if a[j] < pivot:
            inc i
            swap a[i], a[j]
    swap a[i + 1], a[high]
    return i + 1

proc custom_sort[T](a: var openArray[T], low, high: int) =    
    if low < high:
        var pi = partition(a, low, high)
        custom_sort(a, low, pi - 1)
        custom_sort(a, pi + 1, high)

proc quickSort*[T](a: var openArray[T]) =
    custom_sort(a, 0, a.high)



proc part1(s: string): string = 
    var offset = 0
    var l1 = newSeqOfCap[int32](1000)
    var l2 = newSeqOfCap[int32](1000)

    while offset < s.len:
        var i = offset
        var j = i
        while s[j] != ' ': inc j
        
        l1.add parseUnsignedIntOfSize[int32](s[i..<j])

        offset = j
        offset += 3

        var k = offset
        while k < s.len and s[k] != '\n':
            inc k
        l2.add parseUnsignedIntOfSize[int32](s[offset..<k])
        offset = k+1

    l1.quickSort()
    l2.quickSort()
    var r = 0

    for i in 0..<l1.len:
        r += abs(l1[i] - l2[i])
    return $r


proc part2(s: string): string =
    var t = Tokenizer(s: s, offset: 0)
    var l1 = newSeqOfCap[int32](1000)
    var l2 = initCountTable[int32](700)

    while not t.atEnd():
        var i = t.offset
        var j = t.findNext(' ')

        l1.add parseUnsignedIntOfSize[int32](s[i..<j])

        t.offset = j
        t.advanceFixed(3)

        var k = t.findNext('\n')
        l2.inc parseUnsignedIntOfSize[int32](s[t.offset..<k])
        t.offset = k+1

    var r = 0
    for i in l1:
        r += i * l2[i]
    return $r

run(2024, 1, part1, part2)