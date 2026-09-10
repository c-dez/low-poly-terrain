@tool
extends Node3D

## espacio entre barreras
@export var spacing: float = 2.0
## distancia desde path hacia los lados
@export var offset: float = 4.0
## altura de barrera
@export var height: float = 0.0

@export var left_enable : bool = false
@export var right_enable : bool = false

## Llama a generate_barriers()
@export var generate: bool = false:
    set(value):
        generate = value
        if value and Engine.is_editor_hint():
            call_deferred('generate_barriers')
            generate = false
## Lama a clear_barriers()
@export var clear: bool = false:
    set(value):
        clear = value
        if value and Engine.is_editor_hint():
            call_deferred('clear_barriers')
            clear = false

@export var barrier_scene: PackedScene


func _ready() -> void:
    if Engine.is_editor_hint():
        return
    
    generate_barriers()


func clear_barriers() -> void:
    for child in %Right.get_children():
        child.queue_free()


func generate_barriers() -> void: # generate_one()
    clear_barriers()

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
        var pos := curve.sample_baked(distance, true)

        var next_position := curve.sample_baked(
            min(distance + 0.1, length),
            true
        )

        var direction := (
            next_position - pos
        ).normalized()

        var side := Vector3.UP.cross(direction).normalized()

        pos += side * offset
        pos.y += height

        var barrier = barrier_scene.instantiate()

        $Right.add_child(barrier)

        barrier.global_position = path.to_global(pos)

        var global_direction := (
            path.to_global(pos + direction)
            - path.to_global(pos)
        )

        barrier.look_at(
            barrier.global_position + global_direction,
            Vector3.UP
        )

        distance += spacing
        

