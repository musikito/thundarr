class_name Player
extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_force: float = 600.0
@export var gravity: float = 1200.0

# Use @onready with explicit type casting
@onready var state_machine: StateMachine = $StateMachine as StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $Sprite2D

var is_facing_right: bool = true

func _ready():
	if state_machine == null:
		push_error("StateMachine node is missing or doesn't have StateMachine script!")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()
	update_facing_direction()

func update_facing_direction():
	if velocity.x > 0:
		is_facing_right = true
	elif velocity.x < 0:
		is_facing_right = false
	
	sprite.flip_h = not is_facing_right

func get_input_direction() -> float:
	return Input.get_axis("left", "right")

#extends CharacterBody2D
#
#
#const SPEED = 400.0
#const JUMP_VELOCITY = -900.0
#@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
#
#func _physics_process(delta: float) -> void:
	## Animations
	#if (velocity.x > 1 || velocity.x < -1):
		#sprite_2d.animation = "running"
	#else:
		#sprite_2d.animation = "idle"
	#
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
		#sprite_2d.animation = "jumping"
#
	## Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("left", "right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, 12)
#
	#move_and_slide()
	#
	#var isLeft = velocity.x < 0
	#sprite_2d.flip_h = isLeft
