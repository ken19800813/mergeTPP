extends RigidBody2D
class_name Fruit




@export var level := 1
var current_scale := Vector2(1, 1)
var cooldown := 0.1
@onready var mesh := $MeshInstance2D
@onready var sprite := $Sprite2D
@onready var collider := $CollisionShape2D
var absorber
var popped := false
var game_over := false
var free_after_pop := 2.0

const baked_colors := [
		Color(0.9725, 0, 0.2471, 1),
		Color(0.9608, 0.4157, 0.2824, 1),
		Color(0.6039, 0.3922, 0.9804, 1),
		Color(0.9804, 0.698, 0.0157, 1),
		Color(0.9725, 0.5176, 0.0706, 1),
		Color(0.9412, 0.3765, 0.302, 1),
		Color(0.9725, 0.9294, 0.4588, 1),
		Color(0.9765, 0.7765, 0.7333, 1),
		Color(0.949, 0.8118, 0.0118, 1),
		Color(0.6, 0.8471, 0.0588, 1),
		Color(0.0784, 0.5686, 0.0314, 1),
		#Color(0.0784, 0.5686, 0.0314, 1),
	]
#export var colors := baked_colors

# Fruit textures for each level
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
	#preload("res://fruit_textures/12.png"), # level 12 (watermelon)
]



static func get_target_scale(level_: int) -> float:
	return [
		1, # cherry
		1.5, # strawberry
		2.1, # grape
		2.4, # orange
		3, # persimmon
		3.6, # apple
		3.8, # pear
		5.3, # peach
		6.1, # pineapple
		8.5, # melon
		10 # watermelon
		][level_ - 1] * 1.42

static func get_color(level_: int) -> Color:
	return baked_colors[clamp(level_ - 1, 0, baked_colors.size() - 1)]
	


static func get_target_mass(level_: int) -> float:
	#return pow(get_target_scale(level_), 2.0)
	var index = clamp(level_ - 1, 0, 10) # 0 ~ 10 之間
	return [
		1, 1.5, 2.1, 2.4, 3, 3.6, 3.8, 5.3, 6.1, 8.5, 10
	][index] * 1.42

func _ready():
	#if false and colors != baked_colors:
	#	print("[")
	#	for c in colors: 
	#		print("\t\tColor", c, ",")
	#	print("\t]")
	add_to_group("fruits")  # 加到 "fruits" 群組
	contact_monitor = true
	set_max_contacts_reported(50)
	
	#背景音樂播放
	#set_as_top_level(true)
	#set_process(true)  # 確保 _process() 會被調用
	#
	#
	#if not get_node("/root").has_node("AudioStreamPlayer"):
		#var bgm = AudioStreamPlayer.new()
		#bgm.stream = load("res://Brave_Grassroots.ogg")
		#bgm.autoplay = true
		#bgm.loop = true  # 設置循環
		#get_node("/root").add_child(bgm)
	
	

	
	
	update_fruit_appearance()
	mass = get_target_mass(level)
	var target_scale := Vector2(1, 1) * get_target_scale(level)
	var prev_scale = current_scale
	current_scale = target_scale
	_scale_2d(target_scale)

# Update fruit appearance based on level
func update_fruit_appearance():
	if sprite:
		# Apply correct texture based on level (clamped to valid index)
		var texture_index = clamp(level - 1, 0, fruit_textures.size() - 1)
		sprite.texture = fruit_textures[texture_index]
		
		# 根據碰撞形狀大小和紋理大小動態計算scale
		if sprite and sprite.texture:
			var texture_size = sprite.texture.get_size()
			
			
			# 將基礎碰撞半徑設為10.0，與MeshInstance2D的scale一致
			var base_collision_radius = 10.0
			
			# 計算當前等級的目標比例
			var level_scale_factor = get_target_scale(level) / get_target_scale(1)
			
			# 使用填充因子讓水果看起來更大、更緊密
			var fill_factor = 1.4
			
			# 計算需要的sprite比例
			var target_diameter = 2 * base_collision_radius * level_scale_factor * fill_factor
			var scale_factor = target_diameter / max(texture_size.x, texture_size.y)
			
			# 設置sprite的scale
			sprite.scale = Vector2(scale_factor, scale_factor)
			

	
	if mesh:
		# Keep old coloring system as fallback
		mesh.modulate = get_color(level)
		mesh.visible = sprite == null

func get_absorbed(other):
	collider.queue_free()
	absorber = other
	
	if sprite:
		sprite.owner = $".."
		sprite.global_position = global_position
	else:
		mesh.owner = $".."
		mesh.global_position = global_position
		
	var audio: Audio = $"../audio"
	var sample := audio.combine7
	var pitch := 1.0
	var volume := 0.0
	match level:
		1, 2, 3, 4:
			sample = audio.combine7
			pitch += (3 - level) * 0.1 - 0.2
			volume += randf() * -1
		5, 6:
			sample = audio.combine4
			pitch += (17 - level) * 0.05
			volume += 5 - (12 - level)
		7, 8:
			sample = audio.combine2
			pitch += (17 - level) * 0.08 + 0.5
			volume += 5 - (20 - level * 2)
		9, 10:
			sample = audio.combine6
			pitch += (20 - level) * 0.1 + 0.0
			volume += 1 - (20 - level)
		11:
			sample = audio.pop_v3
			pitch = 1.0 + (5 - level) * 0.1
			volume = (level - 8) * 1.0
	#print(level)
	audio.play_audio(sample, pitch + randf() * 0.1 + 0.7, volume)

func _process(delta: float):
	var t := 1.0 - pow(0.0001, delta)
	if mesh:
		mesh.modulate = lerp(mesh.modulate, get_color(level), t)

	if absorber:
		if is_instance_valid(absorber) and absorber.cooldown > 0:
			var dist: Vector2 = absorber.global_position - (sprite.global_position if sprite else mesh.global_position)
			var speed := 1000.0 * delta
			if dist.length() <= speed:
				pass
			else:
				if sprite:
					sprite.global_position += dist.normalized() * speed
				else:
					mesh.global_position += dist.normalized() * speed
				return
		if sprite:
			sprite.queue_free()
		else:
			mesh.queue_free()
		queue_free()

func do_combining(delta: float):
	if game_over:
		return
	

	if cooldown > delta:
		cooldown -= delta
		return
	else:
		cooldown = 0
	
	var colliding_bodies = get_colliding_bodies()
	if not colliding_bodies:  # 避免 null 錯誤
		return
		
	for node in colliding_bodies:
		if not node or not node.has_method("get_absorbed"):
			continue

	for node in get_colliding_bodies():
		if not node.has_method("get_absorbed") or node.level != level or node.is_queued_for_deletion():
			continue
		if node.absorber:
			continue
		if node.cooldown > 0:
			continue
		if node.get_instance_id() < get_instance_id():
			continue
		apply_central_impulse(- (node.global_position - global_position) * mass * 2)
		cooldown = 0.1
		level += 1
		var score: Score = $"/root/ui/score"
		score.add(level)
		if level >= 12:
			level = 11
			cooldown = 1000
			pop()
			node.pop()
		else:
			update_fruit_appearance()
			node.get_absorbed(self)
		return

func _physics_process(delta: float):
	if is_queued_for_deletion():
		return
		
	if popped:
		if free_after_pop <= delta:
			queue_free()
			return
		else:
			free_after_pop -= delta
		
	do_combining(delta)

	var t := 1.0 - pow(0.0001, delta)
	mass = lerp(mass, get_target_mass(level), t)
	var target_scale := Vector2(1, 1) * (get_target_scale(level) if not popped else 0.0)
	var prev_scale = current_scale
	current_scale = lerp(current_scale, target_scale, t)
	_scale_2d(current_scale / prev_scale)

func _scale_2d(target_scale: Vector2):
	if target_scale.x == 1:
		return
		
	if target_scale.x == 0 or target_scale.y == 0:
		return  # 避免除以零
		
	# 標記sprite已被處理，避免update_fruit_appearance重複處理
	var sprite_already_updated = false
	
	for child in get_children():
		if child is Node2D:
			if child == sprite:
				# 對於sprite，我們在update_fruit_appearance函數中處理縮放
				# 這裡只需要更新位置
				child.transform.origin *= target_scale
				sprite_already_updated = true
			else:
				# 其他節點按正常方式縮放
				child.scale *= target_scale
				child.transform.origin *= target_scale
	
	# 僅當sprite未被處理時才更新外觀
	if not sprite_already_updated:
		update_fruit_appearance()




func pop():
	popped = true
	var audio: Audio = $"../audio"
	var sample := audio.pop_v3
	var pitch := 1.0
	var volume := 0.0
	pitch = 1.0 + (5 - level) * 0.1
	volume = (level - 8) * 1.0
	audio.play_audio(sample, pitch - randf() * 0.01, volume - randf() * 2 - 5)
	
