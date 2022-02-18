extends KinematicBody

export var speed:float = 20
export var acceleration:float = 0.6

var space_state:PhysicsDirectSpaceState
var path_index
var path = []
var navigation:Navigation
var target:Vector3 = Vector3.ZERO

var velocity:Vector3
var y_velocity:float

func _ready():
	space_state = get_world().direct_space_state
	navigation = get_parent()
	if navigation:
		print("found navigation")
	else:
		print("cant find navigation")

func _process(delta):
	var player:KinematicBody = get_parent().get_parent().get_node("Player");
	if player:
		target = player.global_transform.origin

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	var direction:Vector3 = Vector3.ZERO
	if path and path_index < path.size():
		direction = path[path_index] - global_transform.origin
		if direction.length() < 1:
			path_index += 1
		else:
			direction = direction.normalized()
			velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
			velocity = move_and_slide(velocity,Vector3.UP)

func _on_Timer_timeout():
	get_target(target)

func get_target(pos):
	path = navigation.get_simple_path(global_transform.origin,pos)
	path_index = 0
