extends Node
## This is really just a script to test the job system
## Using the return key to allow control over adding jobs


@onready var label_pending_jobs: Label = %LabelPendingJobs
@onready var label_pending_jobs_high: Label = %LabelPendingJobsHigh
@onready var label_pending_jobs_normal: Label = %LabelPendingJobsNormal
@onready var label_pending_jobs_low: Label = %LabelPendingJobsLow


var callable: Callable


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		print("Adding 60 jobs to the queue")
		for i in range(20):
			JobScheduler.add_job(_some_sqrt_job)
			JobScheduler.add_job(_some_data_job, JobScheduler.PRIORITY.LOW)
			JobScheduler.add_job(_some_int_job, JobScheduler.PRIORITY.HIGH)
	# update display
	label_pending_jobs.text = "Pending jobs: " + str(JobScheduler.get_pending_job_count())
	label_pending_jobs_high.text = "High priority: " + str(JobScheduler.get_pending_job_count(JobScheduler.PRIORITY.HIGH))
	label_pending_jobs_normal.text = "Normal priority: " + str(JobScheduler.get_pending_job_count(JobScheduler.PRIORITY.NORMAL))
	label_pending_jobs_low.text = "Low priority: " + str(JobScheduler.get_pending_job_count(JobScheduler.PRIORITY.LOW))


# Crunch some floats
func _some_sqrt_job() -> void:
	@warning_ignore("unused_variable")
	var x: float = 0.0;
	for i in range(1000000):
		x = sqrt(i)


# Move some registers
func _some_data_job() -> void:
	var x: float = 0.0;
	var y: float = 0.0;
	var z: float = 0.0;
	for i in range(1000000):
		x = y
		y = z
		z = x


# Do some simple int stuff
func _some_int_job() -> void:
	@warning_ignore("unused_variable")
	var a: int = 1
	for i in range(1000000):
		a *= 78345
