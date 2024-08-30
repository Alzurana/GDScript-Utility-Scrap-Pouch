## A collection of useful things, shaping functions and math stuffs
##
## There's really not that much to say here. Interpolation stuff, math stuff such as a universal
## logarithm because godot does not supply it. Anything generic I think could be useful goes here.
## Adding stuff should only be done when it's actually needed and it should always be documented.
## Honestly I did forget how some of these math functions work internally, just that they work,
## so be warned @myself should I come back and think I'd need to refactor some of these.
class_name Utils


#*************************************************************************
## Bezier alike in a graph from 0 to 1
##
## a and b give the slope at start and end
static func bezier3(a: float, b: float, x: float) -> float:
	var s := 1.0 - x
	var x2 := x * x
	var x3 := x2 * x
	var s2 := s * s
	var A := 3.0 * a * s2 * x
	var B := 3.0 * b * s * x2
	return A + B + x3


#*************************************************************************
# Interpolation methods
#

## t is a value that goes from 0 to 1 to interpolate in a C1 continuous way across uniformly sampled data points.
## when t is 0, this will return B.  When t is 1, this will return C.  Inbetween values will return an interpolation
## between B and C.  A and B are used to calculate slopes at the edges.
static func cubic_hermite(A: float, B: float, C: float, D: float, t: float) -> float:
	var a := -A / 2.0 + (3.0 * B) / 2.0 - (3.0 * C) / 2.0 + D / 2.0
	var b := A - (5.0 * B) / 2.0 + 2.0 * C - D / 2.0
	var c := -A / 2.0 + C / 2.0
	var d := B
	return a * t * t * t + b * t * t + c * t + d


## t is a value that goes from 0 to 1 to interpolate in a C1 continuous way across uniformly sampled data points.
## when t is 0, this will return B.  When t is 1, this will return C.  Inbetween values will return an interpolation
## between B and C.  A and B are used to calculate slopes at the edges.
static func cubic_hermite_vec2(A: Vector2, B: Vector2, C: Vector2, D: Vector2, t: Vector2) -> Vector2:
	var ret := Vector2.ZERO;
	ret.x = cubic_hermite(A.x, B.x, C.x, D.x, t.x)
	ret.y = cubic_hermite(A.y, B.y, C.y, D.y, t.y)
	return ret


## t is a value that goes from 0 to 1 to interpolate in a C1 continuous way across uniformly sampled data points.
## when t is 0, this will return B.  When t is 1, this will return C.  Inbetween values will return an interpolation
## between B and C.  A and B are used to calculate slopes at the edges.
static func cubic_hermite_vec3(A: Vector3, B: Vector3, C: Vector3, D: Vector3, t: Vector3) -> Vector3:
	var ret := Vector3.ZERO;
	ret.x = cubic_hermite(A.x, B.x, C.x, D.x, t.x)
	ret.y = cubic_hermite(A.y, B.y, C.y, D.y, t.y)
	ret.z = cubic_hermite(A.z, B.z, C.z, D.z, t.z)
	return ret


## expects (at least) an array with 16 values, like a 4x4 matrix with x,y values
## means the first 4 values should be coordinates 0:0 1:0 2:0 3:0 then continuing with
## 0:1 1:1 2:1 3:1 where x:y are the coordinates
static func bicubic_hermite(m: PackedFloat32Array, t: Vector2) -> float:
	var A := cubic_hermite(m[0], m[1], m[2], m[3], t.x)
	var B := cubic_hermite(m[4], m[5], m[6], m[7], t.x)
	var C := cubic_hermite(m[8], m[9], m[10], m[11], t.x)
	var D := cubic_hermite(m[12], m[13], m[14], m[15], t.x)
	return cubic_hermite(A, B, C, D, t.y)


## t is a value that goes from 0 to 1 to interpolate between Value1 to Value2 with a hermite interpolation,
## determining the slope of the curve on the tangent value
static func hermite(value1: float, tangent1: float, value2: float, tangent2: float, t: float) -> float:
	var A := (2.0 * value1 - 2.0 * value2 + tangent1 + tangent2)
	var B := (3.0 * value2 - 3.0 * value1 - 2.0 * tangent1 - tangent2)
	return A * (t * t * t) + B * (t * t) + tangent1 * (t) + value1


## t is a value that goes from 0 to 1 to interpolate between Value1 to Value2 with a hermite interpolation,
## determining the slope of the curve on the tangent value
static func hermite_vec2(value1: Vector2, tangent1: Vector2, value2: Vector2, tangent2: Vector2, t: Vector2) -> Vector2:
	var ret := Vector2.ZERO
	ret.x = hermite(value1.x, tangent1.x, value2.x, tangent2.x, t.x)
	ret.y = hermite(value1.y, tangent1.y, value2.y, tangent2.y, t.y)
	return ret


## t is a value that goes from 0 to 1 to interpolate between Value1 to Value2 with a hermite interpolation,
## determining the slope of the curve on the tangent value
static func hermite_vec3(value1: Vector3, tangent1: Vector3, value2: Vector3, tangent2: Vector3, t: Vector3) -> Vector3:
	var ret := Vector3.ZERO
	ret.x = hermite(value1.x, tangent1.x, value2.x, tangent2.x, t.x)
	ret.y = hermite(value1.y, tangent1.y, value2.y, tangent2.y, t.y)
	ret.z = hermite(value1.z, tangent1.z, value2.z, tangent2.z, t.z)
	return ret


## Okay so the idea of this is that, for example, in an image you can just provide 4 adjasent pixels
## (or elevation) and this function will automatically generate reasonable slopes. The interpolation
## happens between point B (t = 0) and C (t = 1)
## However, the weights are quite sophisticated, the distances between A-B and B-C are also considered
## when calculating the weights to get really nice and smooth curves
static func weighted_hermite_vec2(A: Vector2, B: Vector2, C: Vector2, D: Vector2, t: Vector2) -> Vector2:
	var tangentB := weighted_tangent_vec2(A, B, C)
	var tangentC := weighted_tangent_vec2(B, C, D)
	return hermite_vec2(B, tangentB, C, tangentC, t)


## Okay so the idea of this is that, for example, in an image you can just provide 4 adjasent pixels
## (or elevation) and this function will automatically generate reasonable slopes. The interpolation
## happens between point B (t = 0) and C (t = 1)
static func weighted_hermite_vec3(A: Vector3, B: Vector3, C: Vector3, D: Vector3, t: Vector3) -> Vector3:
	var tangentB := weighted_tangent_vec3(A, B, C)
	var tangentC := weighted_tangent_vec3(B, C, D)
	return hermite_vec3(B, tangentB, C, tangentC, t)


## calculates a weighted tangent through a point B based on the position of two auxillery points A and C
## said tangent is an average weighted sum of the directions between the auxillery points, the closer point weighs more.
## this can be used to calculate reasonable tangents through points in a spline
static func weighted_tangent_vec2(A: Vector2, B: Vector2, C: Vector2) -> Vector2:
	var AB := A - B
	var CB := C - B
	var normAB := AB.normalized()
	var normCB := CB.normalized()
	var weightedMirrorA := normAB * CB.length()
	var weightedMirrorC := normCB * AB.length()
	return (weightedMirrorC - weightedMirrorA).normalized()


## calculates a weighted tangent through a point B based on the position of two auxillery points A and C
## said tangent is an average weighted sum of the directions between the auxillery points, the closer point weighs more.
## this can be used to calculate reasonable tangents through points in a spline
static func weighted_tangent_vec3(A: Vector3, B: Vector3, C: Vector3) -> Vector3:
	var AB := A - B
	var CB := C - B
	var normAB := AB.normalized()
	var normCB := CB.normalized()
	var weightedMirrorA := normAB * CB.length()
	var weightedMirrorC := normCB * AB.length()
	return (weightedMirrorC - weightedMirrorA).normalized()


#*************************************************************************
# misc
#

## proper modulo function to utilize a number circle.
## Thing is, godot has this implemented as well, it's called [method @GlobalScope.posmod]
## @deprecated
static func mod(x: int, m: int) -> int:
	var r := x % m
	if r < 0:
		return r + m
	else:
		return r


## What the heck, GDscript has no arbitary base log function, not even log10
## Can be used to get the logarithm of any base, default is 10
static func logb(x: float, base: float = 10.0) -> float:
	return log(x) / log(base)


## What the heck, GDscript has no arbitary base log function, not even log10
## This allows you to get the logarithm with any base for ints. This function
## rounds the output down (always)
static func logbi(x: int, base: int = 10) -> int:
	return int(log(float(x)) / log(float(base)))
