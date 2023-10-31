extends RigidBody2D

signal dead
signal lives_changed

enum {INIT, ALIVE, INVULNERABLE, DEAD}

@export var bullet_scene : PackedScene
@export var engine_power = 500
@export var fire_rate = 0.25
@export var spin_power = 8000

var can_shoot = true
var lives = 0: set = set_lives
var reset_pos = false
var rotation_dir = 0
var screensize = Vector2.ZERO
var state = INIT
var thrust = Vector2.ZERO
var wrap_offset

func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0 - wrap_offset, screensize.x + wrap_offset)
	xform.origin.y = wrapf(xform.origin.y, 0 - wrap_offset, screensize.y + wrap_offset)
	physics_state.transform = xform
	
	if reset_pos:
		physics_state.transform.origin = screensize / 2
		reset_pos = false

func _physics_process(_delta):
	constant_force = thrust
	constant_torque = rotation_dir * spin_power

func _process(_delta):
	get_input()

func _ready():
	change_state(ALIVE)
	screensize = get_viewport_rect().size
	$GunCooldown.wait_time = fire_rate
	wrap_offset = int($Sprite2D.texture.get_size().x / 2 * $Sprite2D.scale.x)

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

## Input handling & part of player movement
func get_input():
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func reset():
	reset_pos = true
	$Sprite2D.show()
	lives = 3
	change_state(ALIVE)

func set_lives(value):
	lives = value
	lives_changed.emit(lives)
	if lives <= 0:
		change_state(DEAD)
	else:
		change_state(INVULNERABLE)

## Creates bullet; movement, deletion, collision handled by its scene
func shoot():
	if state == INVULNERABLE:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start($Muzzle.global_transform)


func _on_gun_cooldown_timeout():
	can_shoot = true
