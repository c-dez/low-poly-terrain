@tool
extends Node3D

@export_category("Road")
@export var road_width: float = 7.0
@export var road_resolution: int = 4

@export_category("Barriers")
@export var generate_left_barrier: bool = true
@export var generate_right_barrier: bool = true
@export var barrier_spacing: float = 2.0
@export var barrier_offset: float = 4.0

@export_category("Signs")
@export var generate_signs: bool = true
@export var sign_spacing: float = 100.0


func _ready():
    if Engine.is_editor_hint():
        return
    
    generate()

func generate():
    generate_road()
    # generate_barriers()
    # generate_signs()

func generate_road():
    var points := get_curve_points()

    # camino seria linea recta con 2 puntos
    if points.size() < 2:
        return

    var vertices := PackedVector3Array()
    var normals := PackedVector3Array()
    var uvs := PackedVector2Array()
    var indices := PackedInt32Array()

    for i in range(points.size()):
        var p = points[i].position
        var dir = points[i].direction

        var side = Vector3.UP.cross(dir).normalized()

        var left = p - side * road_width * 0.5
        var right = p + side * road_width * 0.5

        vertices.append(left)
        vertices.append(right)
        # por que dos?
        normals.append(Vector3.UP)
        normals.append(Vector3.UP)

        uvs.append(Vector2(0,i))
        uvs.append(Vector2(1,i))

    for i in range(points.size() - 1):
        var index = i * 2
        indices.append(index)
        indices.append(index + 2)
        indices.append(index + 1)

        indices.append(index + 1)
        indices.append(index + 2)
        indices.append(index + 3)

    var arrays = []
    arrays.resize(Mesh.ARRAY_MAX)

    arrays[Mesh.ARRAY_MAX] = vertices
    arrays[Mesh.ARRAY_NORMAL] = normals
    arrays[Mesh.ARRAY_TEX_UV] = uvs
    arrays[Mesh.ARRAY_INDEX] = indices

    var mesh = ArrayMesh.new()
    mesh.add_surface_from_arrays(
        Mesh.PRIMITIVE_TRIANGLES,
        arrays
    )

    %RoadMesh.mesh = mesh









    

## Obtiene los puntos en Path3D.curve
func get_curve_points() -> Array:
    var path: Path3D = %Path3D
    var curve := path.curve

    if curve == null:
        return []

    var points := []
    var length := curve.get_baked_length()

    for distance in range(0, int(length), road_resolution):
        var _position := curve.sample_baked(distance, true)

        var forward := curve.sample_baked(
            min(distance + 0.1, length),
            true
        )

        var direction := (forward - _position).normalized()
        points.append({
            "position": _position,
            "direction": direction
        })


    return points
