@tool
@icon("res://utilities/state_machine/assets/state_machine.svg")
class_name StateMachine
extends Node


## Select the state node which should follow if this transition triggers
@export var initial_state: State = null:
	set(value):
		initial_state = value
		update_configuration_warnings()
## How often the transitions should be checked. Every N-th frame, basically. So if this is 1
## then transitions will be checked every physics frame. If it's 2 every 2nd frame. If it's
## 20 then every 20th frame. All state machines also generate an internal random seed to prevent
## state machines with the same interval all checking on the exact same frame.
@export_range(1, 600, 1, "or_greater") var check_transition_every_frame: int = 1:
	set(value):
		check_transition_every_frame = value
		_random_transition_frame = randi_range(0, check_transition_every_frame - 1)
# holds internal seed
var _random_transition_frame: int


# current running state
var _current_state: State


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_current_state = initial_state


# call state frame loop
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_current_state._update(delta)


# call state update loop
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_current_state._physics_update(delta)
	_check_transitions()


# changes states and calls exit and enter functions
func change_state(new_state: State) -> void:
	_current_state._exit_state(new_state)
	var old_state := _current_state
	_current_state = new_state
	_current_state._enter_state(old_state)


# checks current state for conditions if the frame number is correct
func _check_transitions() -> void:
	if get_tree().get_frame() % check_transition_every_frame != _random_transition_frame:
		return
	var new_state: State = _current_state._check_transitions()
	if not new_state:
		return
	change_state(new_state)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	# Filter children for type "State". If there are none this state machine is misconfigured
	if get_children().filter(func(child): return child is State).size() <= 0:
		warnings.append("This StateMachine has no State children to execute")
	# State machine must have an initial state configured
	if not initial_state:
		warnings.append("There is no initial state assigned. Please assign one")
	return warnings
