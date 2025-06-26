extends Node

@onready var prompt = %PromptCanvas
@onready var prompt_include = %PromptInclude

func _ready() -> void:
	prompt.scale = Vector2.ZERO

func show_prompt(include:String):
	prompt_include.text = include
	var tween = create_tween()
	tween.tween_property(prompt,"scale",Vector2(1.2,1.2),0.1)
	tween.tween_property(prompt,"scale",Vector2(1,1),0.1)
	tween.tween_interval(1.0)
	tween.tween_property(prompt,"modulate:a",0.0,1.0)
	tween.tween_callback(queue_free)
