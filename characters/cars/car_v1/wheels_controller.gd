extends Node

# rota y gira meshes de ruedas
@export var fl_wheel:MeshInstance3D
@export var fr_wheel:MeshInstance3D
@export var rl_wheel:MeshInstance3D
@export var rr_wheel:MeshInstance3D
var steering_dir:float
var throttle:float
var speed:float
var rotation_factor:float

func _process(delta: float) -> void:
    steering_dir = Input.get_action_strength('left') - Input.get_action_strength('right')
    
    if Input.is_action_pressed('R2_button') :
        throttle = 0.05

    else:
        throttle = 0.0


    speed = owner.linear_velocity.dot(owner.global_basis.z)

    fl_wheel.rotation.y = lerp(
        fl_wheel.rotation.y,
        steering_dir,
        5.0 * delta
    )

    fr_wheel.rotation.y = lerp(
        fl_wheel.rotation.y,
        steering_dir,
        2.0 * delta
    )

    throttle= lerp(
        throttle,
        1.0,
        0.5*delta
    )
    if speed > 1.0:
        rotation_factor = 0.05
    else:
        rotation_factor = 0.0
        fl_wheel.rotation.x = 0
        fr_wheel.rotation.x = 0
        rl_wheel.rotation.x = 0
        rr_wheel.rotation.x = 0

    #front wheels    
    fl_wheel.rotation.x += throttle + rotation_factor 
    fl_wheel.rotation.x += 0.0
    fr_wheel.rotation.x += throttle + rotation_factor
    # rear wheels
    rl_wheel.rotation.x += rotation_factor + throttle
    rr_wheel.rotation.x += rotation_factor + throttle
    
