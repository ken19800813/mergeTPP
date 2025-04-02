extends Node

@export var shake_threshold: float = 10.0  # 設定搖晃的靈敏度
@export var shake_force: float = 500.0  # 施加的搖晃力量
var last_accel := Vector3.ZERO

func _process(delta):
	var accel = Input.get_accelerometer()  # 讀取手機加速度
	var delta_accel = accel - last_accel  # 計算加速度變化量
	last_accel = accel
	
	# 若變化量超過閾值，觸發搖晃
	if delta_accel.length() > shake_threshold:
		shake_fruits()

func shake_fruits():
	print("手機搖晃偵測到，搖晃水果！")
	
	# 找到所有水果並施加隨機力
	for fruit in get_tree().get_nodes_in_group("fruits"):
		if fruit is RigidBody2D:
			var random_force = Vector2(randf_range(-shake_force, shake_force), randf_range(-shake_force, shake_force))
			fruit.apply_impulse(random_force)


func _on_Button_pressed():
	var shake_strength = 500  # 搖晃力度，可調整
	for fruit in get_tree().get_nodes_in_group("fruits"):  # 獲取所有水果
		if fruit is RigidBody2D:
			if fruit.sleeping:
				fruit.sleeping = false  # 讓靜止的水果可受力
			
			var random_force = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
			fruit.apply_impulse(random_force, Vector2.ZERO)  # 施加衝量

	var fruits = get_tree().get_nodes_in_group("fruits")  
	print("找到的水果節點:", fruits)  # 測試有沒有抓到

	for fruit in fruits:
		if fruit is RigidBody2D:
			print("準備施加衝量到:", fruit)


func _ready():
	#if false and colors != baked_colors:
	#	print("[")
	#	for c in colors: 
	#		print("\t\tColor", c, ",")
	#	print("\t]")
	add_to_group("fruits")  # 加到 "fruits" 群組
	
	set_process(true)  # 確保 _process() 會被調用
	
	
	if not get_node("/root").has_node("AudioStreamPlayer"):
		var bgm = AudioStreamPlayer.new()
		bgm.stream = load("res://Brave_Grassroots.ogg")
		bgm.autoplay = true
		#bgm.loop = true  # 設置循環
		#get_node("/root").add_child(bgm)
