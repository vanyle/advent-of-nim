#[
    Behavior:
        - Find the first problem that is not solved according to solveStatus.txt
        - If there is no input / statement, download them and stop
        - else, run the program written (using osproc and nim r ...), and test it
        - if the tests pass, submit it to AOC, update solve status and stop.
]#

#? replace(sub = "\t", by = "  ")
import strformat, httpclient, os, strutils, parsexml, streams, osproc, net
import tables, parseopt, algorithm, json, times

type ProblemId = object
    year: int
    day: int
    idx: int
type SolveStatus = Table[ProblemId, bool]

type GlobalState = object
    settings: Table[string, string]
    solveStatus: Table[ProblemId, bool]
    authCookie: string
    rerun = false # is the problem already solved or not?

var gstate: GlobalState
const credentialsFilePath = "credentials.txt"
const settingsPath = "settings.json"
const solveStatusPath = "solveStatus.txt"

# ------------------------------

proc saveSolveStatus(solveStatus: SolveStatus, filename = solveStatusPath) =
    var serializedSolvedStatus = ""
    var keys: seq[ProblemId]
    for key, _ in solveStatus:
        keys.add key
    
    keys.sort(proc(a, b: ProblemId): int =
        if a.year != b.year: return cmp(a.year, b.year)
        if a.day != b.day: return cmp(a.day, b.day)
        return cmp(a.idx, b.idx)
    )

    for k in keys:
        serializedSolvedStatus.add fmt"{k.year} {k.day} {k.idx} {solveStatus[k]}" & "\n"

    writeFile(filename, serializedSolvedStatus)

proc getSolveStatus(filename = solveStatusPath): SolveStatus =
    if not fileExists(filename):
        var ss = initTable[ProblemId, bool]()
        saveSolveStatus(ss, filename)
        return ss

    var data = readFile(filename)
    for line in data.splitLines:
        var parts = line.strip().splitWhitespace(4)
        if parts.len != 4:
            continue
        var pid: ProblemId
        pid.year = parseInt(parts[0])
        pid.day = parseInt(parts[1])
        pid.idx = parseInt(parts[2])
        result[pid] = parts[3] == "true"

proc loadConfig() =
    if not fileExists(settingsPath):
        writeFile(settingsPath, "{}")

    var jsonString = readFile(settingsPath)
    let jsonObject = parseJson(jsonString)
    for k, v in jsonObject.pairs:
        if v.kind == JString:
            gstate.settings[k] = v.str
        elif v.kind == JBool or v.kind == JInt or v.kind == JFloat:
            gstate.settings[k] = $v
        # ignore other types.

proc openTextEditor(filepath: string) =
    let textEditor = gstate.settings.getOrDefault("editor.command", "subl")
    discard execCmdEx(
        fmt"{textEditor} {filePath}",
        workingDir = getCurrentDir(),
        options = {poEvalCommand, poUsePath}
    ) # open text editor

proc hasFileContent(path: string): bool =
    if not fileExists(path): return false
    return getFileSize(path) != 0

proc extractArticles(source: string): seq[string] =
    # Extract string that is between:
    # <article class="day-desc">
    # </article>

    var results: seq[string]
    var i = 0

    let startCue = "<article class=\"day-desc\">"
    let endCue = "</article>"

    while i < source.len and i != -1:
        var s_idx = source.find(startCue, i) + startCue.len
        if s_idx == -1 + startCue.len: break
        var e_idx = source.find(endCue, s_idx)
        results.add(source[s_idx..<e_idx])
        i = e_idx + endCue.len

    return results

proc articleToMarkdown(source: string): string =
    # h2 -> ##
    # p -> nothing, line breaks.
    # etc... strip most tags and add formating for some of them
    var x: XmlParser
    x.open(newStringStream(source), "")

    var inPre = false

    result = ""
    while true:
        x.next()
        case x.kind
        of xmlCharData:
            result.add(x.charData)
        of xmlElementStart:
            if x.elementName == "code":
                if inPre:
                    result.add "\n"
                else:
                    result.add "`"
            if x.elementName == "pre":
                inPre = true
                result.add "```"
            if x.elementName == "em":
                result.add "*"
            if x.elementName == "h2":
                result.add "## "
            if x.elementName == "li":
                result.add "- "
            if x.elementName == "ul":
                result.add "\n"
        of xmlElementEnd:
            if x.elementName == "code":
                if inPre:
                    result.add "`"
            if x.elementName == "pre":
                inPre = false
                result.add "```\n"
            if x.elementName == "em":
                result.add "* "
            if x.elementName in ["p", "li", "ul", "h1", "h2"]:
                result.add "\n"
            if x.elementName == "h2":
                result.add "\n" # two line breaks after a title.

        of xmlEof: break
        else:
            discard

proc createFileIfNotExists(path: string) =
    if not dirExists(parentDir(path)):
        createDir(parentDir(path))
    if not fileExists(path):
        writeFile(path, "")

proc getTestSolutionPairs(year: int, day: int, problemIdx: int): seq[(string, string)] =
    # Return (test data, test solution) for a given advent of code problem.
    let problemFile = fmt"cases/{year}/{day}/problem/problem{problemIdx}.txt"
    if not fileExists(problemFile): return @[]
    let content = readFile(problemFile)

    let parts = content.split("=== ADVENTOFCODE CASE ===", 1)


    if parts.len == 1: return @[]
    let cases = parts[1].split("=== ADVENTOFCODE CASE ===")

    for e in cases:
        var r = e.split("=== ADVENTOFCODE SOLUTION ===", 1)
        if r.len == 2:
            result.add (r[0].strip(), r[1].strip())


proc extractTestCases(year: int, day: int, problem: string, problemIdx: int = 1,
        openEditor = true) =
    # Not possible in general without humain input ...
    var toWrite = "=== PROBLEM STATEMENT ====\n"
    toWrite.add problem
    toWrite.add "\nAdd your test cases below. You can add multiple cases if you need\n"

    var filledCases = false
    if problemIdx == 2:
        # Recycle the cases from the easy version but change the solutions.
        let testSolutions = getTestSolutionPairs(year, day, 1)
        for (t, s) in testSolutions:
            toWrite.add "=== ADVENTOFCODE CASE ===\n"
            toWrite.add t & "\n"
            toWrite.add "=== ADVENTOFCODE SOLUTION ===\n"
            toWrite.add "???\n"
        if testSolutions.len != 0:
            filledCases = true

    if not filledCases: # Use this template by default.
        toWrite.add "=== ADVENTOFCODE CASE ===\n"
        toWrite.add "(())\n"
        toWrite.add "=== ADVENTOFCODE SOLUTION ===\n"
        toWrite.add "0"

    var filePath = fmt"cases/{year}/{day}/problem/problem{problemIdx}.txt"
    
    createFileIfNotExists(filePath)

    if not hasFileContent(filePath): # Don't overwrite the test cases!
        writeFile(filePath, toWrite)

    if openEditor:
        openTextEditor(filePath)

proc querySolution(year: int, day: int, idxToSolve: int, input: string): string =
    let solutionPath = fmt"solutions/{year}/{day}/solution.nim"

    if not fileExists(solutionPath):
        return ""

    var isSpeed = gstate.settings.getOrDefault("speed", "false") == "true"

    var args: seq[string] = @["r"]

    if isSpeed:
        let defaultSpeedArgs = [
            "--hints:off",
            "--warnings:off",
            "-d:danger",
            "--opt:speed",
            "--passL:-flto=1",
            "--passC=-flto=1", # fast linking and no warnings!
            "--passC:-w",
            "--passL:-w"
        ]
        if "run.speed" in gstate.settings:
            args.add (gstate.settings["run.speed"].splitWhitespace)
        else:
            args.add defaultSpeedArgs
    else:
        let defaultArgs = [
            "--hints:off",
            "--warnings:off",
        ]
        if "run.default" in gstate.settings:
            args.add (gstate.settings["run.default"].splitWhitespace)
        else:
            args.add defaultArgs
        
    args.add solutionPath

    var process = startProcess(
            "nim", workingDir = getCurrentDir(),
            args = args,
            options = {poUsePath})

    process.inputStream().write(input)
    process.inputStream().close()
    var lines: seq[string]
    try:
        while not process.outputStream().atEnd():
            var line = process.outputStream().readLine()
            echo line
            lines.add line
    except:
        discard # the pipe has been ended.

    discard process.waitForExit()

    var errs = process.errorStream().readAll()
    process.close()
    var programResult = ""

    if errs.len != 0:
        echo "Error were produced during the execution:"
        echo errs

    let seek = fmt"Part {idxToSolve} result:"
    for line in lines:
        if line.startswith(seek):
            programResult = line[seek.len..<line.len].strip()

    return programResult

proc downloadTask(year: int, day: int, isInput: bool = false): string =
    var url = fmt"https://adventofcode.com/{year}/day/{day}"
    if isInput:
        url &= "/input"

    # var ctx = newContext(verifyMode=CVerifyNone)
    var client = newHttpClient()
    client.headers = newHttpHeaders({
        "Cookie": gstate.authCookie,
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36"
    })

    when defined(macosx):
        var r = execCmdEx(fmt"curl -sSL --cookie {gstate.authCookie} {url}")
        return r.output
    else:
        try:
            let response = client.getContent(url)
            return response
        except Exception as err:
            echo "Error: ",err.msg
            echo "Is your cookie valid?"
            echo err.getStackTrace()
        finally:
            client.close()

        echo "Network failure, unable to download: ", url
        quit(0)

proc submitAnswer(year: int, day: int, problemIdx: int, solution: string): (bool, string) =
    # POST https://adventofcode.com/2015/day/1/answer
    # level={problemIdx}&answer={solution}
    var client = newHttpClient()
    client.headers = newHttpHeaders({
        "Cookie": gstate.authCookie,
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36",
        "Content-Type": "application/x-www-form-urlencoded"
    })

    let body = fmt"level={problemIdx}&answer={solution}" & "\n"
    var r = ""
    try:
        let response = client.request(
            fmt"https://adventofcode.com/{year}/day/{day}/answer",
            httpMethod = HttpPost,
            body = body
        )
        r = response.bodyStream.readAll()
        
        # Code to detect if the level was already completed if needed.
        # if "<p>You don't seem to be solving the right level.":
        #     discard
    except:
        discard
    finally:
        client.close()

    if "<p>That's the right answer!" in r:
        return (true, "")
    else:
        if "is too low" in r:
            return (false, "low")
        elif "is too high" in r:
            return (false, "high")

    return (false, "???")

proc setupProblem(year: int, day: int) =
    # We try to perform as little downloads as possible from the
    # website while still updating the files properly when needed.
    let currentTime = now()
    let currentYear = currentTime.year()
    let currentMonth = currentTime.month().int # january = 1
    let currentDay = currentTime.monthday()

    if currentYear < year or (currentYear == year and currentMonth < 12) or
            (currentYear == year and currentMonth == 12 and currentDay < day):
        echo "The next advent of code problem is not available yet."
        echo "You are trying to solve: ", year,",",day 
        quit(0)

    var idxToSolve = 1

    var task: string
    var articles: seq[string]
    var noEdit = gstate.settings.getOrDefault("noedit", "false") == "true"

    if not hasFileContent(fmt"cases/{year}/{day}/problem/problem1.txt"):
        task = downloadTask(year, day)

        articles = extractArticles(task)

        if articles.len == 1:
            # Focus on problem 1
            let problemStatement = articleToMarkdown(articles[0])
            extractTestCases(year, day, problemStatement, 1, not noEdit)
    if not hasFileContent(fmt"cases/{year}/{day}/problem/problem2.txt"):
        if task == "":
            task = downloadTask(year, day)
            articles = extractArticles(task)
        if articles.len == 2:
            # Problem 2 has the same test cases, but different results usually.
            # We could copy the results over from problem 1...
            gstate.solveStatus[ProblemId(year: year, day: day, idx: 1)] = true
            saveSolveStatus(gstate.solveStatus)

            idxToSolve = 2
            let problemStatement = articleToMarkdown(articles[1])
            extractTestCases(year, day, problemStatement, 2, not noEdit)
    else:
        # the fact that we know the problem statement
        # for part 2 means that part 1 is solved.
        idxToSolve = 2

    let inputPath = fmt"cases/{year}/{day}/input.txt"
    var inputData = ""
    if not fileExists(inputPath):
        # never download the input twice as it never changes !!!
        inputData = downloadTask(year, day, isInput = true)
        writeFile(inputPath, inputData)
    else:
        inputData = readFile(inputPath)

    let solutionPath = fmt"./solutions/{year}/{day}/solution.nim"
    createFileIfNotExists(solutionPath)

    var solutionTemplate = ""
    solutionTemplate.add "import ../../../toolbox\n"
    solutionTemplate.add "\n"
    solutionTemplate.add "proc parseInput(s: string): seq[string] = \n"
    solutionTemplate.add "    return s.strip.split(\"\\n\")"
    solutionTemplate.add "\n"
    solutionTemplate.add "\n"    
    solutionTemplate.add "proc part1(s: string): string = \n"
    solutionTemplate.add "    var r = parseInput(s)\n"
    solutionTemplate.add "\n"
    solutionTemplate.add "\n"
    solutionTemplate.add "\n"
    solutionTemplate.add "proc part2(s: string): string = \n"
    solutionTemplate.add "    var r = parseInput(s)\n"
    solutionTemplate.add "\n"
    solutionTemplate.add "\n"
    solutionTemplate.add fmt"run({year}, {day}, part1, part2)"

    if readFile(solutionPath).len == 0:
        writeFile(solutionPath, solutionTemplate)
        openTextEditor(solutionPath)
    else:
        # Run the solution, get the numbers and submit them.
        
        # Get the test data.
        var testData = getTestSolutionPairs(year, day, idxToSolve)

        if testData.len == 0:
            echo "No test data found."

        var allCorrect = true
        echo fmt"Executing solution for {year}/{day}"
        for i in 0..<testData.len:
            var (test, solution) = testData[i]
            var programResult = querySolution(year, day, idxToSolve, test)

            if programResult == "":
                allCorrect = false
                echo fmt"Program for solving {year}/{day} (part {idxToSolve}) is not finished!"
                # subl -n left_file right_file --command "new_pane"
                openTextEditor(solutionPath)
                break

            if programResult != solution:
                allCorrect = false
                echo "Program is not correct !"
                echo "Got: ", programResult
                echo "Expected: ", solution
                break
            else:
                echo fmt"TEST {i} PASSED"

        # Waiting for some kind of a response, fossa.
        if allCorrect:
            echo "Program might be correct (the test are passing.)"
            var programResult = querySolution(year, day, idxToSolve, inputData)
            if programResult.strip().len == 0:
                echo "There is nothing to submit, check your program."
                return

            if gstate.rerun:
                return

            echo "Submit it? (y/n): "
            var line = stdin.readLine()
            if line == "y":
                var (isok, reason) = submitAnswer(year, day, idxToSolve, programResult)
                if isok:
                    echo "CORRECT !"
                    gstate.solveStatus[ProblemId(year: year, day: day, idx: idxToSolve)] = true
                    saveSolveStatus(gstate.solveStatus)
                else:
                    echo "NOT CORRECT :'("
                    echo "Your answer is too ",reason
            else:
                echo fmt"Not submitting. Go to https://adventofcode.com/{year}/day/{day}/"
                echo fmt"for manual submit if you want."
                echo fmt"Was this problem already solved ? (y/n)"
                line = stdin.readLine()
                if line == "y":
                    gstate.solveStatus[ProblemId(year: year, day: day, idx: idxToSolve)] = true
                    saveSolveStatus(gstate.solveStatus)

proc main() =
    if fileExists(credentialsFilePath):
        gstate.authCookie = readFile(credentialsFilePath)
    else:
        writeFile(credentialsFilePath, "session=...\n")


    if gstate.authCookie.len <= 20:
        echo fmt"Credentials file not found, is empty or incorrectly formatted. ({credentialsFilePath})"
        echo "Fill it with your advent of code session cookie like this: session=..."
        echo "You can find it in the chrome developer console (Network Tab) when checking the advent of code website."
        quit(0)

    gstate.solveStatus = getSolveStatus()
    loadConfig()

    # Start by finding the first unsolved problem:
    var solveYear = gstate.settings.getOrDefault("startingYear", "2015").parseInt
    var solveDay = 1

    var p = initOptParser(quoteShellCommand(commandLineParams()))
    var yearSpecified = false

    while true:
        p.next()
        case p.kind:
        of cmdEnd: break
        of cmdArgument:
            discard
        of cmdLongOption, cmdShortOption:
            var k = p.key
            if k == "d" or k == "day":
                solveDay = parseInt(p.val)
                gstate.rerun = true
            elif k == "y" or k == "year":
                solveYear = parseInt(p.val)
                yearSpecified = true
            elif k == "noedit":
                gstate.settings["noedit"] = "true"
            elif k == "speed":
                gstate.settings["speed"] = "true"

    if not gstate.rerun:
        if not yearSpecified: # auto detect day + year
            for pid, status in gstate.solveStatus:
                if pid.year > solveYear:
                    solveYear = pid.year
                    solveDay = pid.day
                if pid.year >= solveYear and pid.day > solveDay:
                    solveDay = pid.day
                    solveYear = pid.year
        else: # auto detect day
            for pid, status in gstate.solveStatus:
                if pid.year == solveYear and pid.day > solveDay:
                    solveDay = pid.day

    if gstate.rerun or ProblemId(year: solveYear, day: solveDay, idx: 2) notin gstate.solveStatus:
        setupProblem(solveYear, solveDay)
    else:
        # Add 1.
        if solveDay < 25: inc solveDay
        else:
            inc solveYear
            solveDay = 1
        setupProblem(solveYear, solveDay)

main()