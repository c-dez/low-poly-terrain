extends Node


## Controla el mesh al drifting
@export var car: MeshInstance3D
@export var max_lateral_speed: float = 10.0
@export var max_y_rotation: float = 50.0
var rotation_smooth: float = 10.0

var max_x_rotation: float = 4.0

    
func _physics_process(delta: float) -> void:
    rotate_mesh_y(delta)
    brake_animation(delta)

## rota el mesh en x para simular inercia al frenar
func brake_animation(delta: float) -> void:
    if owner.is_drifting:
        car.rotation.x = lerp(
            car.rotation.x,
            deg_to_rad(max_x_rotation),
            rotation_smooth * delta
        )
    else:
        car.rotation.x = lerp(
            car.rotation.x,
            0.0,
            5 * delta
        )

    
func rotate_mesh_y(delta: float) -> void:
    var right: Vector3 = owner.global_transform.basis.x
    var lateral_speed = owner.linear_velocity.dot(right)

    var lateral_factor: float = clamp(
        lateral_speed / max_lateral_speed,
        -1.0,
        1.0
    )

    # calcular rotacion objetivo
    var target_rotation: float = - deg_to_rad(max_y_rotation) * lateral_factor

    if owner.is_drifting:
        # suavizar rotacion
        car.rotation.y = lerp(
            car.rotation.y,
            target_rotation,
            rotation_smooth * delta
        )
    else:
        # al salir de drift rota de regreso a 0
        car.rotation.y = lerp(
            car.rotation.y,
            0.0,
            1.0 * delta
        )
    pass
