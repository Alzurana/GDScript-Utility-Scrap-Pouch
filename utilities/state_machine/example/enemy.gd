class_name Enemy
extends Sprite2D



@export var speed: float = 200.0
var distance_to_player: float = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mouse_to_sprite := get_viewport().get_mouse_position() - global_position
	distance_to_player = mouse_to_sprite.length()
