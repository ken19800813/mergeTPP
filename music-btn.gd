extends Button

@onready var audio_player = $"../AudioStreamPlayer"  # 取得音樂播放器

func _ready():
	text = "PLAY"  # 設定按鈕文字
	connect("pressed", Callable(self, "_on_button_pressed"))  # 連接按鈕事件
	audio_player.connect("finished", Callable(self, "_on_music_finished"))  # 設定循環播放

func _on_button_pressed():
	if audio_player.playing:
		audio_player.stop()  # 停止播放
		text = "PLAY"
	else:
		audio_player.play()  # 播放音樂
		text = "STOP"

func _on_music_finished():
	audio_player.play()  # 當音樂結束時，重新播放
