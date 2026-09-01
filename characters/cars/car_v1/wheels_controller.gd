extends Node3D

# rota y gira meshes de ruedas
@export var fl_wheel:MeshInstance3D
@export var fr_wheel:MeshInstance3D
var steering_dir:float

func _process(delta: float) -> void:
    steering_dir = Input.get_action_strength('left') - Input.get_action_strength('right')

    fl_wheel.rotation.y = lerp(
        fl_wheel.rotation.y,
        steering_dir,
        5.0 * delta
    )

    fr_wheel.rotation.y = lerp(
        fl_wheel.rotation.y,
        steering_dir,
        1.0 * delta
    )
