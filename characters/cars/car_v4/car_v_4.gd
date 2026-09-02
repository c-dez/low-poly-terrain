# extends CharacterBody3D


# ## usando characterbody como punto de movimiento, la camara y hovers siguen a este
# # aplico comportamiento de carro / drift etc desde cero
# # hover, controlo su direccion y rotacion

# @onready var ray: RayCast3D = $RayCast3D
# @export var suspension_lenght: float = 0.8
# @export var spring_strength: float = 10.0

# @export var damper_strength: float = 5.0

# var previous_compression: float = 0.0


# func _physics_process(delta: float) -> void:
#     if ray.is_colliding():
#         var hit_point := ray.get_collision_point()

#         var distance := ray.global_position.distance_to(hit_point)

#         # compresion
#         var compression := 1.0 - (
#             distance / suspension_lenght
#         )

#         compression = clamp(
#             compression,
#             1.0,
#             0.0
#         )

#         #fuerza resorte

#         var spring_force := (
#             compression * spring_strength
#         )

#         #velocidad de compresion
#         var compression_velocity := (
#             compression - previous_compression
#         ) / delta

#         # fuerza amortiguador

#         var damper_force := (
#             compression_velocity * damper_strength
#         )

#         #fuerza final

#         var suspension_force := (
#             spring_force + damper_force
#         )

#         # posicion relativa a body
#         var force_position := (
#             ray.global_position - global_position
#         )

#         #aplicar fuerza
#         # elevar el body por encima de el suelo!
        

extends CharacterBody3D

@onready var ray: RayCast3D = $RayCast3D
@export_category('suspension')
@export var hover_height: float = 0.8
@export var hover_speed: float = 10.0
@export_category('controls')
@export var acceleration: float = 10.0
@export var max_speed: float = 20.0
@export var steering_speed: float = 2.5
@export var grip :float = 5.0


func _physics_process(delta: float) -> void:

    #HOVER ---------
    if ray.is_colliding():
        var hit_point := ray.get_collision_point()

        var distance := ray.global_position.distance_to(hit_point)

        var error := hover_height - distance

        velocity.y = error * hover_speed

    else:
        # velocity.y = 0.0
        velocity.y -= 10.0 * delta


    # body direcctions
    var forward := - global_transform.basis.z
    var right := global_transform.basis.x
    # direction speeds
    var forward_speed := velocity.dot(forward)
    var lateral_speed := velocity.dot(right)

    var input := Input.get_axis('L2_button', 'R2_button')

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


    # direction

    var steering := Input.get_axis(
        'left',
        'right'
    )

    if horizontal_velocity.length() > 0.1:
        rotate_y( - steering * steering_speed * delta)

    # grip lateral

    var lateral_velocity := right * lateral_speed
    velocity -= lateral_velocity * grip * delta


    move_and_slide()