extends CharacterBody2D

@onready var mosquitto_animation = %AnimatedSprite2D
@onready var collision = %CollisionShape2D

const damage = -20.0
const treatment = +5.0
const death_distance = 300.0

var move_velocity:float
var move_direction:Vector2
var is_inscreen:bool
var death_position:Vector2
var death_animation = ["injure","cry","sad"]

enum status { wait,live,hide,death,reset }
var state

func _ready() -> void:
	move_velocity = 0
	move_direction = Vector2.ZERO
	state = status.wait
	mosquitto_animation.play("fly")
	is_inscreen = false

func custom_ready() -> void:
	collision.set_deferred("disabled",false)
	modulate.a = 1.0
	state = status.live
	mosquitto_animation.flip_h = move_direction.x < 0
	var angle = move_direction.angle()
	if move_direction.x < 0:
		angle += PI
	rotation = angle

func _process(delta: float) -> void:
	if state == status.live:
		position += move_direction.normalized() * move_velocity * delta
	if state == status.death or state == status.reset:
		position = position.lerp(death_position,delta * 3)
		if (death_position - position).length() < 10 and state == status.death:
			state = status.reset
			custom_free()
	
func death(player_position:Vector2) -> void:
	rotation = 0
	mosquitto_animation.flip_h = false
	death_position = position + (position - player_position).normalized() * death_distance
	mosquitto_animation.play(death_animation.pick_random())
	collision.set_deferred("disabled",true)
	state = status.death
	
func lost(player:Node) -> void:
	state = status.hide
	hide()
	print(GlobalManage.get_time(),"[敌人]等待丢弃动作")
	collision.set_deferred("disabled",true)
	
	await player.space_lost
	print(GlobalManage.get_time(),"[敌人]播放丢弃动作")
	var lost_point:Node
	if player.get_node("PlayerAnimation").flip_h:
		lost_point = player.get_node("LostRight")
	else:
		lost_point = player.get_node("LostLeft")
	var old_position = lost_point.global_position + Vector2(randf_range(-10,10),randf_range(-10,10))
	
	await get_tree().create_timer(0.05).timeout
	position = lost_point.global_position
	AudioManage.play_sound("ui-pop")
	show()
	death(old_position)

func custom_free() -> void:
	var tween = create_tween()
	tween.tween_property(self,"modulate:a",0,1.0)
	await tween.finished
	_ready()

#离开屏幕信号
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if state == status.live:
		_ready()
