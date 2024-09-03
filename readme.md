# Utilities and random script collection

This is just a general collection of useful little gdscript snipplets. They're all documented. Please consult the in editor documentation and check out the examples.

## [SignalBundle](utilities/signal_bundle/)
This is a utility class meant to make awaiting signals easier. it allows to await multiple signals like this:<br>
`await SignalBundle.any([signal1, signal2, ...])`<br>
`await SignalBundle.all([signal1, signal2, ...])`<br>
You just need to add the file, the functions are static, no need to autoload anything. Awaiting any signal even returns the signal that emitted.

## [Freecam](utilities/freecam/)
A simple script that can be attached to any Node3D and derivitives allowing WASD + mouse style movement for spectator cams. Very useful for debugging purposes.

## [KeepAspectRatio](utilities/keep_aspect_ratio/)
This is an autoload that reads the aspect ratio when the game starts and enforces it whenever the player tries to resize the window. Works best with stretch mode: canvas_items
- display/window/stretch/mode = canvas_items

## [Utils](utilities/)
This is just a bunch of static functions that tend to be useful.

- bicubic hermite interpolation
- cubic hermite
- hermite
- weighted hermite (generates tangents automatically)
- general logarithm (You can choose the base via a parameter)

This list might not be complete

## [RandomGeneratorLFSR](random_generator_lfsr/)
It's a Linear Feedback Shift Register made in GDScript.
It supports bit depths 2 to 24. If you need one for your project, you'll know. I'd
recommend checking the godot internal documentation page for this. Alternatively check out [Wikipedia](https://en.wikipedia.org/wiki/Linear-feedback_shift_register).
I first stumbled on them in [this talk about the making of pitfall](https://youtu.be/MBT1OK6VAIU?si=eEunfmleVTLEvtve).
