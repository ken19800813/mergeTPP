extends Area2D

@onready var dropper : Dropper = $"/root/Node2D/dropper"
var restart_queued := false

func _input(event):
	if event is InputEventScreenTouch:
		if event.index == 4:
			dropper.game_over()

func _process(_delta):
	if restart_queued:
		dropper.game_over()
		return

	if Input.is_key_pressed(KEY_R):
		dropper.game_over()
		return

	for body in get_overlapping_bodies():
		if body is Fruit:
			dropper.game_over()

func _on_body_entered(body):
	if body is Fruit:
		restart_queued = true
