import ../../../toolbox

proc parseInput(s: string): Table[string, (int, int, int)] =
    var lines = s.strip.splitLines

    for l in lines:
        var name: string
        var speed, time, restTime: int
        if scanf(
            l,
            "$w can fly $i km/s for $i seconds, but then must rest for $i seconds.",
            name, speed, time, restTime
        ):
            result[name] = (speed, time, restTime)



var part1Ready* = true
proc part1(s: string): string = 
    var info = parseInput(s)

    const raceTime = 2503
    # distance traveled, time to fly, time to rest

    var bestDistance = 0

    for name, (speed, ftime, rtime) in info:
        var dist = 0
        var timeLeft = raceTime
        var flying = true

        while timeLeft > 0:
            var ticks = min(timeLeft, if flying: ftime else: rtime)
            if flying:
                dist += speed * ticks
            flying = not flying
            timeLeft -= ticks

        bestDistance = max(bestDistance, dist)

    return $bestDistance


var part2Ready* = true
proc part2(s: string): string = 
    var info = parseInput(s)

    # name -> distance traveled, status time left, is flying, score
    var rStatus: Table[string, (int, int, bool, int)]
    for name, (speed, ftime, rtime) in info:
        rStatus[name] = (0, ftime, true, 0)

    var timeLeft = 2503
    
    while timeLeft > 0:
        var bestD = 0
        for name, (dt,st,isF,sc) in rStatus:
            if isF:
                rStatus[name][0] += info[name][0]

            dec rStatus[name][1]
            if rStatus[name][1] == 0:
                rStatus[name][2] = not rStatus[name][2]
                if rStatus[name][2]: # flying?
                    rStatus[name][1] = info[name][1]
                else:
                    rStatus[name][1] = info[name][2]                    

        for name, (dt,_,_,_) in rStatus:
            bestD = max(bestD, dt)
        for name, (dt,_,_,_) in rStatus:
            if dt == bestD:
                inc rStatus[name][3]

        dec timeLeft

    var bestScore = 0
    for _, (_,_,_,s) in rStatus: bestScore = max(s, bestScore)

    return $bestScore


run(2015, 14, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)