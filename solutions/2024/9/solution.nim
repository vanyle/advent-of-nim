import ../../../toolbox

proc parseInput(s: string): string = 
    return s.strip()

proc part1(s: string): string = 
    var r = parseInput(s)
    var fs: seq[uint16]

    var isEmpty = false
    var fileId: uint16 = 1

    for i in 0..<s.len:
        let d = toDigit(s[i])
        for j in 0..<d:
            if isEmpty:
                fs.add(0)
            else:
                fs.add(fileId)

        isEmpty = not isEmpty
        if not isEmpty:
            inc fileId

    var firstFreeSpace = 0
    while fs[firstFreeSpace] != 0:
        inc firstFreeSpace

    var firstUsedSpace = fs.len-1
    while fs[firstUsedSpace] == 0:
        dec firstUsedSpace


    while firstFreeSpace < fs.len and firstUsedSpace >= 0:
        assert fs[firstFreeSpace] == 0
        assert fs[firstUsedSpace] != 0

        if firstUsedSpace <= firstFreeSpace:
            break

        swap(fs[firstUsedSpace], fs[firstFreeSpace])
        
        while firstFreeSpace < fs.len and fs[firstFreeSpace] != 0:
            inc firstFreeSpace
        while firstUsedSpace >= 0 and fs[firstUsedSpace] == 0:
            dec firstUsedSpace

    # Compute checksum
    var checksum = 0
    for i in 0..<fs.len:
        if fs[i] == 0:
            break
        checksum += i * (fs[i].int-1)

    return $checksum




proc part2(s: string): string = 
    var r = parseInput(s)
    var fs: seq[uint16]

    var isEmpty = false
    var fileId: uint16 = 1

    for i in 0..<s.len:
        let d = toDigit(s[i])
        for j in 0..<d:
            if isEmpty:
                fs.add(0)
            else:
                fs.add(fileId)

        isEmpty = not isEmpty
        if not isEmpty:
            inc fileId


    var blockProcessed = fileId
    var position = fs.len

    while position >= 0:
        dec position
        while position >= 0 and fs[position] == 0:
            dec position
        if position < 0: break

        blockProcessed = fs[position]

        var sizeOfChunk = 0
        while position >= 0 and fs[position] == blockProcessed:
            inc sizeOfChunk
            dec position
        inc position

        # Search for the first free spot of size sizeOfChunk
        var i = 0
        var currentFreeSpace = 0
        while i <= position and currentFreeSpace < sizeOfChunk:
            if fs[i] == 0:
                inc currentFreeSpace
            else:
                currentFreeSpace = 0
            inc i

        dec i
        if i >= position: # no free spot found
            continue

        for j in 0..<sizeOfChunk:
            swap(fs[position+j], fs[i-j])

    # Compute checksum
    var checksum = 0
    for i in 0..<fs.len:
        if fs[i] == 0: continue
        checksum += i * (fs[i].int-1)

    return $checksum


run(2024, 9, part1, part2)