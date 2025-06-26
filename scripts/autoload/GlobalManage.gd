extends Node

var prompt_scene = preload("res://scenes/global-scene/PromptScene.tscn")
var transition_scene = preload("res://scenes/global-scene/TransitionScene.tscn")

func _ready() -> void:
	print(get_time(),"[全局管理]已载入")

#获取时间
func get_time() -> String:
	var time = Time.get_time_dict_from_system()
	var time_string = "[%02d:%02d:%02d]" %[time["hour"],time["minute"],time["second"]]
	return time_string

#弹出提示
func show_prompt(include:String) -> void:
	print(get_time(),"[全局管理]弹出提示：",include)
	var prompt = prompt_scene.instantiate()
	add_child(prompt)
	prompt.show_prompt(include)
	AudioManage.play_sound("ui-pop")

#加载动画
func play_transition() -> void:
	add_child(transition_scene.instantiate())
