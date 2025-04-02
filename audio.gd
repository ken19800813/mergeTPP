extends AudioStreamPlayer
class_name Audio

const combine2 := preload("res://sfx/combine2.wav")
const combine4 := preload("res://sfx/combine4.wav")
const combine6 := preload("res://sfx/combine6.wav")
const combine7 := preload("res://sfx/combine7.wav")
const pop_v3 := preload("res://sfx/opening_a_soda_pop.wav")

var _streams := [] 

func _new_stream() -> AudioStreamPlayer:
	var new_stream := AudioStreamPlayer.new()
	_streams.append(new_stream)
	add_child(new_stream)
	return new_stream

func _ready():
	for i in range(10):
		_new_stream()

func play_audio(sample: AudioStream, pitch : float, volume : float):
	for a in _streams:
		if a.playing:
			continue
		a.stream = sample
		a.pitch_scale = pitch
		a.volume_db = volume
		a.play()
		#print_debug("playing sample: " + str(sample))
		return

	#print_debug("adding " + str(len(_streams)) + "th stream to play " + str(sample))
	var new_stream := _new_stream()
	new_stream.stream = sample
	new_stream.pitch_scale = pitch
	new_stream.volume_db = volume
	new_stream.play()


func _on_button_pressed() -> void:
	pass # Replace with function body.
