@tool
extends Node3D


@export var road_width: float = 8.0:
    set(value):
        road_width = value
        update_road()
        
signal road_changed


func update_road() -> void:
    var road: CSGPolygon3D = %CSGPolygon3D
    if road == null:
        return

    var half_width := road_width / 2

    var polygon := PackedVector2Array([
        Vector2(-half_width, 0.0),
        Vector2( half_width, 0.0),
        Vector2( half_width, -0.2),
        Vector2(-half_width, -0.2)
    ])

    road.polygon = polygon

    road_changed.emit()
    pass