import ../../../toolbox

import z3/z3_api # pretty big dependency here...

type V2f = tuple[x: float, y: float]
type Area = tuple[x: float, y: float, x2: float, y2: float]

# Mini z3 bindings, because Nim v2 support is not available for z3...

proc to_Z3_ast(ctx: Z3_context, v: Z3_ast): Z3_ast = v

proc to_Z3_ast(ctx: Z3_context, v: bool, sort: Z3_sort = nil.Z3_sort): Z3_ast =
  if v: Z3_mk_true(ctx) else: Z3_mk_false(ctx)

proc to_Z3_ast(ctx: Z3_context, v: SomeInteger, sort: Z3_sort = nil.Z3_sort): Z3_ast =
  Z3_mk_int64(ctx, v.clonglong, sort)


template binop(name: untyped, Tin, Tout: untyped, fn: untyped, helper: untyped) =
  template name*(a1, a2: Tin): Tout =
    helper(ctx, fn, a1, a2).Tout

  template name*[T](a1: Tin, a2: T): Tout =
    helper(ctx, fn, a1, to_Z3_ast(ctx, a2, Z3_get_sort(ctx, a1)))

  template name*[T](a1: T, a2: Tin): Tout =
    helper(ctx, fn, to_Z3_ast(ctx, a1, Z3_get_sort(ctx, a2)), a2)

template helper_var(ctx: Z3_context, fn: untyped, v1, v2: Z3_ast): Z3_ast =
    let vs = [v1, v2]
    fn(ctx, 2, unsafeAddr vs[0])

template helper_bin(ctx: Z3_context, fn: untyped, v1, v2: Z3_ast): Z3_ast =
    fn(ctx, v1, v2)

binop(`==`,  Z3_ast,Z3_ast, Z3_mk_eq, helper_bin)
binop(`+`, Z3_ast, Z3_ast, Z3_mk_add, helper_var)
binop(`*`, Z3_ast, Z3_ast, Z3_mk_mul, helper_var)
binop(`-`, Z3_ast, Z3_ast, Z3_mk_sub, helper_var)

template assert(s: Z3_solver, e: Z3_ast) =
    Z3_solver_assert(ctx, s, e)

template check*(s: Z3_solver): Z3_lbool =
    Z3_solver_check(ctx, s)

template get_model*(s: Z3_Solver): Z3_model =
    Z3_solver_get_model(ctx, s)

proc eval(ctx: Z3_Context, model: Z3_model, v: Z3_ast): Z3_ast =
  var r: Z3_ast
  discard Z3_model_eval(ctx, model, v, true, addr r)
  return r

proc evalInt64(ctx: Z3_Context, model: Z3_model, v: Z3_ast): int64 =
  var c: clonglong
  discard Z3_get_numeral_int64(ctx, ctx.eval(model, v), addr c)
  return c

proc mk_var(ctx: Z3_Context, name: string, ty: Z3_sort): Z3_ast =
  let sym = Z3_mk_string_symbol(ctx, name)
  return Z3_mk_const(ctx, sym, ty)

func cross*(a: V2f, b: V2f): float {.inline.} =
    return a.x * b.y - a.y * b.x

proc collideSolver(p1,p2,v1,v2: V2f, testArea: static[Area]): bool =
    if v1.cross(v2) == 0:
        return false

    let pc1 = p1.cross(v1)
    let pc2 = p2.cross(v2)
    let nor = v1.cross(v2)

    let x = (pc2 * v1.x - pc1 * v2.x) / nor
    let y = (pc2 * v1.y - pc1 * v2.y) / nor
    
    if (x - p1.x) * v1.x < 0: return false
    if (y - p1.y) * v1.y < 0: return false
    if (x - p2.x) * v2.x < 0: return false
    if (y - p2.y) * v2.y < 0: return false

    if x >= testArea.x and x <= testArea.x2:
        if y >= testArea.y and y <= testArea.y2:
            return true

    return false


proc part1(s: string): string = 
    var particles: seq[(V2f, V2f)] = newSeqOfCap[(V2f, V2f)](300)

    const testArea: Area = (
        200000000000000.float, 200000000000000.float,
        400000000000000.float, 400000000000000.float
    )

    for l in s.fastSplit('\n'):
        if l.len == 0: continue
        var ii = ints(l, 6)
        particles.add((
            (ii[0].float, ii[1].float),
            (ii[3].float, ii[4].float)
        ))

    var ccounter = 0
    for i in 0..<particles.len:
        for j in 0..<i:
            if collideSolver(
                particles[i][0], particles[j][0],
                particles[i][1], particles[j][1],
                testArea
            ):
                inc ccounter

    return $ccounter

proc part2(s: string): string = 
    # Turn's out the equation system is a bit overconstrainted.
    # We only need like 2 or 3 lines to solve it.

    var i = 0
    var data = newSeqOfCap[array[6, int]](6)

    for l in s.fastSplit('\n'):
        var ii = ints(l, 6)

        var aa: array[6, int]
        for j in 0..5:
            aa[j] = ii[j]
        data.add aa

        # We should have enough data for a solve now.
        inc i
        if i >= 5:
            break


    # Custom Z3 code for Nim 2.0 support ...
    let cfg = Z3_mk_config()
    Z3_set_param_value(cfg, "model", "true");
    let ctx = Z3_mk_context(cfg)
    let fpa_rm {.used.} = Z3_mk_fpa_round_nearest_ties_to_even(ctx)
    Z3_del_config(cfg)

    var s = Z3_mk_solver(ctx)
    let xr =   ctx.mk_var("xr", Z3_mk_int_sort(ctx))
    let yr =   ctx.mk_var("yr", Z3_mk_int_sort(ctx))
    let zr =   ctx.mk_var("zr", Z3_mk_int_sort(ctx))
    let vxr =  ctx.mk_var("vxr", Z3_mk_int_sort(ctx))
    let vyr =  ctx.mk_var("vyr", Z3_mk_int_sort(ctx))
    let vzr =  ctx.mk_var("vzr", Z3_mk_int_sort(ctx))
    let zero = ctx.mk_var("zero", Z3_mk_int_sort(ctx))

    s.assert zero == 0

    for i in 0..<min(data.len, 5):
        var x  = data[i][0]
        var y  = data[i][1]
        var z  = data[i][2]
        var vx = data[i][3]
        var vy = data[i][4]
        var vz = data[i][5]

        s.assert( (xr - x) * (vy - vyr) - (yr - y) * (vx - vxr) == zero)
        s.assert( (yr - y) * (vz - vzr) - (zr - z) * (vy - vyr) == zero)

    assert s.check() == Z3_L_TRUE

    var model = s.get_model()
    var sxr = ctx.evalInt64(model, xr)
    var syr = ctx.evalInt64(model, yr)
    var szr = ctx.evalInt64(model, zr)
    var res = sxr + syr + szr

    Z3_del_context(ctx)


    return $res

run(2023, 24, part1, part2)