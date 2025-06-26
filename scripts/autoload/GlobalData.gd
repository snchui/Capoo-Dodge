extends Node

const data_file_path = "user://gamedata.dat"
var game_data:Dictionary = {}

#读取数据
func _ready() -> void:
	print(GlobalManage.get_time(),"[全局数据]已载入")
	var file = FileAccess.open(data_file_path,FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(content)
		
		if error == OK:
			game_data = json.get_data()
			print(GlobalManage.get_time(),"[全局数据]读取数据成功：",game_data)
		else:
			print(GlobalManage.get_time(),"[全局数据]JSON解析错误")
			GlobalManage.show_prompt("游戏数据JSON解析错误，已重置游戏数据")
			reset_data("all")
	else:
		print(GlobalManage.get_time(),"[全局数据]数据文件内容为空，已创建默认游戏数据")
		reset_data("all")

#保存数据
func save_data() -> void:
	var file = FileAccess.open(data_file_path,FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(game_data))
		file.close()
		print(GlobalManage.get_time(),"[全局数据]游戏数据保存成功:",game_data)
	else:
		push_error(GlobalManage.get_time(),"[全局数据]游戏数据保存失败")
		GlobalManage.show_prompt("数据保存失败，请检查设备剩余空间和游戏权限是否足够")

#重置数据
func reset_data(reset_type:String) -> void:
	print(GlobalManage.get_time(),"[全局数据]已重置数据：",reset_type)
	if reset_type in ["all","progress"]:
		game_data["progress"] = {
			"level":null,
			"level_progress":null,
		}
	if reset_type in ["all","setting"]:
		game_data["setting"] = {
			"attack_lock":false,
			"animation_jump":true,
			"music_volume":0.8,
			"sound_volume":0.8,
		}
	if reset_type in ["all","animation"]:
		game_data["play_state"] = {
			Capoo_Dodge = {
				"video1":false,
				"video2":false,
				"video3":false,
				"video4":false,
				"video5":false,
				"video6":false,
			}
		}
	
	save_data()
