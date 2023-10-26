extends RigidBody2D

enum {INIT, ALIVE, INVULNERABLE, DEAD}

@export var engine_power = 500
@export var spin_power = 8000

var rotation_dir = 0
var state = INIT
var thrust = Vector2.ZERO

func _physics_process(_delta):
	constant_force = thrust
	constant_torque = rotation_dir * spin_power

func _process(_delta):
	get_input()

func _ready():
	change_state(ALIVE)

func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true)
		ALIVE:
			$CollisionShape2D.set_deferred("disabled", false)
		INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled", true)
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
	state = new_state

func get_input():
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
