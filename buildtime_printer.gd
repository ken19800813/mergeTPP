@tool
extends Node

const BUILD_TIME_KEY := "application/config/build_datetime"

func _ready():
	if Engine.is_editor_hint():
		_update_build_time()
	else:
		if ProjectSettings.has_setting(BUILD_TIME_KEY):
			print("Build time:", ProjectSettings.get_setting(BUILD_TIME_KEY))
		else:
			print("No build time recorded.")

func _process(_delta):
	if Engine.is_editor_hint():
		set_process(false)
		_update_build_time()

func _update_build_time():
	var current_time := Time.get_datetime_string_from_system()
	var stored_time := ""
	if ProjectSettings.has_setting(BUILD_TIME_KEY):
		stored_time = ProjectSettings.get_setting(BUILD_TIME_KEY)

	if stored_time != current_time:
		ProjectSettings.set_setting(BUILD_TIME_KEY, current_time)
		ProjectSettings.save()
		print("Updated build time to:", current_time)
