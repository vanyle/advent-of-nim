import ../../../toolbox

import json

proc processNode(node: JsonNode): int =
    if node.kind == JFloat:
        return node.fnum.int
    elif node.kind == JInt:
        return node.num
    elif node.kind == JObject:
        var s = 0
        for _,v in node.fields:
            s += processNode(v)
        return s
    elif node.kind == JArray:
        var s = 0
        for i in node.elems:
            s += processNode(i)
        return s
    return 0

var part1Ready* = true
proc part1(s: string): string = 
    var node = parseJson(s.strip)

    return $processNode(node)

proc processNode2(node: JsonNode): int =
    if node.kind == JFloat:
        return node.fnum.int
    elif node.kind == JInt:
        return node.num
    elif node.kind == JObject:        
        var s = 0
        for _,v in node.fields:
            if v.kind == JString and v.str == "red":
                return 0
            s += processNode2(v)

        return s
    elif node.kind == JArray:
        var s = 0
        for i in node.elems:
            s += processNode2(i)
        return s
    return 0

var part2Ready* = true
proc part2(s: string): string = 
    var node = parseJson(s.strip)

    return $processNode2(node)

run(2015, 12, if part1Ready: part1 else: nil, if part2Ready: part2 else: nil)