class_name RandomGeneratorLFSR
extends Resource
## Linear Feedback Shift Register
##
## Every now and then, when reading about gamedev stuff you stumble over LFSRs, often as sort
## of cycling random number generators used for whatever purpose.
## Their useful property is that they cycle through a sequence of of numbers fairly randomly
## while each number in a given set comes up exactly once in that sequence (no repeats unless
## you reach the end of the sequence). At the end of the sequence they just begin from the start.
## This class is exactly that. Haven't seen any engine ever providing these but they can be quite
## useful. Pitfall used them to generate it's level seeds due to memory constraints.[br]
## I did not implement reverse cycling but you could just remember the output anyways.[br]
## [br]
## An LFSR has a bit depth that determines it's sequence period. The more bits, the longer it is
## The period length is 2^BitDepth - 1. There's a utility function for this.[br]
## In general, I'd advice checking out the
## [url=https://en.wikipedia.org/wiki/Linear-feedback_shift_register#Example_polynomials_for_maximal_LFSRs]wikipedia article[/url]
## on them for further reading. This is also where I took the taps from.[br]
## [br]
## Usage:[br]
## [br]
## Simply instantiate, select bit depth and go! Since this is a resource type you can even save
## and use it as a property. Even exported for easy manipulation within the inspector. However,
## you should always set the bit depth first.
## [codeblock]
## var lfsr := RandomGeneratorLFSR.new()
## lfsr.bit_depth = 16
## lfsr.seed = 123
## print(lfsr.randi())
## [/codeblock]


## Bit depth of the LFSR. The bit depth determines how long the period of the LFSR is.
@export_range(2, 24) var bit_depth: int = 8:
	set(new_bit_depth):
		var clamped_bit_depth: int = clampi(new_bit_depth, 2, 24)
		if 2 > new_bit_depth or new_bit_depth > 64:
			push_warning("LFSR bit_depth set to invalid value: ", new_bit_depth, " Only values 2 to 24 are accepted. Input will be clamped to ", clamped_bit_depth)
		bit_depth = clamped_bit_depth
## Seed of the LFSR. This is basically the number it started at. Setting this will also set the state.
@warning_ignore("shadowed_global_identifier") # that global is irrelevant to instances of this class
@export var seed: int = 1:
	set(new_seed):
		var seed_clipped: int = (_pow_table[bit_depth] - 1) & new_seed
		if seed_clipped != new_seed:
			push_warning("LFSR initialized with higher bits than bit_depth permits. Ignoring higher bits past ", bit_depth)
		if seed_clipped == 0:
			push_warning("LFSR initialized with 0 as a seed. This is not permitted. LFSR will be seeded to 1 instead.")
			seed = 1
			state = 1
		else:
			seed = seed_clipped
			state = seed_clipped
		notify_property_list_changed()
## Current state of the LFSR. This is the last random number it spit out
@export var state: int = 1


# These taps are already optimized for creating bitmasks with pow
# meaning that we start counting bit positions at 0
static var _taps: Array[PackedByteArray] = [
			[],               #  0 - Padding
			[0],              #  1 - Padding
			[1, 0],           #  2
			[2, 1],           #  3
			[3, 2],           #  4
			[4, 2],           #  5
			[5, 4],           #  6
			[6, 5],           #  7
			[7, 5, 4, 3],     #  8
			[8, 4],           #  9
			[9, 6],           # 10
			[10, 8],          # 11
			[11, 10, 9, 3],   # 12
			[12, 11, 10, 7],  # 13
			[13, 12, 11, 1],  # 14
			[14, 13],         # 15
			[15, 14, 12, 3],  # 16
			[16, 13],         # 17
			[17, 10],         # 18
			[18, 17, 16, 13], # 19
			[19, 16],         # 20
			[20, 18],         # 21
			[21, 20],         # 22
			[22, 17],         # 23
			[23, 22, 21, 16], # 24
]
# Just precomputed pow values for 2^n up to 24
# Developer Tangent:
# This should be more efficient than calling "pow()" all the time and converting from
# int to float to int but I did not test that. So this is a blind optimization
# with an unknown impact which is a little sin. If I read this in the future I might
# write a test case to confirm the speed boost or shoot myself in the foot.
static var _pow_table: PackedInt32Array = [
		1, 2, 4, 8, 16, 32, 64, 128, # 0 - 7
		256, 512, 1024, 2048, 4096, 8192, 16384, 32768, # 8 - 15
		65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, # 16 - 23
		16777216, # 24
]


## Get the next random number in this sequence. This updates the internal state.
func randi() -> int:
	# tapping
	var parity: int = 0
	for tap in _taps[bit_depth]:
		# 1. isolate bit, shift to rightm, then xor
		var tap_bit = (_pow_table[tap] & state) >> tap
		parity = parity ^ tap_bit
	# shift, cut high bits, combine
	state = ((state << 1) & (_pow_table[bit_depth] - 1)) | parity
	return state


## This returns the period of the set bit_depth. Just a shorthand for 2^BitDepth - 1.
## The period determines how many random values you can pull until the sequence repeats itself.
func get_period() -> int:
	return _pow_table[bit_depth] - 1


## Does the same as [method RandomGeneratorLFSR.get_period].
## Somehow documentation is broken if I want to also disable a warning. :C
# It complaining that it would shadow an internal variable makes no sense as this is a
# static function
@warning_ignore("shadowed_variable")
static func get_period_of(bit_depth: int) -> int:
	return _pow_table[bit_depth] - 1
