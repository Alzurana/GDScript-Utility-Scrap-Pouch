# track window/viewport changes and keep aspect ratio
extends Node
## Track window/viewport changes and keep aspect ratio
##
## This script will force the aspect ratio of a window to always be the same
## regardles how the user resizes it.
## By default it auto detects the aspect ratio of the scene when it's _ready()
## function was invoked. Note that this only happens once, if you change
## the aspect ratio through script it will honor the new ratio as soon as the
## next resize event was triggered.

## Aspect ratio property will be ignored if this is checked
@export var autodetect_aspect_ratio: bool = true
## The aspect ratio this scipt should enforce
@export var aspect_ratio: float = 16.0 / 9.0
# Used to prevent signal processing until resolution change happened at the end of the frame
var _ignore_next_signal := false


# grab ratio and register callback
func _ready() -> void:
	if autodetect_aspect_ratio:
		# casting so it won't do an integer division
		var defaultSize := Vector2(DisplayServer.window_get_size())
		aspect_ratio = defaultSize.x / defaultSize.y
		print(name, " - Aspect ratio detected as ", aspect_ratio)
	get_tree().root.connect("size_changed", self._on_window_size_changed)


## Every time the user grabbles the window we want to reset the aspect ratio
func _on_window_size_changed() -> void:
	# skip if we triggered a change this frame already
	if _ignore_next_signal:
		return
	var new_size := Vector2(DisplayServer.window_get_size())
	var new_ratio := new_size.x / new_size.y
	# smaller ratio means x is too short, otherwise y is too short
	if new_ratio < aspect_ratio:
		new_size.x = new_size.y * aspect_ratio
	else:
		new_size.y = new_size.x / aspect_ratio
	# we need to call resize at the end of the frame and ignore all signals until then
	_ignore_next_signal = true
	_resize_window.call_deferred(new_size)


## Resizes the window
func _resize_window(new_size: Vector2i) -> void:
	print(name, " - Window resized, forcing new resolution of ", Vector2i(new_size))
	DisplayServer.window_set_size(Vector2i(new_size))
	_ignore_next_signal = false
