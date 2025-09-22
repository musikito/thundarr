class_name State
extends Node

signal state_transition(new_state_name: String)

var character: CharacterBody2D

func _ready():
	character = get_tree().current_scene.find_child("*", true, false) as CharacterBody2D
	if not character:
		character = owner

func enter():
	pass

func exit():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	pass

func handle_input(event: InputEvent):
	pass
