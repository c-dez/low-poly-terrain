extends CharacterBody3D

@onready var ray: RayCast3D = $RayCast3D
@export_category('suspension')
@export var hover_height: float = 0.8
@export var hover_speed: float = 10.0
@export_category('controls')
@export var acceleration: float = 50.0
@export var max_speed: float = 100.0
@export var steering_speed: float = 1.0
@export var grip :float = 5.0
@export_category('dift')
@export var drift_grip : float = 1.0
@export var drift_force : float = 5.0
@export var drift_steering_mult : float = 1.3

@onready var mesh :MeshInstance3D = $Mesh

@export var fl_wheel:MeshInstance3D 
@export var fr_wheel:MeshInstance3D


func _ready() -> void:
    # ray.add_exception(collision)
    pass
func _physics_process(delta: float) -> void:

    
    # variables
    # body direcctions
    var forward := - global_transform.basis.z
    var right := global_transform.basis.x
    # direction speeds
    var forward_speed := velocity.dot(forward)
    var lateral_speed := velocity.dot(right)

    #debug
    var label :Label = $Label
    label.text = str(int(forward_speed *3.6)/2)
    # label.text = str(velocity.x)

    var drifting := Input.is_action_pressed('L2_button')
    # var drifting := Input.is_action_pressed('a_button')
    # var input := Input.get_axis('L2_button', 'R2_button')
    var input := Input.get_action_strength('R2_button')

    #HOVER ---------
    
    if ray.is_colliding():
        var hit_point := ray.get_collision_point()

        var distance := ray.global_position.distance_to(hit_point)

        var error := hover_height - distance

        velocity.y = error * hover_speed
    else:
        # velocity.y = 0.0
        velocity.y -= 10.0 * delta



    velocity += forward * input * 10.0 * delta

    # velocidad maxima
    var horizontal_velocity := Vector3(
        velocity.x,
        0.0,
        velocity.z
    )
    if horizontal_velocity.length() > max_speed:
        horizontal_velocity = horizontal_velocity.normalized() * max_speed

        velocity.x = horizontal_velocity.x
        velocity.z = horizontal_velocity.z


    # steering

    var steering := Input.get_axis(
        'left',
        'right'
    )

    if horizontal_velocity.length() > 0.1:
        var steering_mult := 1.0
        if drifting:
            steering_mult = drift_steering_mult

        var value := -steering * steering_speed * steering_mult * delta
        rotate_y(value)

    # grip lateral

    var lateral_velocity := right * lateral_speed
    velocity -= lateral_velocity * grip * delta


    # drifting
   
    if drifting and forward_speed > 20.0:
        grip = drift_grip
        velocity += (right * drift_force * delta )
        print(right * drift_force * delta )
    else:
        grip = 5.0

    var camera:Camera3D = $Camera3D
    var camera_forward:= - camera.global_transform.basis.z

    var target_angle := atan2(
        camera_forward.x,
        camera_forward.z
    )
    # extra giro
    if drifting and forward_speed > 20.0:
        var drift_angle := deg_to_rad(40.0)

        # izquierda/derecha
        target_angle -= steering * drift_angle

        mesh.global_rotation.y = lerp_angle(
            mesh.global_rotation.y,
            target_angle,
            4 * delta
        )

        # rotar en x para simular frenado
        mesh.rotation.x = deg_to_rad(5.0)
        # camera.fov = 60
        camera.fov = lerp(
            camera.fov,
            70.0, 
            10.0 *delta
        )
        camera.position.z = lerp(
            camera.position.z,
            6.0,
            10.0 * delta
        )

    else:
        # camera.fov = 80
        mesh.rotation.x = deg_to_rad(0.0)
        camera.fov = lerp(
            camera.fov,
            85.0, 
            1.0 *delta
        )
        camera.position.z = lerp(
            camera.position.z,
            8.0,
            1.0 * delta
        )

   
    mesh.global_rotation.y = lerp_angle(
        mesh.global_rotation.y,
        target_angle,
        2 * delta
    )

    move_and_slide()


    #girar ruedas
    fl_wheel.rotation.y = deg_to_rad(45) *- steering
    fr_wheel.rotation.y = deg_to_rad(45) *- steering
        

func rotate_mesh(value):
    # necesito angulo camara comparado con angulo body


    pass
