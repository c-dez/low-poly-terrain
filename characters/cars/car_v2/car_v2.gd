extends Node3D



@onready var ball:RigidBody3D = $Ball
@onready var car :Node3D= $Car
@onready var car_body = $Car/CarBody
# @onready var car:

@export var FL_wheel:MeshInstance3D
@export var FR_wheel:MeshInstance3D

@export var acceleration := 70.0
@export var steering := 12.0
@export var turn_speed := 5.0
@export var body_tilt := 30.0


var speed_input := 0.0
var rotate_input := 0.0


func _physics_process(delta: float) -> void:
    car.transform.origin = ball.transform.origin
    ball.apply_central_force(car_body.global_transform.basis.z * speed_input)
    rotate_car(delta)
    
func _process(delta: float) -> void:
    speed_input = (Input.get_action_strength('R2_button'))* acceleration
    rotate_input = deg_to_rad(steering) * (Input.get_action_strength('left') - Input.get_action_strength('right'))

    FL_wheel.rotation.y =rotate_input
    FR_wheel.rotation.y =rotate_input


func rotate_car(delta:float)->void:
    var new_basis = car.global_transform.basis.rotated(car.global_transform.basis.y, rotate_input)

    car.global_transform.basis = car.global_transform.basis.slerp(new_basis , turn_speed* delta)
    car.global_transform = car.global_transform.orthonormalized()
