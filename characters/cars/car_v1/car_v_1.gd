extends VehicleBody3D


@export var torque: int = 2000
## Smooth speed changes
@export var max_RPM: int = 600
@export var turn_speed: float = 3.0
@export var turn_amount: float = 0.4
@export var wheel_traction_left: VehicleWheel3D
@export var wheel_traction_right: VehicleWheel3D


func _physics_process(delta: float) -> void:
    var dir := Input.get_action_strength('R2_button') - Input.get_action_strength('L2_button')
    var steering_dir := Input.get_action_strength('left') - Input.get_action_strength('right')

    var RPM_left := wheel_traction_left.get_rpm()
    var RPM_right := wheel_traction_right.get_rpm()
    var RPM = (RPM_left + RPM_right / 2)

    engine_force = dir * torque * (1.0 - RPM / max_RPM)
    steering = lerp(steering, steering_dir * turn_amount, turn_speed * delta)

    if dir == 0:
        brake = 3

    