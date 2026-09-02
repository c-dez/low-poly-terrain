extends RigidBody3D
class_name CarV3

@export var suspension_lenght: float = 0.8
@export var spring_strength: float = 10.0
@export var damper_strength: float = 5.0

@onready var suspension_rays: Array[RayCast3D] = [
    $FLRay,
    $FRRay,
    $RLRay,
    $RRRay
]

var previous_compression := [0.0, 0.0, 0.0, 0.0]


func _physics_process(delta: float) -> void:
    for i in suspension_rays.size():
        apply_suspension(
            suspension_rays[i],
            i,
            delta
        )


func apply_suspension(
    ray: RayCast3D,
    index: int,
    delta: float
) -> void:

    # No toca el suelo
    if not ray.is_colliding():
        previous_compression[index] = 0.0
        return

    # Punto donde el RayCast toca el terreno
    var hit_point := ray.get_collision_point()

    # Distancia entre la rueda y el suelo
    var distance := ray.global_position.distance_to(
        hit_point
    )

    # Compresión de la suspensión
    var compression := 1.0 - (
        distance / suspension_lenght
    )

    compression = clamp(
        compression,
        0.0,
        1.0
    )

    # Fuerza del resorte
    var spring_force := (
        compression * spring_strength
    )

    # Velocidad de compresión
    var compression_velocity = (
        compression - previous_compression[index]
    ) / delta

    # Fuerza del amortiguador
    var damper_force = (
        compression_velocity * damper_strength
    )

    # Fuerza final
    var suspension_force = (
        spring_force + damper_force
    )

    # Posición RELATIVA al RigidBody
    var force_position := (
        ray.global_position - global_position
    )

    # Aplicar fuerza
    apply_force(
        Vector3.UP * suspension_force,
        force_position
    )

    # Guardar compresión para el siguiente frame
    previous_compression[index] = compression