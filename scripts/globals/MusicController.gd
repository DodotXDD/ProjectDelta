extends Control

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var music_1: AudioStream
@export var music_2: AudioStream

var last_stream: AudioStream
var music_volume_local: float = 1.0

func _ready():
	audio_player.stream = music_1
	audio_player.volume_db = music_volume_local

func play_stream(stream: AudioStream):
	
	if last_stream == stream:
		return 
	
	last_stream = stream;
	audio_player.stop();
	audio_player.stream = stream;
	audio_player.play();

func stop():
	audio_player.stop();

func set_volume(volume: float):
	audio_player.volume_db = volume;
