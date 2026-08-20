extends RigidBody3D


@export var accel_curve: Curve
@export var brake_curve: Curve

var velocimetro_time = 0.2
var _velocimetro_time = velocimetro_time

var speed_input := 0.0
## grirar ruedas en radiants
var turn_input := 0.0
@export var acceleration := 600.0
@export var reverse_force := 150.0
# var brake_force := 2.5
@export var steering_angle := 25.0
## Cuando drift se suma este a steering
@export var drifting_steering_angle := 10.0
var _steering_angle 
# var steering_mult := 1.0
var turn_speed := 2.0
@export var speed_input_weight := 70.0

@onready var velocimetro_label: Label = $Label
@onready var mesh: MeshInstance3D = $Mesh
@onready var ray: RayCast3D = $Ray
# @onready var spring: SpringArm3D = $SpringArm3D
# @onready var interior:Node3D = $Interior


#debug
@onready var debug_label:Label = $DebugLabel

# drifting
var is_drifting:bool = false

## IDEAS para mejorar el feeling:
# inclinar camara al drifting
# dar un bost de velocidad al salir de un drift
# controlar drift con right analoge
#https://www.youtube.com/watch?v=lBD92kG9QI8 checar distancia de camara, puede resaltar el camino


func _ready() -> void:
    ray.top_level = true
    mesh.top_level = true
    # interior.top_level = true
    print('asd')
    pass


func _process(delta: float) -> void:
    set_acceleration(delta)
    set_turn_input()
    # interior.global_position = $Camera/Camera3D.global_position
    # interior.global_basis = $Camera/Camera3D.global_basis

    print(Input.is_action_just_pressed('R2_button'))

func _physics_process(delta: float) -> void:
    _set_object_global_position(mesh)
    _set_object_global_position(ray, Vector3(0, -0.8, 0))
    # _set_object_global_position(interior,Vector3(0.0,0,0))
    # interior.global_basis = mesh.global_basis


    # debug_label.text = str((is_drifting))

    if not ray.is_colliding():
        return

    girar(delta)
    apply_acceleration(delta)
    apply_lateral_grip(delta)
    apply_brake(delta)
    #reversa se tiene que invertir la direccion
    reverse()

    # capturar turn_input al superar x lateral_grip
    # var _lateral_speed := linear_velocity.dot(mesh.global_basis.x)
    # if abs(_lateral_speed) > 8.0:
        
    
    
    pass


func reverse() -> void:
    var brake := Input.get_action_strength('L2_button')
    # var reverse_force := 150.0
    if get_moving_speed(-mesh.global_basis.z) <= 1.0:
        if brake > 0.1:
            apply_central_force(-mesh.global_basis.z * -reverse_force * brake)


func set_acceleration(_delta: float) -> void:
    var throttle = Input.get_action_strength('R2_button')
    var accel_mult = accel_curve.sample(throttle)

    var brake = Input.get_action_strength('L2_button')
    # var brake_mult = brake_curve.sample(brake)

    # Suma a _steering_angle al frenar
    # _steering_angle = 20 + (brake_mult * 5)

    var speed = abs(get_moving_speed(-mesh.global_basis.z))
    var steering_bonus = clamp(speed / 10, 0.0, 1.0)

    _steering_angle = steering_angle + brake_curve.sample(brake) * drifting_steering_angle* steering_bonus

    var target_speed: float = acceleration * accel_mult
    if brake > 0.0:
        target_speed = 0.0

    #hace que la aplicacion de speed sea interpolado
    speed_input = move_toward(
        speed_input,
        target_speed,
        (speed_input_weight + accel_curve.sample(throttle) ) * _delta
    )

    pass


func velocimetro(delta: float, forward_speed: float) -> void:
    _velocimetro_time -= delta
    if _velocimetro_time < 0:
        velocimetro_label.text = str('%.2f' % (forward_speed * 3.6))
        _velocimetro_time = velocimetro_time
    pass


## toma los inputs de jugador y los convierte a radians para girar direccion de movimiento y los asigna a turn_input
func set_turn_input() -> void:
    turn_input = (Input.get_action_strength('left') - Input.get_action_strength('right')) * deg_to_rad(_steering_angle)
    pass


func girar(delta: float) -> void:
    if abs(get_moving_speed(-mesh.global_basis.z)) > 0.1:
        var current_basis := mesh.global_transform.basis
        var rotated_basis := current_basis.rotated(current_basis.y, turn_input)
        var smoothed_basis := current_basis.orthonormalized().slerp(
            rotated_basis.orthonormalized(), delta * turn_speed
        )
        mesh.global_basis = smoothed_basis.orthonormalized()
    pass


func apply_acceleration(delta: float) -> void:
    var forward := -mesh.global_transform.basis.z

    apply_central_force(forward * speed_input)
    velocimetro(delta, get_moving_speed(forward))

    # testing etiqueta muestra fuerzas laterales en km/h
    var right := mesh.global_transform.basis.x
    var lateral_label = $LateralLabel
    lateral_label.text = str('%.0f m/s' % (get_moving_speed(right)*3.6))


func apply_brake(delta: float) -> void:
    var brake := Input.get_action_strength('L2_button')

    if brake == 0.0:
        return

    #reverse
    if get_moving_speed(-mesh.global_basis.z) <= 1.0:
        return

    linear_velocity = linear_velocity.move_toward(
        Vector3.ZERO,
        brake * brake_curve.sample(brake) * 15 * delta
    )

    apply_central_force(
        mesh.global_basis.x *
        turn_input *
        abs(speed_input) *
        brake_curve.sample(brake) * 0.3
    )


func apply_lateral_grip(delta: float) -> void:
    var right = mesh.global_basis.x
    var lateral_speed := linear_velocity.dot(right)
    var brake = Input.get_action_strength('L2_button')

    var grip = lerp(15.0, 3.0, brake)
    linear_velocity -= right * lateral_speed

    linear_velocity += right * move_toward(
        lateral_speed,
        0.0,
        grip * delta
        )


## Calcula velocidad en m/s de movimiento hacia adelante, tambien puede calcul;ar la velocidad lateral dandole right_basis
func get_moving_speed(forward_basis: Vector3) -> float:
    var forward_speed := linear_velocity.dot(forward_basis)
    return forward_speed


## object.global_position = global_position
func _set_object_global_position(object: Node3D, _offset: Vector3 = Vector3.ZERO) -> void:
    object.global_position = global_position + _offset
    pass
