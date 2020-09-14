extends KinematicBody



export var speed : float = 20
export var acceleration : float = 15
export var air_acceleration : float = 5
export var gravity : float = 0.98
export var max_terminal_velocity : float = 54
export var jump_force : float = 30

var velocity : Vector3
var direction = Vector3()

export(float, 0.1, 5) var input_sensitivity : float = 0.3
export(float, -90, 0) var min_pitch : float = -90
export(float, 0, 90) var max_pitch : float = 90


onready var CameraPivotN = $CameraPivot
onready var CameraBoomN = $CameraPivot/CameraBoom/Spatial
onready var CameraN = $CameraPivot/Camera
onready var VisualsN = $Visuals
onready var RaycastN = $RayCast



func _physics_process(delta):
	_camera_movement(delta)
	_player_movement(delta)



func _player_movement(delta):
	direction = Vector3()
	
	if Input.is_action_pressed('player_backward'):
		direction += CameraPivotN.transform.basis.z
	if Input.is_action_pressed('player_forward'):
		direction -= CameraPivotN.transform.basis.z
	if Input.is_action_pressed('player_left'):
		direction -= CameraPivotN.transform.basis.x
	if Input.is_action_pressed('player_right'):
		direction += CameraPivotN.transform.basis.x
	
	direction = direction.normalized()
	
	VisualsN.rotation.y = lerp_angle(VisualsN.rotation.y, atan2(-velocity.x, -velocity.z), delta * 10)
	
	var accel = acceleration if self.is_on_floor() else air_acceleration
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	
	if self.is_on_floor():
		velocity.y = 0
	elif RaycastN.is_colliding() == false:
		velocity.y = clamp(velocity.y - gravity, -max_terminal_velocity, max_terminal_velocity)
	
	if Input.is_action_just_pressed('player_jump') and RaycastN.is_colliding():
		velocity.y = jump_force
	
	velocity = self.move_and_slide(velocity, Vector3.UP)



func _camera_movement(delta):
	CameraPivotN.rotation_degrees.x += Input.get_joy_axis(0, JOY_AXIS_3) * input_sensitivity
	CameraPivotN.rotation_degrees.y -= Input.get_joy_axis(0, JOY_AXIS_2) * input_sensitivity
	CameraPivotN.rotation_degrees.x = clamp(CameraPivotN.rotation_degrees.x, min_pitch, max_pitch)
	
	
	CameraN.translation = lerp(CameraN.translation, CameraBoomN.translation, delta * 1)


