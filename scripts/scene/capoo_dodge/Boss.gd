extends CharacterBody2D
signal action_finished
signal death
signal updata_progress(value:int)

@onready var boss_animation = %BossAnimation
@onready var boss_health_progress = %BossHealthProgress
@onready var left_create_point = %BossLeftAttackPoint
@onready var right_create_point = %BossRightAttackPoint
@onready var left_collision_1 = %BossLeftShape1
@onready var left_collision_2 = %BossLeftShape2
@onready var right_collision_1 = %BossRightShape1
@onready var right_collision_2 = %BossRightShape2

const damage = -30.0
const treatment = +0
const max_health = 1000

var health:int = max_health
var base_animation:String = "fly"
var target_position:Vector2 = position
var target_distance:float = 0.01
var initial_distance:float = 0.01
var level_progress:int

#开始行动
func start() -> void:
	health = max_health
	boss_health_progress.value = boss_health_progress.max_value
	base_animation = "fly"

#移动
func _physics_process(delta: float) -> void:
	target_distance = (position - target_position).length()
	if position != target_position and health != 0:
		var t =clamp(5 * (initial_distance - target_distance)/initial_distance,2,5)
		position = position.lerp(target_position,delta * t)
		if target_distance < 1:
			position = target_position
			action_finished.emit()

#请求移动
func move_to_position(aim_position:Vector2) -> void:
	print(GlobalManage.get_time(),"[Boss]移动：",position,"->",aim_position)
	initial_distance = (aim_position - position).length()
	if initial_distance < 1:
		await get_tree().create_timer(0.5).timeout
		action_finished.emit()
	else:
		target_position = aim_position

#移动到随机位置
func move_to_random(screen_size: Vector2) -> void:
	var min_x = max(0.0, position.x - screen_size.x / 2)
	var max_x = min(screen_size.x, position.x + screen_size.x / 2)
	var min_y = max(0.0, position.y - screen_size.y / 2)
	var max_y = min(screen_size.y, position.y + screen_size.y / 2)
	
	min_x = min(min_x, max_x)
	min_y = min(min_y, max_y)
	
	var random_position := Vector2(randf_range(min_x, max_x),randf_range(min_y, max_y))
	move_to_position(random_position)

#请求动画
func request_animation(anim:String) -> void:
	boss_animation.play(anim)
	if anim in ["damage","injure"]:
		await boss_animation.animation_finished
		boss_animation.play(base_animation)
	else:
		base_animation = anim

#更改朝向
func updata_direction(player_position:Vector2) -> void:
	boss_animation.flip_h = player_position.x - position.x > 0
	if boss_animation.flip_h:
		left_collision_1.disabled = true
		left_collision_2.disabled = true
		right_collision_1.disabled = false
		right_collision_2.disabled = false
	else:
		left_collision_1.disabled = false
		left_collision_2.disabled = false
		right_collision_1.disabled = true
		right_collision_2.disabled = true

#怪物生成点
func get_enemy_create_point() -> Vector2:
	if boss_animation.flip_h:
		return right_create_point.global_position
	else:
		return left_create_point.global_position

#受伤操作
func injure() -> void:
	var injure_value:int
	if boss_animation.animation in ["fly","damage"]:
		injure_value = 50
	else:
		injure_value = 20
	health = clamp(health - injure_value,0,max_health)
	print(GlobalManage.get_time(),"[Boss]血量变化：",boss_health_progress.value,"->",health)
	boss_health_progress.value = health
	updata_progress.emit( int((float(max_health - health)/max_health) * 100) )
	if health != 0:
		if base_animation == "fly":
			request_animation("damage")
		else:
			request_animation("injure")
	else:
		base_animation = "damage"
		request_animation("damage")
		death.emit()
		left_collision_1.call_deferred("set_disabled",true)
		left_collision_2.call_deferred("set_disabled",true)
		right_collision_1.call_deferred("set_disabled",true)
		right_collision_2.call_deferred("set_disabled",true)
		var tween = create_tween()
		tween.tween_property(self,"modulate:a",0,2.0)
		
