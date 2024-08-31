class_name SignalBundle
## This class provides utilities to await multiple signals.

## Usage:[br]
## It is simplest to just use the 2 static functions any and all like this:
## [codeblock]await SignalBundle.any([signal1, signal2, ...])
## await SignalBundle.all([signal1, signal2, ...])[/codeblock]
## I didn't write a more sophisticated interface as that just wasn't needed. If you want to
## you can instantiate this class yourself with new and even monitor which signals are still
## missing in AWAIT_MODE.ALL but I'd recommend you modify this in that case and make it a bit
## less convolided.


## Emits when the await mode condition is met.
signal finished


## Mode enum. Any means any signal triggers the Awaiter, all means all signals need to emit
enum AWAIT_MODE
{
	ANY,
	ALL,
}


## Does any signal trigger the finished condition or do we need all
var await_mode: AWAIT_MODE
## Signal wrappers
var _wrappers: Array[_CallbackWrapper]


## Sets up the awaiter and connects all signals
func _init(init_signals: Array[Signal], init_await_mode: AWAIT_MODE) -> void:
	await_mode = init_await_mode
	for sig in init_signals:
		var wrapper: _CallbackWrapper = _CallbackWrapper.new(sig, self)
		_wrappers.append(wrapper)


## Coroutine you can await until any signal emitted
## Essentially what you do is call it like this:
## [codeblock]await SignalBundle.any([signal1, signal2, ...])[/codeblock]
## It will return as soon as one of the provided signals emitted. It is important
## you "await" this method, otherwise it will just return immediately.
## It will also return which signal triggered it should you choose to capture that.
static func any(signals : Array[Signal]) -> Signal:
	var bundler: SignalBundle = SignalBundle.new(signals, AWAIT_MODE.ANY)
	var emitted_signal: Signal = await bundler.finished
	return emitted_signal


## Coroutine you can await until all signals emitted
## Essentially what you do is call it like this:
## [codeblock]await SignalBundle.all([signal1, signal2, ...])[/codeblock]
## It will return as soon as all of the provided signals emitted. It is important
## you "await" this method, otherwise it will just return immediately.
static func all(signals : Array[Signal]):
	var bundler: SignalBundle = SignalBundle.new(signals, AWAIT_MODE.ALL)
	await bundler.finished


## used by the internal wrapper to notify a signal fired
func _callback(calling_wrapper: _CallbackWrapper):
	var return_signal: Signal = calling_wrapper._wrapped_signal
	_wrappers.erase(calling_wrapper)
	match await_mode:
		AWAIT_MODE.ANY:
			for wrapper in _wrappers:
				wrapper.disconnect_signal()
			_wrappers.clear()
			finished.emit(return_signal)
		AWAIT_MODE.ALL:
			if _wrappers.is_empty():
				finished.emit()


## Wrapper for a single signal in order to store and return it
##
## This is used to bundle a callback with the signal it came from
## This is to reliably be able to return the signal that caused an await to resolve.
## This is only relevant in "any" mode, ofc
## I did not use Callable.bind() for this because it appends arguments making it difficult
## to capture them in callbacks should the signal also return arguments.
class _CallbackWrapper:
	## Which signal is wrapped
	var _wrapped_signal: Signal
	## Who to notify when signal fired
	var _parent: SignalBundle
	## Does everything including connecting to the signal
	func _init(wrapped_signal: Signal, parent: SignalBundle) -> void:
		_wrapped_signal = wrapped_signal
		_parent = parent
		wrapped_signal.connect(_callback, Object.CONNECT_ONE_SHOT)
	## Can be used to disconnect signal before it fired
	func disconnect_signal() -> void:
		_wrapped_signal.disconnect(_callback)
	## Internal callback function for signal connection
	func _callback():
		_parent._callback(self)
