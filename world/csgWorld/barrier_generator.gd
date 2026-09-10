@tool
extends Node3D

## espacio entre barreras
@export var spacing: float = 2.0
## distancia desde path hacia los lados
@export var offset: float = 4.0
## altura de barrera
@export var height: float = 0.0

@export var barrier_scene: PackedScene

func _ready() -> void:
    if Engine.is_editor_hint():
        return
    
    # generate_one()
    generate_one_test()


func generate() -> void:
    clear_barriers()
    if barrier_scene == null:
        return

    var path: Path3D = %Path3D

    if path == null:
        return

    var curve := path.curve
    
    if curve == null:
        return

    var length := curve.get_baked_length()

    var distance := 0.0

    while distance < length:
        var poos := curve.sample_baked(distance, true)

        var next_position := curve.sample_baked(
            min(distance + 0.1, length), true
        )

        var direction := (
            next_position - poos
        ).normalized()

        var side := Vector3.UP.cross(direction).normalized()

        poos += side * offset

        var barrier = barrier_scene.instantiate()

        $Right.add_child(barrier)

        barrier.global_position = (
            path.to_global(poos)
        )

        distance += spacing
    pass


func clear_barriers() -> void:
    for child in $Right.get_children():
        child.queue_free()
    pass


func generate_one():
    if barrier_scene == null:
        return

    var path: Path3D = %Path3D
    var curve := path.curve

    if curve == null:
        return

    var length := curve.get_baked_length()

    if length <= 0.0:
        return

    var distance := 0.0

    var position := curve.sample_baked(distance, true)

    var next_position := curve.sample_baked(
        min(distance + 0.1, length),
        true
    )

    var direction := (
        next_position - position
    ).normalized()

    var side := Vector3.UP.cross(direction).normalized()

    position += side * offset
    position.y += height


    var barrier = barrier_scene.instantiate()

    $Right.add_child(barrier)

    barrier.global_position = path.to_global(position)

    var global_direction := path.to_global(position + direction) - path.to_global(position)

    barrier.look_at(
        barrier.global_position + global_direction,
        Vector3.UP
    )


func generate_one_test():
    if barrier_scene == null:
        return

    var path: Path3D = %Path3D
    var curve := path.curve

    if curve == null:
        return

    var length := curve.get_baked_length()

    if length <= 0.0:
        return

    var distance := 0.0

    while distance < length:
        var position := curve.sample_baked(distance, true)

        var next_position := curve.sample_baked(
            min(distance + 0.1, length),
            true
        )

        var direction := (
            next_position - position
        ).normalized()

        var side := Vector3.UP.cross(direction).normalized()

        position += side * offset
        position.y += height

        var barrier = barrier_scene.instantiate()

        $Right.add_child(barrier)

        barrier.global_position = path.to_global(position)

        var global_direction := (
            path.to_global(position + direction)
            - path.to_global(position)
        )

        barrier.look_at(
            barrier.global_position + global_direction,
            Vector3.UP
        )

        distance += spacing