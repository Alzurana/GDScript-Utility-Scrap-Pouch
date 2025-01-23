#region Class Header
extends Node
class_name JobScheduler
## This class provides utilities to schedule and execute async jobs on limited CPU cores.
## It will create a limited amount of threads based on your systems logical core count.
## See [member max_thread_number]
##
## USAGE:
## Add this class as an autoload to your project.
## Use [method add_job] to add a job to the job queues. Jobs are functions that are being called
## on parallel threads. This means that your job functions must be thread safe.
## Jobs also have a priority which determines which threads will take on the job first.
## The scheduler will attempt to run a high prio job on a high prio thread first.
## If, for example, normal priority threads have nothing to do they will attempt to take on work
## from the high priority, then low priority bucket to ensure full utilization. Creating a job
## will provide a [class Job] object which can be used to track progress as well as wait on
## the jobs [signal Job.finished] signal which triggers during the first idle time after the
## job has been completed.[br]
## [br]
## Some things to look out for: There are no timeouts, no cancellations. You have to make sure your
## jobs actually run through. If your code runs into deadlocks or endless loops it will block
## the ececuting threads forever. These features might be added later.[br]
## [br]
## Some notes on how this works internally:
## Threads themselves look at the pending job list and take on available jobs, if none are available
## for the assigned thread priority they begin to work on other priority buckets until no jobs are
## left, then go to sleep. This ensures that, even if there's a high amount of high priority jobs
## there will still be SOME threads working on normal and low and nothing is starved, therefor.
## [br]
## Jobs are being processed in FIFO fashion per bucket. Best practice is to think of most work as
## low priority and only use high priority for very important work that should be taken on before
## other low priority jobs and as soon as a thread frees up.
## [br]
## The whole thing is also setup with a distributed scheduler. There is no central entity
## scheduling, threads decide themselves what job to take on next. Tt's similar to the NT kernel in
## this regard (but also means it has more overhead of threads potentially colliding when looking
## for new jobs, this should be negliable however)
#endregion


#region enums
## A jobs priority.
enum PRIORITY
{
	LOW,	## Run on low priority threads
	NORMAL,	## Run on normal priority threads
	HIGH,	## Run on high prioritiy threads
	LAST,
}
#endregion


#region public members
## The maximum number of threads to be used. By default this will be 2 less than the logical core
## count of your system which is usually enough. Chaning this property will join all threads until
## they have completed their work as it will trigger their recreation. The scheduler will attempt
## and create 20% low, 30% medium, 50% high priority threads. Each priority will get at least
## 1 thread assigned so the minimum number of threads used by the scheduler is always at least 3,
## regardless of if a lower number is provided.
static var max_thread_number: int = OS.get_processor_count() - 2:
	set(value):
		max_thread_number = value
		if _is_not_initialized:
			_init()
		else:
			_setup_threads()
#endregion


#region private mambers
# Still pending jobs of each priority. Currently running jobs are not part of this data structure.
static var _pending_jobs: Array[Array] = []
# Mutex for acessing central storage [member _pending_jobs]
static var _pending_jobs_mutex: Mutex = Mutex.new()
# All threads
static var _threads: Array[Thread] = []
# The threads respective priorities
static var _thread_priorities: Array[PRIORITY] = []
# Internal flag to trigger the constructor, should this class have no been interacted with yet
# We need to use a trigger like this because GDscript does not provide me with static constructors, yet
static var _is_not_initialized: bool = true
#endregion


#region public methods
## Adds a job to be scheduled. If there are idle threads said job will run immediately.
## If not it will be scheduled and worked off based on it's priority.[br]
##[br]
## [param function_to_call] This is the function this job should run. This respects object boundries,
## so if you tell it to run a specific "generate" function of an object in your scene tree it will
## run that function as if it were on that particular object. It is important that you make sure
## said function is thread safe. The scheduler can not protect you from unsafe access.[br]
##[br]
## [param priority] This defaults to normal priority and if you do not care about job order
## then this is irrelevant for you. For more information about execution order, check the detailed
## class description on the topic: See [class JobScheduler]
static func add_job(function_to_call: Callable, priority: PRIORITY = PRIORITY.NORMAL):
	if _is_not_initialized:
		_init()
	var new_job: Job = Job.new(function_to_call, priority)
	_pending_jobs_mutex.lock()
	_pending_jobs[priority].push_back(new_job)
	_pending_jobs_mutex.unlock()
	_wakeup_threads()


## Joins and waits until all jobs have finished.
static func join_all_jobs() -> void:
	if _is_not_initialized:
		_init()
	for thread in _threads:
		thread.wait_to_finish()


## Get how many jobs are remaining. If you provide a priority it will only return those jobs.
static func get_pending_job_count(priority: PRIORITY = PRIORITY.LAST) -> int:
	if _is_not_initialized:
		_init()
	match priority:
		PRIORITY.LAST:
			# we use this unused parameter to mean "all tasks"
			var number_of_pending_jobs: int = 0
			for i in range(PRIORITY.LAST):
				number_of_pending_jobs += _pending_jobs[i].size()
			return number_of_pending_jobs
		_:
			return _pending_jobs[priority].size()
#endregion


#region private methods
# Static constructor.
# This boy needs to be manually managed as GDscript does not support constructors for statics
static func _init() -> void:
	print("JobScheduler - Init called")
	_pending_jobs.resize(PRIORITY.LAST)
	_is_not_initialized = false
	_setup_threads()


# Function to setup the thread structure. it first joins all threads until they completed
# their work before destroying them and using the configured thread count to repopulate all
# worker threads.
static func _setup_threads():
	print("JobScheduler - Thread setup called, joining threads to finish all jobs")
	for thread in _threads:
		thread.wait_to_finish()
	print("JobScheduler - Clearing thread list")
	_threads.clear()
	_thread_priorities.clear()
	print("JobScheduler - Setting up threads, User chose ", max_thread_number , " Threads to be created")
	var low_priority_count: int = int(max_thread_number * 0.2)
	if low_priority_count < 1:
		low_priority_count = 1;
	var normal_priority_count: int = int((max_thread_number - low_priority_count) * 0.4)
	if normal_priority_count < 1:
		normal_priority_count = 1;
	var high_priority_count: int = max_thread_number - normal_priority_count - low_priority_count
	if high_priority_count < 1:
		high_priority_count = 1;
	for i in range(high_priority_count):
		_threads.push_back(Thread.new())
		_thread_priorities.push_back(PRIORITY.HIGH)
	for i in range(normal_priority_count):
		_threads.push_back(Thread.new())
		_thread_priorities.push_back(PRIORITY.NORMAL)
	for i in range(low_priority_count):
		_threads.push_back(Thread.new())
		_thread_priorities.push_back(PRIORITY.LOW)
	print("JobScheduler - Created threads with following priorities: ", low_priority_count, "/", normal_priority_count, "/", high_priority_count, " - LOW/NORMAL/HIGH")


# Just wakes up as many threads as there are jobs. Ignores priorities for now and lets threads
# figure this out
static func _wakeup_threads() -> void:
	var pending_jobs = get_pending_job_count()
	for i in range(_threads.size()):
		if not _threads[i].is_alive():
			if _threads[i].is_started():
				_threads[i].wait_to_finish()
			_threads[i].start(_thread_main_function.bind(_thread_priorities[i]))
			pending_jobs -= 1
			if pending_jobs <= 0:
				break


# Thread main loop. Attempts to find a job to run, then runs it
# The execution order for different priorities is as follows:
# HIGH: High, Normal, Low
# NORMAL: Normal, High, Low
# LOW:Low, Normal, High
# The way this code is written is a bit ugly but there is no urgency to refactor this.
static func _thread_main_function(priority: PRIORITY) -> void:
	while true:
		var current_job: Job = null
		_pending_jobs_mutex.lock()
		match (priority):
			PRIORITY.LOW:
				current_job = _pending_jobs[PRIORITY.LOW].pop_front()
				if not current_job:
					current_job = _pending_jobs[PRIORITY.NORMAL].pop_front()
					if not current_job:
						current_job = _pending_jobs[PRIORITY.HIGH].pop_front()
			PRIORITY.NORMAL:
				current_job = _pending_jobs[PRIORITY.NORMAL].pop_front()
				if not current_job:
					current_job = _pending_jobs[PRIORITY.HIGH].pop_front()
					if not current_job:
						current_job = _pending_jobs[PRIORITY.LOW].pop_front()
			PRIORITY.HIGH:
				current_job = _pending_jobs[PRIORITY.HIGH].pop_front()
				if not current_job:
					current_job = _pending_jobs[PRIORITY.NORMAL].pop_front()
					if not current_job:
						current_job = _pending_jobs[PRIORITY.LOW].pop_front()
		_pending_jobs_mutex.unlock()
		# No more jobs, thread will exit
		if not current_job:
			return
		current_job._run_job()
#endregion


#region Job subclass
## Utility class to manage jobs. You're not supposed to create these yourself.
## They will be provided when creating a job with [method JobScheduler.add_job] and
## can be used to track the status of a job. This is useful to know if relevant data
## has been processed yet.
class Job:
	## This signal is called after the job has finished within the next idle period of a frame.
	## This signal is emitted via call_deferred()
	signal finished
	## Job statuses
	enum STATUS
	{
		INVALID,	## Something went wrong, this job is invalid
		PENDING,	## This job has been queued but processing hasn't started yet
		RUNNING,	## This job is currently being executed on a thread
		FINISHED,	## This job has finished it's work
		LAST,
	}
	# The function that this job should call. Please do not modify this.
	var _job_function: Callable
	# This jobs priority.
	var _priority: PRIORITY = PRIORITY.NORMAL
	# Job status based on [enum STATUS]
	var _status: STATUS = STATUS.INVALID
	# Constructor.
	func _init(job_function, priority: PRIORITY):
		_job_function = job_function
		_priority = priority
		_status = STATUS.PENDING
	## Get the status of this job as a [enum STATUS]
	func get_status() -> STATUS:
		return STATUS.INVALID
	## Returns TRUE if the job is still pending and has not started yet.
	func is_pending() -> bool:
		return _status == STATUS.PENDING
	## Returns TRUE if the job is currently being executed on a thread.
	func is_running() -> bool:
		return _status == STATUS.RUNNING
	## Returns TRUE if the job has finished. Note that this can be TRUE even before [signal finished] fired.
	func is_finished() -> bool:
		return _status == STATUS.FINISHED
	## Returns this jobs priority as [enum JobScheduler.PRIORITY]
	func get_priority() -> PRIORITY:
		return _priority
	# Runs the job with all safety checks, it also manages status and signals. This is meant to be
	# called by our threads, do not call it as the user.
	func _run_job():
		# bad code smell to avoid another bad code smell
		# in order not to dublicate the cleanup steps of finishing and calling the signal
		# we run the hot path in the else blocks.
		# Just think "if all is good we end up in else and execute the function, in any case, we clean up"
		if not _job_function:
			push_warning("JobScheduler - Attempted to run an empty job. Someone supplied a callable as NULL.")
		else:
			if not _job_function.is_valid():
				push_warning("JobScheduler - Attempted to run a job but it's callable is not valid. Maybe the source object was deleted?")
			else:
				_status = STATUS.RUNNING
				_job_function.call()
		_status = STATUS.FINISHED
		finished.emit.call_deferred()
#endregion
