extends Node
signal progress_finished
signal prompt_change
signal progress_updata(value:int)

@onready var enemy  = %Mosquito_A
@onready var enemy_animation = %MosquitoAAnimation
@onready var path = %PathFollow2D
@onready var player = %Player_A
@onready var prompt_back = %PromptBackGround
@onready var prompt_label = %PromptLabel

var is_path_move:bool
var speed:float = 600
enum status { wait,robit,attention,attack }
var state := status.wait
var old_position:Vector2
var direction:Vector2
var level_progress:int

var prompt_point = [
	[3180,3500,4000],#A
	[5300,5700,6200],#S
	[9200,9700,10400],#A
	[11500,11900,12600],#D
	[14000,15550,16000],#W
]
var prompt_text = ["A","S","D","D","W"]
var prompt_handled:bool
var prompt_handle_point:float

func _ready() -> void:
	enemy.hide()
	path.progress = 0
	is_path_move = false
	prompt_handled = true
	prompt_back.hide()
	prompt_label.add_theme_color_override("font_color", Color("#48b4ff"))
	updata_prompt()

func start(wait_position:Vector2) -> void:
	enemy.show()
	enemy.global_position = wait_position
	state = status.robit
	
func _process(delta: float) -> void:
	if player.health == 0:
		return

	if path.progress_ratio * 100 >= level_progress + 5:
		level_progress = int(path.progress_ratio * 100)
		progress_updata.emit(level_progress)
	
	if not prompt_handled and path.progress > prompt_handle_point:
		prompt_handled = true
		prompt_change.emit()
	
	match state:
		status.robit:
			path.progress += speed * delta
			if path.progress > 3180:
				state = status.attention
				attention()
		status.attack:
			path.progress += speed * delta
			if path.progress_ratio == 1.0:
				state = status.wait
				await get_tree().create_timer(2.0).timeout
				progress_finished.emit()
	if enemy.global_position != old_position:
		enemy_animation.flip_h = (enemy.global_position - old_position).x < 0
	
	direction = enemy.global_position - old_position
	old_position = enemy.global_position

func attention() -> void:
	enemy_animation.play("attention")
	player.request_animation("look")
	await enemy_animation.animation_finished
	state = status.attack
	enemy_animation.play("fly")

func updata_prompt() ->void:
	for i in range(prompt_point.size()):
		set_prompt_handle_point(i,0)
		
		await prompt_change
		prompt_back.show()
		prompt_label.text = prompt_text[i]
		set_prompt_handle_point(i,1)
		
		await prompt_change
		prompt_label.add_theme_color_override("font_color", Color("ffffff"))
		set_prompt_handle_point(i,2)
			
		await prompt_change
		prompt_back.hide()
		prompt_label.add_theme_color_override("font_color", Color("#48b4ff"))

func set_prompt_handle_point(i:int,n:int) -> void:
	prompt_handle_point = prompt_point[i][n]
	prompt_handled = false
