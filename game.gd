extends Node2D

@export var shake_threshold := 4.0  # 搖晃觸發的靈敏度
@export var shake_cooldown := 0.5  # 最小間隔時間，避免連續觸發
var last_shake_time := 0.0  # 記錄上次搖晃的時間

func _process(delta):
	var accel = Input.get_accelerometer()  # 取得手機的加速度數據
	var shake_strength = accel.length()  # 計算加速度的大小
	
	# 避免短時間內多次觸發
	if shake_strength > shake_threshold and Time.get_ticks_msec() / 1000.0 - last_shake_time > shake_cooldown:
		last_shake_time = Time.get_ticks_msec() / 1000.0
		shake_fruits()

func shake_fruits():
	print("Shaking Fruits!")  # 除錯用，可刪除
	for fruit in get_tree().get_nodes_in_group("fruits"):
		if fruit.has_method("apply_shake_force"):
			fruit.apply_shake_force()
