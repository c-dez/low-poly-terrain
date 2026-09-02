extends RigidBody3D

var min_angle = deg_to_rad(0.0)
var max_angle = deg_to_rad(45.0)
var engine_force = 10.0
var steering_torque = 5.0
var max_steering_speed = 2.0

func _physics_process(delta: float) -> void:
    var dir = Input.get_axis('left', 'right')

    if Input.is_action_pressed('R2_button'):
        var forward = -global_transform.basis.z
        apply_central_force( forward * engine_force)


    #girar
    var steering = -dir

    if steering != 0.0:
        apply_torque(
                Vector3.UP * steering * steering_torque
            )
