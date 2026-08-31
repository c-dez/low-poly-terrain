extends VehicleBody3D


@export var torque: int = 3500
## Smooth speed changes
@export var max_RPM: int = 1500
@export var turn_speed: float = 3.0
@export var turn_amount: float = 0.3
@export var wheel_front_left: VehicleWheel3D
@export var wheel_front_right: VehicleWheel3D
@export var wheel_rear_left: VehicleWheel3D
@export var wheel_rear_right: VehicleWheel3D
@export var suspension_travel := 0.05

var traction_wheel_left: VehicleWheel3D
var traction_wheel_right: VehicleWheel3D

@export var camera: SpringArm3D


var velocimetro_time := 0.5
var _velocimetro_time = velocimetro_time

# drifting
@export var normal_grip := 15.0
@export var drift_grip := 15.0
var grip

var is_drifting := false
var brake_strength: float = 0.0

@onready var label: Label = $Label
enum TRACTION {
    front,
    rear
}
@export var traction := TRACTION.rear


func _ready() -> void:
    for child in get_children():
        if child is VehicleWheel3D:
            child.suspension_travel = suspension_travel

    set_traction()


func _process(_delta: float) -> void:
    brake_strength = Input.get_action_strength('L2_button')
    # print(brake_strength)

    camera_toggle()


func _physics_process(delta: float) -> void:
    car_handling(delta)
    # QUE QUIERO LOGRAR:?
    #el manejo de el carro hasta ahora cumple con los minimos
    # pero requiere darle sabor 
    # agregar visuales
    # inclinar el modelo de el carro a derrapar
    # inclinar camera
    # particulas al derrapar / sonido


func car_handling(delta: float) -> void:
    # var dir := Input.get_action_strength('R2_button') 
    var dir := Input.get_action_strength('R2_button') - (Input.get_action_strength('L2_button') * 0.3)
    var steering_dir := Input.get_action_strength('left') - Input.get_action_strength('right')

    var RPM_left := traction_wheel_left.get_rpm()
    var RPM_right := traction_wheel_right.get_rpm()
    var RPM := (RPM_left + RPM_right / 2)

    engine_force = dir * torque * (1.0 - RPM / max_RPM)
    # steering = lerp(steering, steering_dir * turn_amount, turn_speed * delta)

    #no acelerando
    if dir == 0:
        brake = 4
        pass
    else:
        brake = 0

    #brake
    if Input.is_action_pressed('L2_button'):
        # magic numbers
        brake = lerp(brake, brake_strength * 10, 10 * delta)
        is_drifting = true
    else:
        is_drifting = false

    if is_drifting:
        grip = drift_grip
        wheel_rear_left.wheel_friction_slip = 1
        wheel_rear_right.wheel_friction_slip = 1
        steering = lerp(steering, steering_dir * turn_amount * brake_strength * 1.2, turn_speed * delta)
    else:
        grip = normal_grip
        steering = lerp(steering, steering_dir * turn_amount, turn_speed * delta)

        wheel_rear_left.wheel_friction_slip = 2
        wheel_rear_right.wheel_friction_slip = 2

    # Lateral velocity
    var right := global_transform.basis.x
    var lateral_speed: float = linear_velocity.dot(right)

    apply_central_force(
        - right * lateral_speed * grip * mass
    )

   #DEBUG 
    debug_label(lateral_speed, delta)
    

func camera_toggle() -> void:
    var d1 := 0.0
    var d2 := -5.0
    if Input.is_action_just_pressed('a_button'):
        if camera.spring_length == d1:
            camera.spring_length = d2
        else:
            camera.spring_length = d1

func debug_label(text, delta: float) -> void:
    _velocimetro_time -= delta
    if _velocimetro_time < 0:
        _velocimetro_time = velocimetro_time
        var _speed = linear_velocity.dot(global_transform.basis.z) * 3.6
        

        # var text = lateral_speed
        label.text = str(

            int(_speed)

            )

func set_traction() -> void:
    match traction:
        TRACTION.front:
            wheel_front_left.use_as_traction = true
            wheel_front_right.use_as_traction = true
            wheel_rear_left.use_as_traction = false
            wheel_rear_right.use_as_traction = false

            traction_wheel_left = wheel_front_left
            traction_wheel_right = wheel_front_right
            pass
        TRACTION.rear:
            wheel_front_left.use_as_traction = false
            wheel_front_right.use_as_traction = false
            wheel_rear_left.use_as_traction = true
            wheel_rear_right.use_as_traction = true

            traction_wheel_left = wheel_rear_left
            traction_wheel_right = wheel_rear_right
            pass
