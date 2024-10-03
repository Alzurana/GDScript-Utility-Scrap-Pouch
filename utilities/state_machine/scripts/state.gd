@icon("res://utilities/state_machine/assets/state.svg")
class_name State
extends Node
## Class to represent a state
##
## This class is meant to be inherited from.


## Overwrite for the update loop. Called when _process() is called on the state machine and
## this is the current state.
func _update(_delta: float):
	pass


## Overwrite for the update loop. Called when _physics_process() is called on the state machine and
## this is the current state.
func _physics_update(_delta: float):
	pass


## Overwrite for the update loop. Called when the state machine changed to this
## as the current state.
func _enter_state(_new_state: State) -> void:
	pass


## Overwrite for the update loop. Called when this was the current state and the state machine
## changes over to another state.
func _exit_state(_old_state: State) -> void:
	pass


# Checking all transitions of this state
func _check_transitions() -> State:
	var transitions := get_children().filter(func (child): return child is Transition)
	for transition in transitions:
		var new_state = transition._check_transition()
		if new_state:
			return new_state
	return null
