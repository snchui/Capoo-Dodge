extends Node

@onready var game = %Game
@onready var UI = %UI
@onready var progress_timer = %ProgressTimer
@onready var space_progress = %SpaceProgress
@onready var back_ground = %BackGround
@onready var back_color = %BackColor

var mainscene = load("res://scenes/main-scene/MainScene.tscn")

func _ready():
	back_color.hide()
	back_ground.show()
	print(GlobalManage.get_time(),"[场景]游戏场景已载入")
	if GlobalData.game_data["progress"]["level"] != "Capoo Dodge":
		GlobalData.game_data["progress"] = {
			"level":"Capoo Dodge",
			"level_progress":"A",
		}
		GlobalData.save_data()
	var game_progress = GlobalData.game_data["progress"]["level_progress"]
	print(GlobalManage.get_time(),"[场景]已载入游戏，进度：",game_progress)
	load_game(game_progress)

func load_game(level_progress:String) -> void:
	while(true):
		print(GlobalManage.get_time(),"[游戏]进入关卡流程：{progress}".format({"progress":level_progress}))
		match level_progress:
			"A":
				back_color.show()
				back_ground.hide()
				await UI.play_video("video1")
				space_progress.hide()
				UI.music_play("bgm-1")
				await game.level_progress_A()
				UI.music_stop()
				level_progress = "B"
			"B":
				back_ground.show()
				back_color.hide()
				space_progress.show()
				await UI.play_video("video2")
				UI.music_play("bgm-1")
				await game.level_progress_B()
				UI.music_stop()
				level_progress = "C"
			"C":
				await UI.play_video("video3")
				UI.music_play("bgm-1")
				await game.level_progress_C()
				UI.music_stop()
				level_progress = "D"
			"D":
				await UI.play_video("video4")
				UI.music_play("bgm-0")
				if await game.level_progress_D():
					UI.music_stop()
					await UI.play_video("video5")
				else:
					UI.music_stop()
					await UI.play_video("video6")
				UI.show_game_pass_window()
				GlobalData.game_data["progress"]["level"] = null
				GlobalData.save_data()
				break
			_:
				push_error(GlobalManage.get_time(),"[游戏]未知的游戏进度：",level_progress)
				break

		GlobalData.game_data["progress"]["level_progress"] = level_progress
		GlobalData.save_data()
