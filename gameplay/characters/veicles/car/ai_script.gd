extends RigidBody3D

@export var max_speed := 35.0          # m/s
@export var acceleration := 3.0       # m/s²
@export var brake_accel := 45.0        # m/s²
@export var steering_angle := 20.0
@export var turn_speed := 5.0

## Grip lateral
@export var grip := 8.0                # normal
@export var drift_grip := 1.5          # mientras frenas

var speed := 0.0
var turn_input := 0.0
var current_grip := grip

@onready var mesh := $Mesh

func _process(delta):
    set_inputs(delta)

func _physics_process(delta):

    update_rotation(delta)
    update_velocity(delta)
    $Mesh/SpringArm3D.global_position = global_position


func set_inputs(delta):

    var throttle = Input.get_action_strength("R2_button")
    var brake = Input.get_action_strength("L2_button")

    ## velocidad objetivo
    if throttle > 0.05:
        speed = move_toward(speed, max_speed * throttle, acceleration * delta)
    elif brake > 0.05:
        speed = move_toward(speed, 0.0, brake_accel * delta)
    else:
        speed = move_toward(speed, 0.0, acceleration * 0.3 * delta)

    turn_input = Input.get_action_strength("left") - Input.get_action_strength("right")

    ## grip mientras derrapa
    current_grip = lerp(grip, drift_grip, brake)


func update_rotation(delta):

    if abs(speed) < 0.5:
        return

    var angle = deg_to_rad(steering_angle)

    mesh.rotate_y(turn_input * angle * turn_speed * delta)


func update_velocity(delta):

    var forward = -mesh.global_basis.z
    var right = mesh.global_basis.x

    var forward_speed = linear_velocity.dot(forward)
    var lateral_speed = linear_velocity.dot(right)

    ## acelerar hacia la velocidad deseada
    forward_speed = move_toward(forward_speed, speed, acceleration * delta)

    ## eliminar velocidad lateral
    lateral_speed = move_toward(lateral_speed, 0.0, current_grip * delta * abs(forward_speed))

    linear_velocity = forward * forward_speed + right * lateral_speed
