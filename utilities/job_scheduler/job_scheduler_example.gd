extends Node
## This is really just a script to test the job system
## Using the return key to allow control over adding jobs


@onready var label_pending_jobs: Label = %LabelPendingJobs


var callable: Callable


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		print("Adding 10 jobs to the queue")
		for i in range(5):
			JobScheduler.add_job(_some_sqrt_job)
			JobScheduler.add_job(_some_data_job, JobScheduler.PRIORITY.LOW)
	# update display
	label_pending_jobs.text = "Pending Jobs: " + str(JobScheduler.get_pending_job_count())


# This is really just meant to crunch some numbers
func _some_sqrt_job() -> void:
	@warning_ignore("unused_variable")
	var x: float = 0.0;
	for i in range(1000000):
		x = sqrt(i)

# This is really just meant to crunch some numbers
func _some_data_job() -> void:
	var x: float = 0.0;
	var y: float = 0.0;
	var z: float = 0.0;
	for i in range(1000000):
		x = y
		y = z
		z = x
