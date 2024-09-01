extends Node


@export var lfsr: RandomGeneratorLFSR


static var random_strings: PackedStringArray = [
		"Don't forget your umbrella",
		"The cake is a lie",
		"42",
		"JOEY DOES NOT SHARE FOOD!",
		"Gravity is proportional to the mass of both bodies",
		"Gravity is antiproportional to the distance squared between both bodies",
		"Really, this is the last string",
]


func _ready() -> void:
	lfsr.bit_depth = 3
	lfsr.seed = 1
	lfsr_coroutine()


func lfsr_coroutine() -> void:
	while true:
		# if I use it in an array I need to keep in mind that it never returns 0
		print(random_strings[lfsr.randi() - 1])
		await get_tree().create_timer(1.0).timeout
