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


        rotate_y( - steering * steering_speed * steering_mult * delta)

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


    move_and_slide()