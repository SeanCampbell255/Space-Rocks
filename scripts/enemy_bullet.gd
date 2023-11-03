extends Area2D

@export var damage = 15
@export var speed = 1000

func _process(delta):
	position += transform.x * speed * delta

func start(_pos, _dir):
	position = _pos
	rotation = _dir.angle()

func _on_body_entered(body):
	if body.name == "Player":
		body.shield -= damage
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
