@tool
extends Node

func _ready():
	print("Build time: ", ProjectSettings.get_setting("application/config/build_datetime"))

func _process(_delta):
	if Engine.is_editor_hint():
		var t := Time.get_datetime_string_from_system()
		if ProjectSettings.get_setting("application/config/build_datetime") != t:
			ProjectSettings.set_setting("application/config/build_datetime", t)
			ProjectSettings.save()

func _on_shake_button_pressed():
	for fruit in get_tree().get_nodes_in_group("fruits"):  # 遍歷所有水果
		fruit.shake()
