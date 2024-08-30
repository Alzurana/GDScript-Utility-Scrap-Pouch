extends Node
class_name Main
## This is really just a script to test all those different utilities


signal up
signal down


func _ready() -> void:
	_any_test()
	_all_test()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		up.emit()
	if Input.is_action_just_pressed("ui_down"):
		down.emit()


func _any_test() -> void:
	while true:
		var triggered_signal: Signal = await SignalBundle.any([up, down])
		print("Any, triggered by signal ", triggered_signal.get_name())


func _all_test() -> void:
	while true:
		await SignalBundle.all([up, down])
		print("ALL was triggered")
