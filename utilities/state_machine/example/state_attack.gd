extends State


@onready var enemy: Enemy = %Enemy


func _enter_state(_old_state: State) -> void:
	enemy.modulate = Color.RED
