extends Node2D
class_name Dropper

#@onready var cursor: Node2D = $fruit_cursor
#@onready var score: Score = $"/root/ui/score"
@onready var cursor: Node2D = get_node_or_null("fruit_cursor")
@onready var score: Score = get_node_or_null("/root/ui/score")
var cursor_y: float
var future_fruit: Node2D
var target_x := 0.0
var drop_queued := false

var level := 1
var future_level := 1
const prefab: PackedScene = preload("res://fruit.tscn")
const original_size := Vector2(10, 10)
var cooldown := 0.0
const border_const := 199.9

var is_game_over: bool = false
var ending_over: bool = false
var ending_cooldown: float = 0.0

var fruit_rng := RandomNumberGenerator.new()
#@onready var screenshot: Sprite2D = $"/root/transition/screenshot"
#@onready var screenshot_anim: AnimationPlayer = $"/root/transition"
@onready var screenshot: Sprite2D = get_node_or_null("/root/transition/screenshot")
@onready var screenshot_anim: AnimationPlayer = get_node_or_null("/root/transition")
var screenshot_taken := false
var eat_release := true

# Load the textures for the fruit preview
# const fruit_textures := [
# 	preload("res://fruit_textures/cherry.png"), # level 1
# 	preload("res://fruit_textures/strawberry.png"), # level 2
# 	preload("res://fruit_textures/grape.png"), # level 3
# 	preload("res://fruit_textures/orange.png"), # level 4
# 	preload("res://fruit_textures/persimmon.png"), # level 5
# 	preload("res://fruit_textures/apple.png"), # level 6
# 	preload("res://fruit_textures/pear.png"), # level 7
# 	preload("res://fruit_textures/peach.png"), # level 8
# 	preload("res://fruit_textures/pineapple.png"), # level 9
# 	preload("res://fruit_textures/melon.png"), # level 10
# 	preload("res://fruit_textures/watermelon.png"), # level 11
# ]
const fruit_textures := [
	preload("res://fruit_textures/01.png"), # level 1 (cherry)
	preload("res://fruit_textures/02.png"), # level 2 (strawberry)
	preload("res://fruit_textures/03.png"), # level 3 (grape)
	preload("res://fruit_textures/04.png"), # level 4 (orange)
	preload("res://fruit_textures/05.png"), # level 5 (persimmon)
	preload("res://fruit_textures/06.png"), # level 6 (apple)
	preload("res://fruit_textures/07.png"), # level 7 (pear)
	preload("res://fruit_textures/08.png"), # level 8 (peach)
	preload("res://fruit_textures/09.png"), # level 9 (pineapple)
	preload("res://fruit_textures/10.png"), # level 10 (melon)
	preload("res://fruit_textures/11.png"), # level 11 (watermelon)
]



func _ready():
	
	print_debug("cursor:", cursor)
	print_debug("score:", score)
	print_debug("future_fruit:", future_fruit)
	print_debug("Fruit 類別:", Fruit)
	
	fruit_rng.set_seed(7) # Chosen with a fair dice roll (also the sequence starts with two small fruits)
	score.level_start()
	

	

	
	
	
	# Set up the future fruit preview
	future_fruit = cursor.duplicate()
	


	add_child(future_fruit)
	move_child(future_fruit, 0)
	future_fruit.name = "FUTURE"
	future_fruit.global_position = Vector2(-208, -280)
	
	cursor_y = cursor.position.y
	cursor.global_position = future_fruit.global_position
	
	# Set up the sprite for the current fruit
	update_cursor_appearance()
	
	# Set up the sprite for the future fruit
	update_future_fruit_appearance()

# Update cursor appearance based on current level
func update_cursor_appearance():
	var cursor_sprite = cursor.get_node_or_null("sprite")
	if cursor_sprite:
		var texture_index = clamp(level - 1, 0, fruit_textures.size() - 1)
		cursor_sprite.texture = fruit_textures[texture_index]
		
		# 使用與fruit.gd中完全相同的計算邏輯
		if cursor_sprite.texture:
			var texture_size = cursor_sprite.texture.get_size()
			
			# 使用相同的填充因子(1.4)以保持一致
			var fill_factor = 1.0
			
			# 將碰撞直徑設置為等同於fruit.gd中實際水果的大小
			# 注意cursor預設scale已經是10，所以基礎半徑用1.0，但乘以等級縮放因子
			var base_collision_radius = 1.0
			var level_scale_factor = 1 # Fruit.get_target_scale(level) / Fruit.get_target_scale(1)
			
			# 計算目標直徑，與fruit.gd保持一致
			var target_diameter = 2 * base_collision_radius * level_scale_factor * fill_factor
			var scale_factor = target_diameter / max(texture_size.x, texture_size.y)
			
			# 應用到sprite上
			cursor_sprite.scale = Vector2(scale_factor, scale_factor)
	else:
		# If there's no sprite node, create one
		var sprite = Sprite2D.new()
		sprite.name = "sprite"
		var texture_index = clamp(level - 1, 0, fruit_textures.size() - 1)
		sprite.texture = fruit_textures[texture_index]
		cursor.add_child(sprite)
		
		# 立即更新剛創建的sprite的大小
		if sprite.texture:
			var texture_size = sprite.texture.get_size()
			
			var fill_factor = 1.0
			var base_collision_radius = 1.0
			var level_scale_factor = 1 # Fruit.get_target_scale(level) / Fruit.get_target_scale(1)
			var target_diameter = 2 * base_collision_radius * level_scale_factor * fill_factor
			var scale_factor = target_diameter / max(texture_size.x, texture_size.y)
			sprite.scale = Vector2(scale_factor, scale_factor)

# Update future fruit appearance based on future level
func update_future_fruit_appearance():
	var future_sprite = future_fruit.get_node_or_null("sprite")
	if future_sprite:
		var texture_index = clamp(future_level - 1, 0, fruit_textures.size() - 1)
		future_sprite.texture = fruit_textures[texture_index]
		
		# 使用與fruit.gd中完全相同的計算邏輯
		if future_sprite.texture:
			var texture_size = future_sprite.texture.get_size()
			
			# 使用相同的填充因子(1.4)以保持一致
			var fill_factor = 1.0
			
			# 將碰撞直徑設置為等同於fruit.gd中實際水果的大小
			var base_collision_radius = 1.0
			var level_scale_factor = 1 # Fruit.get_target_scale(future_level) / Fruit.get_target_scale(1)
			
			# 計算目標直徑，與fruit.gd保持一致
			var target_diameter = 2 * base_collision_radius * level_scale_factor * fill_factor
			var scale_factor = target_diameter / max(texture_size.x, texture_size.y)
			
			# 應用到sprite上
			future_sprite.scale = Vector2(scale_factor, scale_factor)
	else:
		# If there's no sprite node, create one
		var sprite = Sprite2D.new()
		sprite.name = "sprite"
		var texture_index = clamp(future_level - 1, 0, fruit_textures.size() - 1)
		sprite.texture = fruit_textures[texture_index]
		future_fruit.add_child(sprite)
		
		# 立即更新剛創建的sprite的大小
		if sprite.texture:
			var texture_size = sprite.texture.get_size()
			
			var fill_factor = 1.0
			var base_collision_radius = 1.0
			var level_scale_factor = 1 # Fruit.get_target_scale(future_level) / Fruit.get_target_scale(1)
			var target_diameter = 2 * base_collision_radius * level_scale_factor * fill_factor
			var scale_factor = target_diameter / max(texture_size.x, texture_size.y)
			sprite.scale = Vector2(scale_factor, scale_factor)

func maybe_restart():
	if is_game_over and ending_over and not screenshot_anim.is_playing():
		screenshot_anim.play("go_away")
		get_tree().reload_current_scene()

func make_fruit():
	if is_game_over:
		return
	
	score.end_combo()
	var fruit = prefab.instantiate()
	fruit.level = level
	#$"..".add_child(fruit)
	if get_parent() != null:
		get_parent().add_child(fruit)
	else:
		print_debug("Dropper 沒有父節點，無法新增 fruit")
		
	fruit.global_position.y = cursor.global_position.y
	var border_dist := border_const - Fruit.get_target_scale(level) * original_size.x
	fruit.global_position.x = clamp(target_x, -border_dist, border_dist)
	fruit.linear_velocity.y = 400.0
	fruit.linear_velocity.x = 0
	fruit.angular_velocity = fruit_rng.randf() * 0.2 - 0.1
	
	# Update the levels for the next fruits
	level = future_level
	future_level = int(clamp(abs(fruit_rng.randfn(0.5, 2.3)) + 1, 1, 5))
	cooldown = 0.1 + min(0.2, level * 0.1)
	
	# Update the appearances
	update_cursor_appearance()
	update_future_fruit_appearance()
	
	cursor.global_position = future_fruit.global_position
	cursor.scale = original_size * Fruit.get_target_scale(level)

func _physics_process(delta: float):
	if is_game_over:
		if not screenshot_taken:
			take_screenshot()
		do_ending(delta)

	cooldown -= delta
	var t: float = 1.0 - pow(0.0001, delta)
	
	#var target_scale := original_size * Fruit.get_target_scale(level)
	var scale_factor = 1.0
	#if "get_target_scale" in Fruit:
		#scale_factor = Fruit.get_target_scale(level)
	#else:
		#push_error("Fruit 類別內找不到 get_target_scale 方法");
	if not Engine.has_singleton("Fruit"):
		print_debug("Fruit 類別不存在！請確認 Fruit.gd 是否正確載入")
	elif not "get_target_scale" in Fruit:
		print_debug("Fruit 類別沒有 get_target_scale 方法！")

	var target_scale := original_size * Fruit.get_target_scale(level)

	
	
	cursor.scale = lerp(cursor.scale, target_scale, t)
	var border_dist := border_const - cursor.scale.x
	
	if not drop_queued:
		target_x = clamp(get_local_mouse_position().x, -border_dist, border_dist)

	if not is_game_over:
		var pos_t: float = 1.0 - pow(0.0000001, delta)
		var target_pos := Vector2(target_x, cursor_y)
		cursor.position = lerp(cursor.position, target_pos, pos_t)

	future_fruit.scale = lerp(future_fruit.scale, original_size * Fruit.get_target_scale(future_level), t)

	#if Input.is_key_pressed(KEY_I) and cooldown < 0.13:
		#drop_queued = true
		#maybe_restart()
		
	if Input.is_key_pressed(KEY_I) and cooldown < 0.13:
		drop_queued = true
		
	if drop_queued and abs(target_x - cursor.position.x) < 10:
		make_fruit()
		drop_queued = false

func _input(event):
	if event is InputEventMouseButton:
		if not event.is_pressed() and not eat_release:
			if cooldown <= 0:
				drop_queued = true
		else:
			eat_release = false
		maybe_restart()
	elif event is InputEventKey:
		if event.physical_keycode == KEY_ESCAPE and OS.has_feature("editor"):
			get_tree().quit()

#func game_over():
	#if is_game_over:
		#return
	#is_game_over = true
	#ending_over = false
	#ending_cooldown = 1.0
	#score.game_over()
#
	#var parent: Node2D = $".."
	#for c in parent.get_children():
		#if c is Fruit:
			#c.game_over = true
			
func game_over():
	if is_game_over:
		return
	is_game_over = true
	ending_over = false
	ending_cooldown = 1.0
	if score:
		score.game_over()
	
	var fruits = []
	for c in $"..".get_children():
		if c is Fruit:
			fruits.append(c)
	
	for f in fruits:
		f.game_over = true


func take_screenshot():
	screenshot_taken = true
	var data: Image = get_viewport().get_texture().get_image()
	if data.get_size().x > data.get_size().y:
		var w := data.get_size().y
		var h := data.get_size().y
		var offset_x = (data.get_size().x - w) / 2
		var data_cropped: Image = Image.new()
		data_cropped.copy_from(data)
		data_cropped.blit_rect(data, Rect2(offset_x, 0, w, h), Vector2.ZERO)
		data_cropped.crop(w, h)
		data = data_cropped
	elif data.get_size().y > data.get_size().x * 1.3:
		var w := data.get_size().x
		var h := w * 1.3
		var offset_y = (data.get_size().y - h) / 2
		var data_cropped: Image = Image.new()
		data_cropped.copy_from(data)
		data_cropped.blit_rect(data, Rect2(0, offset_y, w, h), Vector2.ZERO)
		data_cropped.crop(w, h)
		data = data_cropped
		
	data.flip_y()
	false # data.lock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	var border_color := Color(1, 1, 1, 1)
	border_color.r8 = 26 # match the fade color to blend the borders
	border_color.g8 = 26
	border_color.b8 = 26
	for x in range(data.get_size().x):
		data.set_pixel(x, 0, border_color)
		data.set_pixel(x, data.get_size().y - 1, border_color)
	for y in range(data.get_size().y):
		data.set_pixel(0, y, border_color)
		data.set_pixel(data.get_size().x - 1, y, border_color)
	false # data.unlock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	var img: ImageTexture = ImageTexture.create_from_image(data)
	var aspect := data.get_size().x / (float)(data.get_size().y)
	img.set_size_override(Vector2(aspect, 1) * ProjectSettings.get_setting("display/window/size/viewport_height"))
	screenshot.texture = img

var cooldown_progress := 1.0

func do_ending(delta: float):
	ending_cooldown -= delta
	if ending_cooldown > 0.0 or ending_over:
		return
	ending_cooldown += fruit_rng.randf() * 0.25 * max(0.1, cooldown_progress) + 0.01 * max(0.1, cooldown_progress)
	ending_cooldown = max(ending_cooldown, delta * 0.75)
	cooldown_progress *= 0.97
	var parent: Node2D = $".."
	for c in parent.get_children():
		if c is Fruit and not c.popped:
			c.pop()
			return
	ending_over = true
	screenshot_anim.play("screenshot")
