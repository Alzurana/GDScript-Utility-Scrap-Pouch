@tool
class_name TransitionCondition
extends Transition
## Marks a transition to another state.
##
## With this transition you can move to another state if a specific condition is met.
## For this you provide a node and property name to check as well as a value to check against.
## You can then select if it should check if the property is equal, less, more than the value
## you've provided. If that is the case the transition returns the new state.
## It is possible to use this to completely automate a state machine without writing a single
## line of code. Great for AI behavior.


## Defines which operation should be performed to determine if this transition triggers
enum Operator {
	LESS_THAN,		## < less than
	LESS_THAN_EQUAL,## <= less than or equal
	EQUAL,			## == equal
	MORE_THAN_EQUAL,## >= more than or equal
	MORE_THAN,		## > more than
	BOOLEAN,		## Compare property directly
}


## Which node to check a property of. Leave empty (null) to check a property in the parent state
@export var node_to_check: Node = null:
	set(value):
		node_to_check = value
		update_configuration_warnings()
## Which property to check on. This needs to be an exact match.
@export var property_name: StringName:
	set(value):
		property_name = value
		update_configuration_warnings()
## Which logical operation should be performed. Boolean will check the property directly
@export var operation: Operator = Operator.EQUAL
## The value to check the given property against.
## This will be ignored if Boolean was selected as operation
@export var check_value: float = 0.0


## Checks weather or not the transition is met and if so, returns true
func check_transition() -> bool:
	var property
	if node_to_check:
		property = node_to_check.get(property_name)
	else:
		property = get_parent().get(property_name)
	match operation:
		Operator.LESS_THAN:
			if property < check_value:
				return true
		Operator.LESS_THAN_EQUAL:
			if property <= check_value:
				return true
		Operator.EQUAL:
			if property == check_value:
				return true
		Operator.MORE_THAN_EQUAL:
			if property >= check_value:
				return true
		Operator.MORE_THAN:
			if property > check_value:
				return true
		Operator.BOOLEAN:
			if property:
				return true
	# no condition met
	return false


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	# attach parent warnings
	warnings.append_array(super())
	# Does the property name exist
	var has_property = false
	var node: Node = node_to_check if node_to_check else get_parent()
	var script: Script = node.get_script()
	# check base
	if node.get(property_name):
		has_property = true
	# check script
	if script:
		for property in script.get_script_property_list():
			if property.name == property_name:
				has_property = true
	if not has_property:
		warnings.append("Target node to check has no property called \"" + property_name + "\"")
	return warnings
