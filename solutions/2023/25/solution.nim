import ../../../toolbox

proc parseInput(s: string): seq[(string, seq[string])] = 
    var ll = s.strip.split("\n")
    for l in ll:
        var els = l.split(": ",1)
        result.add((
            els[0],
            els[1].split(" ")
        ))

proc toTableGraph(s: seq[(string, seq[string])]): Table[string, seq[string]] =
    var tableGraph: Table[string, seq[string]] = initTable[string, seq[string]]()
    
    for (startNode, edges) in s:
        if startNode notin tableGraph:
            tableGraph[startNode] = edges
        else:
            tableGraph[startNode].add(edges)

        for endNode in edges:
            if endNode notin tableGraph:
                tableGraph[endNode] = @[startNode]
            else:
                tableGraph[endNode].add(startNode)

    for k, v in tableGraph:
        tableGraph[k] = v.toHashSet().toSeq()

    return tableGraph

proc findPath(sourceNode: string, sinkNode: string, flow: Table[(string, string), int], graph: Table[string, seq[string]]): seq[string] =
    var visited: HashSet[string] = [sourceNode].toHashSet
    var stack: seq[(string, seq[string])] = @[(sourceNode, @[])]

    while stack.len > 0:
        var (currNode, pathToCurrNode) = stack.pop()
        
        if currNode == sinkNode:
            return pathToCurrNode.concat(@[sinkNode])
        
        for nextNode in graph[currNode]:
            # residual capacity = capacity - flow. the capacity is assumed to be 1 everywhere.
            if nextNode in visited or 1 - flow[(currNode, nextNode)] <= 0:
                continue
            visited.incl(nextNode)
            stack.add((nextNode, concat(pathToCurrNode, @[currNode])))

    if stack.len == 0:
        return @[]

proc fordFulkerson(sourceNode: string, sinkNode: string, tableGraph: Table[string, seq[string]], maxValStop: int): (int, seq[seq[string]]) =
    var flow: Table[(string, string), int]
    # init flow
    for startNode, edges in tableGraph:
        for endNode in edges:
            flow[(startNode, endNode)] = 0
            flow[(endNode, startNode)] = 0

    var maxFlow = 0
    var flowPaths: seq[seq[string]] = @[]

    while true:
        var path = findPath(sourceNode, sinkNode, flow, tableGraph)
        if path.len == 0:
            break
        # We know the max flow of the path is 1.
        for i in 0..<path.len-1:
            flow[(path[i], path[i+1])] += 1
            flow[(path[i+1], path[i])] -= 1
        maxFlow += 1
        flowPaths.add(path)
        if maxFlow >= maxValStop:
            break

    return (maxFlow, flowPaths)

proc part1(s: string): string = 
    var r = parseInput(s)
    var tableGraph = toTableGraph(r)
    var nodeCount = tableGraph.len

    # 1. Construct Graph
    # 2. Run ford fulkerson on pairs of vertices until we get 3 as max flow
    # 3. Cut there.
    var done = false
    var uniqueEdges: seq[(string, string)]
    var nodeOfFirstComponent: string
    var nodeOfSecondComponent: string

    for (startNode, _) in r:
        for (endNode, _) in r:
            if startNode == endNode: continue
            var (maxFlow, flowPaths) = fordFulkerson(startNode, endNode, tableGraph, 99) # stop at 4.

            if maxFlow == 3:
                var sets: seq[seq[(string, string)]]
                for path in flowPaths:
                    for i in 0..<path.len-1:
                        uniqueEdges.add((path[i], path[i+1])) # cut all the edges of the flow paths

                nodeOfFirstComponent = startNode
                nodeOfSecondComponent = endNode
                done = true
                break
        if done:
            break

    # We need to remove the unique edges from the graph
    for edge in uniqueEdges:
        var (startNode, endNode) = edge
        tableGraph[startNode] = tableGraph[startNode].filterIt(it != endNode)
        tableGraph[endNode] = tableGraph[endNode].filterIt(it != startNode)

    # We count the size of a connected component by running a dfs from a node.
    var visited: HashSet[string]
    var stack: seq[string] = @[nodeOfFirstComponent]
    
    while stack.len > 0:
        var currNode = stack.pop()
        if currNode in visited:
            continue
        visited.incl(currNode)
        for nextNode in tableGraph[currNode]:
            stack.add(nextNode)

    var res = (visited.len * (nodeCount - visited.len))
    return $res


proc part2(s: string): string = 
    return part1(s)


run(2023, 25, part1, part2)