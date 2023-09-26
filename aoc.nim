#[
    Behavior:
        - Find the first problem that is not solved according to solveStatus.txt
        - If there is no input / statement, download them and stop
        - else, run the program written (using osproc and nim r ...), and test it
        - if the tests pass, submit it to AOC, update solve status and stop.
]#

#? replace(sub = "\t", by = "  ")
import strformat, httpclient, os, strutils, parsexml, streams, osproc


# let starting_year = 2015

var authString = ""
var credentialsFilePath = "credentials.txt"

if fileExists(credentialsFilePath):
    authString = readFile(credentialsFilePath)

if authString == "":
    echo "Credentials file not found or is empty."
    echo "Fill it with your session cookie like this: session=..."
    quit(1)


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

    result = ""
    while true:
        x.next()
        case x.kind
        of xmlCharData:
            result.add(x.charData)
        of xmlElementStart:
            if x.elementName == "code":
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
                result.add "```"
            if x.elementName == "em":
                result.add "* "
            if x.elementName in ["p","li","ul","h1","h2"]:
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
    let cases = parts[0].split("=== ADVENTOFCODE CASE ===")

    for e in cases:
        var r = e.split("=== ADVENTOFCODE SOLUTION ===", 1)
        if r.len == 2:
            result.add (r[0],r[1])


proc extractTestCases(year: int, day: int, problem: string, problemIdx: int = 1, openEditor = true) =
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
            toWrite.add "???"
        if testSolutions.len != 0:
            filledCases = true
    
    if not filledCases: # Use this template by default.
        toWrite.add "=== ADVENTOFCODE CASE ===\n"
        toWrite.add "(())\n"
        toWrite.add "=== ADVENTOFCODE SOLUTION ===\n"
        toWrite.add "0"
    
    var filePath = fmt"cases/{year}/{day}/problem/problem{problemIdx}.txt"
    createFileIfNotExists(filePath)
    writeFile(filePath, toWrite)

    if openEditor:
        discard execCmd(fmt"subl {filePath}") # open sublime.


proc downloadTask(year: int, day: int, isInput: bool = false): string =
    var url = fmt"https://adventofcode.com/{year}/day/{day}"
    if isInput:
        url &= "/input"

    var client = newHttpClient()
    client.headers = newHttpHeaders({
        "Cookie": authString,
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36"
    })


    try:
        let response = client.getContent(url)
        return response
    finally:
        client.close()

    echo "Network failure, unable to download: ",url
    quit(1)

proc setupProblem(year: int, day: int, forceUpdate: bool = false) =
    # Check if we need to download the problem statement:
    if not fileExists(fmt"cases/{year}/{day}/problem/problem1.txt") or forceUpdate:
        var task = downloadTask(year, day)
        let articles = extractArticles(task)

        if articles.len == 1:
            # Focus on problem 1
            let problemStatement = articleToMarkdown(articles[0])
            extractTestCases(year, day, problemStatement, 1, true)
        else:
            # Problem 2 has the same test cases, but different results usually.
            # We could copy the results over from problem 1...
            let problemStatement = articleToMarkdown(articles[1])
            extractTestCases(year, day, problemStatement, 2, true)

    let inputPath = fmt"cases/{year}/{day}/input.txt"
    if not fileExists(inputPath):
        # never download the input twice as it never changes !!!
        var inputData = downloadTask(year, day, isInput = true)
        writeFile(inputPath, inputData)

    let solutionPath = fmt"solutions/{year}/{day}/solution.nim"
    createFileIfNotExists(solutionPath)

    var solutionTemplate = ""
    solutionTemplate.add "import ../../../toolbox\n"
    solutionTemplate.add "\n"
    solutionTemplate.add "var part1Ready* = false\n"
    solutionTemplate.add "proc part1(s: string): string = \n"
    solutionTemplate.add "    discard\n"
    solutionTemplate.add "\n"
    solutionTemplate.add "var part2Ready* = false\n"
    solutionTemplate.add "proc part2(s: string): string = \n"
    solutionTemplate.add "    discard\n"
    solutionTemplate.add "\n"
    solutionTemplate.add fmt"run({year},{day}, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)"

    if readFile(solutionPath).len == 0:
        writeFile(solutionPath, solutionTemplate)
        discard execCmd(fmt"subl {solutionPath}")
    else:
        # Run the solution, get the numbers and submit them.
        echo "Executing solution ..."
        var process = startProcess("nim", workingDir = getCurrentDir(), args = ["r","--hints:off","--warnings:off", solutionPath])
        process.inputStream().write("test")
        process.inputStream().write("moare data")
        process.inputStream().close()
        discard process.waitForExit()
        var result = process.outputStream().readAll()
        # process.close()
        echo result

        # Waiting for some kind of a response, fossa.

setupProblem(2015, 1)