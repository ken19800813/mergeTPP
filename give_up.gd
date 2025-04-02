extends Button

@onready var dropper : Dropper = $"/root/Node2D/dropper"

func _on_pressed():
	print("asdfasdf")
	dropper.game_over()
