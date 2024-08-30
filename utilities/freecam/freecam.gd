class_name Freecam3D
extends Node3D
## Freecam script for a spectator type camera
##
## This script allows for WASD spectator like movement with a captured mouse in 3D space.
## It uses built in keybindings for this, mainly ui_down, ui_up, ui_left and ui_right for
## all movement input. It reads the mouse to determine direction and consumes the input
## event [InputEventMouseMotion], supressing subsequent calls on other nodes or the UI.
## Upon instantiation, this script captures the mouse. To toggle mouse capture use
## the ui_cancel key to do so. (Usually this is ESC). Disabeling capture also stops mouse
## move events from being consumed.[br]
## ATTENTION: Do not instantiate this twice, it's just a small helper script and will not
## fail gracefully if you do so. It could rather capture your mouse forever or do other
## wonky stuff.


## Sensitivity. Higher values cause more movement
@export_range(0.0, 1.0) var mouse_sensitivity: float = 0.4
## Travel speed while pressing forward
@export_range(0.0, 100.0) var movement_speed: float = 10.0


## Private internal accumulator should _input be called more than once per frame
var _mouse_input: Vector2 = Vector2(0.0, 0.0)


func _ready() -> void:
	# initial state assumes control
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	_handle_controls(delta)


func _input(event: InputEvent) -> void:
	# accumulate all mouse movement inputs that happened
	if event is InputEventMouseMotion \
		and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_mouse_input += event.relative
		get_viewport().set_input_as_handled()
	# escape sequence to capture and release the mouse from freecam
	elif event.is_action_released("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			print(get_script().get_path().get_file(), " Mouse visible")
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			print(get_script().get_path().get_file(), " Mouse captured")
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## Handles all controls, first moves the view around, then moves the object along the view direction
## based on speed
func _handle_controls(delta: float) -> void:
	# rotation
	var mouse_rotation := Vector3(-_mouse_input.y, -_mouse_input.x, 0.0)
	var relative_rotation := mouse_rotation * mouse_sensitivity
	rotation = relative_rotation * delta + rotation
	# don't break your neck clamp
	rotation.x = clamp(rotation.x, -PI/2.0, PI/2.0)
	# movement
	# forward is -z
	# sideways is +x
	var input_forward := Input.get_axis("ui_down", "ui_up")
	var input_right := Input.get_axis("ui_left", "ui_right")
	var forward_dir := -get_global_transform().basis.z
	var right_dir := get_global_transform().basis.x
	var move_forward = forward_dir * input_forward * movement_speed * delta
	var move_right = right_dir * input_right * movement_speed * delta
	position = move_forward + move_right + position
	# resetting input data
	_mouse_input = Vector2(0.0, 0.0)
