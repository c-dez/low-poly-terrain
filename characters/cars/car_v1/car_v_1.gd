extends VehicleBody3D


@export var torque: int = 2000
## Smooth speed changes
@export var max_RPM: int = 600
@export var turn_speed: float = 3.0
@export var turn_amount: float = 0.4
@export var wheel_traction_left: VehicleWheel3D
@export var wheel_traction_right: VehicleWheel3D
@export var wheel_rear_left: VehicleWheel3D
@export var wheel_rear_right: VehicleWheel3D
@export var suspension_travel := 0.05

@export var camera: SpringArm3D


var velocimetro_time := 0.5
var _velocimetro_time = velocimetro_time

# drifting
@export var normal_grip := 8.0
@export var drift_grip := 1.5
var grip

var is_drifting := false
var brake_force
func _ready() -> void:
    for child in get_children():
        if child is VehicleWheel3D:
            child.suspension_travel = suspension_travel

func _process(delta: float) -> void:
    brake_force = Input.get_action_strength('L2_button')
    # print(brake_force)


func _physics_process(delta: float) -> void:
    # var dir := Input.get_action_strength('R2_button') 
    var dir := Input.get_action_strength('R2_button') - Input.get_action_strength('L2_button')*0.5
    var steering_dir := Input.get_action_strength('left') - Input.get_action_strength('right')

    var RPM_left := wheel_traction_left.get_rpm()
    var RPM_right := wheel_traction_right.get_rpm()
    var RPM = (RPM_left + RPM_right / 2)
    # var brake_force = Input.get_action_strength('L2_button')

    engine_force = dir * torque * (1.0 - RPM / max_RPM)
    # steering = lerp(steering, steering_dir * turn_amount, turn_speed * delta)

    #no acelerando
    if dir == 0:
        brake = 3
    else:
        brake = 0

    #brake
    if Input.is_action_pressed('L2_button'):
        brake = lerp(brake, brake_force * 1, 10 * delta)
        is_drifting = true
    else:
        is_drifting = false
        # brake = 0
        # print(brake)

    # Lateral velocity
    var right := global_transform.basis.x
    var lateral_speed: float = linear_velocity.dot(right)

    

    if is_drifting:
        grip = drift_grip * brake_force
        wheel_rear_left.wheel_friction_slip = 1.4
        wheel_rear_right.wheel_friction_slip = 1.4
        steering = lerp(steering, steering_dir * turn_amount *brake_force * 2.0, turn_speed * delta)


        
    else:
        grip = normal_grip
        steering = lerp(steering, steering_dir * turn_amount, turn_speed * delta)

        wheel_rear_left.wheel_friction_slip = 2
        wheel_rear_right.wheel_friction_slip = 2

    apply_central_force(
        - right * lateral_speed * grip * mass
    )
    

    # velocimetro
    _velocimetro_time -= delta
    if _velocimetro_time < 0:
        _velocimetro_time = velocimetro_time
        print(linear_velocity.dot(global_transform.basis.z) *3.6)
        # print(rad_to_deg(steering))
        # print(brake_force)


    #camera lerp
    # camera.look_at(global_transform.basis.z,Vector3.UP)
