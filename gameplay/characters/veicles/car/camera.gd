extends SpringArm3D
class_name Camera

@onready var mesh: MeshInstance3D = owner.get_node("Mesh")
@export var hight_offset: float = 1.0
@export var weight: float = 20.0
var _offset: float = 0
var current_camera := camera.first
enum camera {
    first,
    third
}


func _ready() -> void:
    top_level = true


func _process(delta: float) -> void:
    _set_camera_position(delta)
   
           
        
func _set_camera_position(delta) -> void:
    global_position = Vector3(mesh.global_position.x, mesh.global_position.y + hight_offset, mesh.global_position.z)

    var lateral = owner.linear_velocity.dot(mesh.global_basis.x)

    _offset = lerp(
        0.0,
        lateral * 1.2,
        4 * delta
    )

    var camera_target := mesh.rotation.y

    rotation.y = lerp_angle(
        rotation.y,
        camera_target + _offset,
        weight * delta
    )

    
    pass
