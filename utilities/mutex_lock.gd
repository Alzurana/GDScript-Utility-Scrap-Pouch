# @tool
class_name MutexLock
extends RefCounted
#region Docstring
## A class to lock a mutex RAII style.
##
## This class is meant to make handling mutexes a bit easier and safer. It prevents
## forgetting to unlock a mutex after you're done with your work. You use it by creating
## a new object of this type at the start of your function scope and pass the mutex
## you want to lock as a parameter to new(). Any operation following that call
## will be safe with a locked mutex. As soon as the function is done the lock object
## will be destroyed and the mutex unlocked. Do keep in mind that you should not
## store the lock object as, as long as it exists, the mutex will remain locked.
## This is literally only meant for this ussecase. Lock at the beginning of work
## (your function) and let it expire at the end. Do not reuse this object, do not cache it,
## just let it expire.[br]
## Example:
## [codeblock]
## func my_task(new_data):
##	var lock := MutexLock.new(data_mutex)
##	data.append(new_data)
## [cCodeblock]
#endregion


#region private variables
var _mutex: Mutex
#endregion


#region optional built-in virtual _init methods
func _init(lock_mutex: Mutex) -> void:
	_mutex = lock_mutex
	_mutex.lock()
#endregion


#region remaining built-in virtual methods
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_mutex.unlock()
#endregion
