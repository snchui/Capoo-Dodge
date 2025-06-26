extends Node

@onready var capoo = %Capoo
@onready var mosquitto = %Mosquitto
@onready var anim = %MosAnim
@onready var point1 = %Point1
@onready var point2 = %Point2

enum h_direction {L,R}
var h_state = h_direction.R
var h_speed = 100

enum v_direction {U,D}
var v_state = v_direction.U
var v_speed = 50
var base_hight:float

func _ready() -> void:
	base_hight = mosquitto.position.y

func _process(delta: float) -> void:
	#向左移动的条件
	if mosquitto.position.x > point2.position.x:
		h_state = h_direction.L
		anim.flip_h = true
	
	#向右移动的条件
	if mosquitto.position.x < point1.position.x:
		h_state = h_direction.R
		anim.flip_h = false
	
	#向左或右移动
	if h_state == h_direction.R:
		mosquitto.position.x += h_speed * delta
	else:
		mosquitto.position.x -= h_speed * delta
	
	#向下移动的条件
	if mosquitto.position.y < base_hight - 20:
		v_state = v_direction.U
	
	#向上移动的条件
	if mosquitto.position.y > base_hight + 20:
		v_state = v_direction.D
	
	#向上或下移动
	if v_state == v_direction.U:
		mosquitto.position.y += v_speed * delta
	else:
		mosquitto.position.y -= v_speed * delta
