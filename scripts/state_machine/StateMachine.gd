class_name StateMachine
extends Node

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready():
	# Wait for all children to be ready
	await get_tree().process_frame
	
	# Initialize all states
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_transition.connect(_on_state_transition)
	
	if initial_state:
		current_state = initial_state
		current_state.enter()

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func _input(event):
	if current_state:
		current_state.handle_input(event)

func _on_state_transition(new_state_name: String):
	var new_state = states.get(new_state_name.to_lower())
	if new_state and new_state != current_state:
		if current_state:
			current_state.exit()
		current_state = new_state
		current_state.enter()

func force_change_state(new_state_name: String):
	_on_state_transition(new_state_name)
