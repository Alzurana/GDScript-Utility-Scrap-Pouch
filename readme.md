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

## [RandomGeneratorLFSR](utilities/random_generator_lfsr/)
It's a Linear Feedback Shift Register made in GDScript.
It supports bit depths 2 to 24. If you need one for your project, you'll know. I'd
recommend checking the godot internal documentation page for this. Alternatively check out [Wikipedia](https://en.wikipedia.org/wiki/Linear-feedback_shift_register).
I first stumbled on them in [this talk about the making of pitfall](https://youtu.be/MBT1OK6VAIU?si=eEunfmleVTLEvtve).

## [StateMachine](utilities/state_machine/)
This is a simple state machine with the node based scene tree of godot in mind. To use it you
simply add a state machine node. Each state will be a child of the state machine. In oder to define
your own behavior you must extend the State class in your script and overwrite the `_update` or
`_physics_update` method of the base class. It works pretty much the same as `_process` and
`_physics_process`. In addition there is _enter_state and _exit_state methods. The example project
should you provide with all the information in this regard. All classes are also documented. Now,
state transitions are handled via transition nodes which are children of each state. Currently
there is one always transition and one conditional. You can also extend the Transition class in oder
to make custom transitions that react to signals, for example.

## [JobScheduler](utilities/job_scheduler/)
This is a static, multi threaded job scheduling system. It can be provided with any callable function
and a priority and it will schedule it to run asynchonously on worker threads. The amount of
worker threads is chosen to not choke out the main process but it can be customized. The job scheduler
will assign 20% of it's threads to low, 30% to medium and 50% to high priority. It will distribute
jobs among these threads based on their priorities in a FiFo pattern for each priority bucket.
Should a priority bucket not contain any jobs, threads will attempt to help out with other buckets.
This allows for advanced job management where high priority tasks are being worked on fast but
idle time is not wasted. Another cool thing is that GDscript preserves the object a callable is from,
meaning if you provide some generate function of a specific object the job will call that function
on that specific object.<br>
Usage as follows:<br>
`JobScheduler.add_job(some_callable)`<br>
`JobScheduler.add_job(some_other_callable, JobSchedulder.PRIORITY.HIGH)`<br>
