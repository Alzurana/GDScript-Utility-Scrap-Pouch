# Utilities and random script collection

This is just a general collection of useful little gdscript snipplets. They're all documented. Please consult the in editor documentation and check out the examples.

## [SignalBundle](utilities/signal_bundle/)
This is a utility class meant to make awaiting signals easier. it allows to await multiple signals like this:  
`await SignalBundler.any([signal1, signal2, ...])`  
`await SignalBundler.all([signal1, signal2, ...])`  
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
