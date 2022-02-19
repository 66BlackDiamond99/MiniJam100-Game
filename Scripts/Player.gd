extends KinematicBody

export var walk_speed:float = 10
export var run_speed:float = walk_speed + 10
export var acceleration:float = 7.5
export var air_acceleration:float = 5
export var gravity:float = 0.98
export var max_terminal_vel:float = 54
export var jump_power:float = 20

export(float,0.1,1) var mouse_sensitivity:float = 0.3
export(float,-90,0) var min_pitch:float = -90
export(float,0,90) var max_pitch:float = 90

var velocity:Vector3
var y_velocity:float

onready var camera_pivot = $CameraPivot
onready var camera = $CameraPivot/CameraHolder/Camera
onready var animator = $Female/AnimationPlayer
onready var model = $Female

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if event is InputEventMouseMotion:
		event = event as InputEventMouseMotion
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		camera_pivot.rotation_degrees.x -= event.relative.y * mouse_sensitivity
		camera_pivot.rotation_degrees.x = clamp(camera_pivot.rotation_degrees.x, min_pitch,max_pitch)

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	var direction:Vector3 = Vector3.ZERO
	var running = false
	
	if Input.is_action_pressed("move_forward"):
		model.rotation_degrees.y = lerp(model.rotation_degrees.y,-180,0.4)
		direction -= transform.basis.z
	
	if Input.is_action_pressed("move_backward"):
		model.rotation_degrees.y = lerp(model.rotation_degrees.y,0,0.4)
		direction += transform.basis.z
	
	if Input.is_action_pressed("move_right"):
		model.rotation_degrees.y = lerp(model.rotation_degrees.y,270,0.4)
		direction += transform.basis.x
	
	if Input.is_action_pressed("move_left"):
		model.rotation_degrees.y = lerp(model.rotation_degrees.y,-90,0.4)
		direction -= transform.basis.x
	
	
	direction = direction.normalized()
	
	
	if direction.length() != 0 and is_on_floor() and Input.is_action_pressed("run"):
		running = true
	
	var acc = acceleration if is_on_floor() else air_acceleration
	var speed = run_speed if running else walk_speed
	velocity = velocity.linear_interpolate(direction * speed, acc * delta)
	
	if is_on_floor():
		y_velocity = -0.1
	else:
		y_velocity = clamp(y_velocity - gravity, -max_terminal_vel, max_terminal_vel)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		y_velocity = jump_power
	
	velocity.y = y_velocity
	velocity = move_and_slide(velocity,Vector3.UP)
	
	if velocity.length() < 0.01 and is_on_floor():
		animator.play("idle-loop")
	elif is_on_floor():
		if velocity.length() > walk_speed and running:
			animator.play("running-loop")
		else:
			animator.play("Walking-loop")
	else:
		pass #jump/fall animation
	
