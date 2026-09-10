@tool
extends Node3D
class_name Road3D



@export var road_width: float = 8.0:
    set(value):
        road_width = value
        update_road()
        
signal road_changed


func _ready() -> void:
    var path: Path3D = %Path3D
    if path.curve:
        if not path.curve.changed.is_connected(_on_curve_changed):
            path.curve.changed.connect(_on_curve_changed)

    update_road()


@onready var road: CSGPolygon3D = %Polygon
func update_road() -> void:
    if road == null:
        return

    var half_width := road_width / 2

    var polygon := PackedVector2Array([
        Vector2(-half_width, 0.0),
        Vector2(half_width, 0.0),
        Vector2(half_width, -0.5),
        Vector2(-half_width, -0.5)
    ])

    road.polygon = polygon

    road_changed.emit()
    pass


#SIGNALS
func _on_curve_changed() -> void:
    if not Engine.is_editor_hint():
        return

    road_changed.emit()