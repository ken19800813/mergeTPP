extends Node2D
class_name Dropper

@onready var cursor: Node2D = $fruit_cursor
@onready var score: Score = get_node("/root/ui/score")
@onready var screenshot: Sprite2D = get_node("/root/transition/screenshot")
@onready var screenshot_anim: AnimationPlayer = get_node("/root/transition")

const prefab: PackedScene = preload("res://fruit.tscn")
const original_size := Vector2(10, 10)
const border_const := 199.9
const fruit_textures := [
	preload("res://fruit_textures/01.png"), preload("res://fruit_textures/02.png"),
	preload("res://fruit_textures/03.png"), preload("res://fruit_textures/04.png"),
	preload("res://fruit_textures/05.png"), preload("res://fruit_textures/06.png"),
	preload("res://fruit_textures/07.png"), preload("res://fruit_textures/08.png"),
	preload("res://fruit_textures/09.png"), preload("res://fruit_textures/10.png"),
	preload("res://fruit_textures/11.png")
]

var cursor_y := 0.0
var target_x := 0.0
var drop_queued := false
var cooldown := 0.0
var screenshot_taken := false
var eat_release := true

var level := 1
var future_level := 1
var is_game_over := false
var ending_over := false
var ending_cooldown := 0.0
var cooldown_progress := 1.0

var fruit_rng := RandomNumberGenerator.new()
var future_fruit: Node2D

func _ready():
	fruit_rng.randomize()
	score.level_start()

	cursor_y = cursor.position.y
	init_future_fruit()
	update_cursor_sprite()
	update_future_sprite()

func init_future_fruit():
	future_fruit = cursor.duplicate()
	future_fruit.name = "FUTURE"
	add_child(future_fruit)
	move_child(future_fruit, 0)
	future_fruit.global_position = Vector2(-208, -280)
	cursor.global_position = future_fruit.global_position

func update_cursor_sprite():
	update_fruit_sprite(cursor, level)

func update_future_sprite():
	update_fruit_sprite(future_fruit, future_level)

func update_fruit_sprite(node: Node2D, lvl: int):
	var sprite = node.get_node_or_null("sprite") as Sprite2D
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.name = "sprite"
		node.add_child(sprite)

	var texture_index = clamp(lvl - 1, 0, fruit_textures.size() - 1)
	sprite.texture = fruit_textures[texture_index]

	var texture_size = sprite.texture.get_size()
	var fill_factor = 1.0
	var radius = 1.0
	var scale = (2 * radius * fill_factor) / max(texture_size.x, texture_size.y)
	sprite.scale = Vector2(scale, scale)

func _physics_process(delta: float):
	if is_game_over:
		if not screenshot_taken:
			take_screenshot()
		do_ending(delta)
		return

	cooldown -= delta
	var t = 1.0 - pow(0.0001, delta)
	var pos_t = 1.0 - pow(0.0000001, delta)

	cursor.scale = lerp(cursor.scale, original_size * Fruit.get_target_scale(level), t)
	future_fruit.scale = lerp(future_fruit.scale, original_size * Fruit.get_target_scale(future_level), t)

	var border_dist = border_const - cursor.scale.x
	if not drop_queued:
		target_x = clamp(get_local_mouse_position().x, -border_dist, border_dist)

	cursor.position = lerp(cursor.position, Vector2(target_x, cursor_y), pos_t)

	if Input.is_key_pressed(KEY_I) and cooldown < 0.13:
		drop_queued = true

	if drop_queued and abs(target_x - cursor.position.x) < 10:
		drop_fruit()
		drop_queued = false

func _input(event):
	if event is InputEventMouseButton:
		if not event.is_pressed() and not eat_release and cooldown <= 0:
			drop_queued = true
		else:
			eat_release = false
		maybe_restart()
	elif event is InputEventKey and event.physical_keycode == KEY_ESCAPE and OS.has_feature("editor"):
		get_tree().quit()

func drop_fruit():
	if is_game_over:
		return

	score.end_combo()
	var fruit = prefab.instantiate()
	fruit.level = level
	get_parent().add_child(fruit)

	var border_dist := border_const - Fruit.get_target_scale(level) * original_size.x
	fruit.global_position = Vector2(clamp(target_x, -border_dist, border_dist), cursor.global_position.y)
	fruit.linear_velocity = Vector2(0, 400)
	fruit.angular_velocity = fruit_rng.randf_range(-0.1, 0.1)

	level = future_level
	future_level = int(clamp(abs(fruit_rng.randfn(0.5, 2.3)) + 1, 1, 5))
	cooldown = 0.1 + min(0.2, level * 0.1)

	update_cursor_sprite()
	update_future_sprite()
	cursor.global_position = future_fruit.global_position

func game_over():
	if is_game_over:
		return
	is_game_over = true
	ending_over = false
	ending_cooldown = 1.0
	score.game_over()

	for c in get_parent().get_children():
		if c is Fruit:
			c.game_over = true

func maybe_restart():
	if is_game_over and ending_over and not screenshot_anim.is_playing():
		screenshot_anim.play("go_away")
		get_tree().reload_current_scene()

func take_screenshot():
	screenshot_taken = true
	var image = get_viewport().get_texture().get_image()
	var size = image.get_size()
	if size.x > size.y:
		var w = size.y
		image.crop(w, w)
	elif size.y > size.x * 1.3:
		var h = size.x * 1.3
		image.crop(size.x, h)
	image.flip_y()
	var texture = ImageTexture.create_from_image(image)
	screenshot.texture = texture

func do_ending(delta: float):
	ending_cooldown -= delta
	if ending_cooldown > 0.0 or ending_over:
		return
	ending_cooldown += fruit_rng.randf() * 0.25 * max(0.1, cooldown_progress) + 0.01 * max(0.1, cooldown_progress)
	ending_cooldown = max(ending_cooldown, delta * 0.75)
	cooldown_progress *= 0.97

	for c in get_parent().get_children():
		if c is Fruit and not c.popped:
			c.pop()  # ✅ 合成動畫觸發
			return
	ending_over = true
	screenshot_anim.play("screenshot")
