extends Node

var _sound_players := []

var _sounds := {
	"ui-click":preload("res://assets/audio_sound/ui-click.ogg"),
	"ui-page":preload("res://assets/audio_sound/ui-page.ogg"),
	"ui-pop":preload("res://assets/audio_sound/ui-pop.ogg"),
	"ui-warning":preload("res://assets/audio_sound/ui-warning.ogg"),
	"capoo-action":preload("res://assets/audio_sound/capoo-action.ogg"),
	"capoo-swing":preload("res://assets/audio_sound/capoo-attack.ogg"),
	"capoo-cry":preload("res://assets/audio_sound/capoo-cry.ogg"),
	"capoo-weep":preload("res://assets/audio_sound/capoo-weep.ogg")
}

func _ready():
	print(GlobalManage.get_time(),"[全局声音]已载入")
	for i in range(6):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sound_players.append(player)

#播放音效
func play_sound(id:String):
	if _sounds.has(id):
		print(GlobalManage.get_time(),"[全局声音]播放音效：",id)
	else:
		push_error(GlobalManage.get_time(),"[全局声音]未知的音效名称：",id)
		return

	for player in _sound_players:
		if not player.playing:
			player.stream = _sounds[id]
			player.volume_linear = GlobalData.game_data["setting"]["sound_volume"]
			player.play()
			return
	
	var new_player = AudioStreamPlayer.new()
	new_player.bus = "SFX"
	add_child(new_player)
	_sound_players.append(new_player)
	new_player.stream = _sounds[id]
	new_player.volume_linear = GlobalData.game_data["setting"]["sound_volume"]
	new_player.play()
