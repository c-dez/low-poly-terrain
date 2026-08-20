extends Node3D

@onready var rear_camera:Camera3D = $SubViewport/RearCamera
@onready var marker:Marker3D = $Marker3D


func _process(_delta: float) -> void:
    rear_camera.global_basis = marker.global_basis
    rear_camera.global_position = marker.global_position
    rear_camera.global_basis.z *= -1

    pass
