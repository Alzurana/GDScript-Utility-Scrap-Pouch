extends State


@onready var enemy: Enemy = %Enemy


func _physics_update(delta: float):
	enemy.global_position = enemy.global_position.move_toward(get_viewport().get_mouse_position(), enemy.speed * delta)


func _enter_state(_old_state: State) -> void:
	enemy.modulate = Color.GREEN
