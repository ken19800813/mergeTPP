extends Label
class_name Score

var combo_counter := 1
var score := 0
var is_game_over := true

@onready var fade := get_node_or_null("/root/transition/fade")

func _ready():
	text = ""
	score = 0

func level_start():
	$"../prev_score".text = text
	text = ""
	score = 0
	is_game_over = false

func end_combo():
	combo_counter = 1

func add(val: int):
	if is_game_over or val <= 0:
		return
	combo_counter += 1
	score += val * combo_counter
	write_score(score)

func write_score(val: int):
	text = str(val)

func game_over():
	if is_game_over:
		return
	is_game_over = true
	$"../prev_score".text = ""

func _process(_delta: float):
	if fade:
		modulate.a = pow(1 - fade.modulate.a, 4)
