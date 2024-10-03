@tool
@icon("res://utilities/state_machine/assets/transition.svg")
class_name Transition
extends Node
## Marks a transition to another state.
##
## This transition will always trigger no matter what. You can inherit from this class and
## make your own transition condition.


## Select the state node which should follow if this transition triggers
@export var target_state: State = null:
	set(value):
		target_state = value
		update_configuration_warnings()


## Overwrite to check weather or not this transition wants to transition to another state
## When inheriting from this class you'd overwrite this function and return true should
## the state transition
func check_transition() -> bool:
	return true


# internal, checks the check_transition() overwrite for a result
func _check_transition() -> State:
	if check_transition():
		return target_state
	return null


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	# There should always be a target state for a transition
	if not target_state:
		warnings.append("No target state selected. This transition won't do anything")
	return warnings
