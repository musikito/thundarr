# Thundarr


This tutorial will guide you through creating a basic Metroidvania-style platformer in Godot 4.5 using GDScript. The focus will be on:
- State machines for the main character, companions, and enemies.
- Switchable companions, each with their own inventory.
- Inventories for weapons, spells, and skills for both main character and companions.

---

## Table of Contents

1. [Project Setup](#project-setup)
2. [Basic Scene Structure](#basic-scene-structure)
3. [State Machine Implementation](#state-machine-implementation)
	- [Main Character](#main-character-state-machine)
	- [Companions](#companion-state-machine)
	- [Enemies](#enemy-state-machine)
4. [Companion Switching System](#companion-switching-system)
5. [Inventory System](#inventory-system)
	- [Weapons, Spells, Skills](#inventory-setup)
6. [Putting It All Together](#putting-it-all-together)
7. [Extending the Game](#extending-the-game)

---

## 1. Project Setup

1. **Open Godot 4.5**
2. **Create a new project:** `Metroidvania2D`
3. **Setup folder structure:**
	- `scenes/`
	- `scripts/`
	- `assets/`
	- `scenes/characters/`
	- `scenes/enemies/`
	- `scenes/companions/`
	- `scenes/ui/`

---

## 2. Basic Scene Structure

Create your main scene (`Main.tscn`) as a `Node2D` with subnodes:
- `Player` (instance of MainCharacter)
- `CompanionManager` (handles switching/management)
- `EnemyManager` (spawns enemies)
- `UI` (inventory, HUD, etc.)

Example:
```
Main (Node2D)
├── Player (CharacterBody2D)
├── CompanionManager (Node2D)
├── EnemyManager (Node2D)
├── UI (CanvasLayer)
```

---

## 3. State Machine Implementation

### Main Character State Machine

Create a folder `scripts/states/`. Each state is a script, e.g. `IdleState.gd`, `RunState.gd`, `JumpState.gd`, etc.

**Base State Script:**
```gdscript name=scripts/states/BaseState.gd
extends Node

func enter(owner): pass
func exit(owner): pass
func handle_input(owner, event): pass
func update(owner, delta): pass
```

**Main Character Script:**
```gdscript name=scripts/MainCharacter.gd
extends CharacterBody2D

var state = null
var states = {}

func _ready():
	states["idle"] = preload("res://scripts/states/IdleState.gd").new()
	states["run"] = preload("res://scripts/states/RunState.gd").new()
	states["jump"] = preload("res://scripts/states/JumpState.gd").new()
	state = states["idle"]
	state.enter(self)

func _physics_process(delta):
	state.update(self, delta)

func _input(event):
	state.handle_input(self, event)

func change_state(new_state_name):
	state.exit(self)
	state = states[new_state_name]
	state.enter(self)
```

**Example Idle State:**
```gdscript name=scripts/states/IdleState.gd
extends "res://scripts/states/BaseState.gd"

func enter(owner):
	owner.velocity = Vector2.ZERO

func handle_input(owner, event):
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		owner.change_state("run")
	elif Input.is_action_just_pressed("jump"):
		owner.change_state("jump")
```

### Companion State Machine

Companions can reuse the state system. Each companion is a `CharacterBody2D` with its own state machine.

```gdscript name=scripts/Companion.gd
extends CharacterBody2D

var state = null
var states = {}

func _ready():
	states["follow"] = preload("res://scripts/states/CompanionFollowState.gd").new()
	states["assist"] = preload("res://scripts/states/CompanionAssistState.gd").new()
	state = states["follow"]
	state.enter(self)

func _physics_process(delta):
	state.update(self, delta)

func change_state(new_state_name):
	state.exit(self)
	state = states[new_state_name]
	state.enter(self)
```

### Enemy State Machine

Similarly, create enemy states such as `Patrol`, `Chase`, `Attack`.

```gdscript name=scripts/Enemy.gd
extends CharacterBody2D

var state = null
var states = {}

func _ready():
	states["patrol"] = preload("res://scripts/states/EnemyPatrolState.gd").new()
	states["chase"] = preload("res://scripts/states/EnemyChaseState.gd").new()
	state = states["patrol"]
	state.enter(self)

func _physics_process(delta):
	state.update(self, delta)

func change_state(new_state_name):
	state.exit(self)
	state = states[new_state_name]
	state.enter(self)
```

---

## 4. Companion Switching System

Create a manager to handle switching companions.

```gdscript name=scripts/CompanionManager.gd
extends Node2D

var companions = []
var active_companion_index = 0

func _ready():
	# Add companion nodes to scene
	for companion in companions:
		add_child(companion)
		companion.hide()
	companions[active_companion_index].show()

func switch_companion(index):
	companions[active_companion_index].hide()
	active_companion_index = index
	companions[active_companion_index].show()
```

**Bind UI or input for switching companions:**
```gdscript
func _input(event):
	if event.is_action_pressed("switch_companion"):
		var next_index = (active_companion_index + 1) % companions.size()
		switch_companion(next_index)
```

---

## 5. Inventory System

### Inventory Setup

Create reusable inventory scripts and data structures.

**Inventory.gd**
```gdscript name=scripts/Inventory.gd
extends Node

var weapons = []
var spells = []
var skills = []

func add_weapon(weapon): weapons.append(weapon)
func add_spell(spell): spells.append(spell)
func add_skill(skill): skills.append(skill)

func remove_weapon(weapon): weapons.erase(weapon)
func remove_spell(spell): spells.erase(spell)
func remove_skill(skill): skills.erase(skill)
```

**Weapon/Spell/Skill:**
- Can be a `Resource` or simple `Dictionary` with relevant properties (name, damage, etc.)

**Attach inventory:**
Each character (main, companion) has an inventory instance.

```gdscript
var inventory = preload("res://scripts/Inventory.gd").new()
```

### Simple UI Example

Create a basic UI scene to show the active character's inventory.

```gdscript name=scripts/ui/InventoryUI.gd
extends Control

func update_inventory(character):
	# Display character.inventory.weapons, spells, skills
	pass
```

---

## 6. Putting It All Together

- Main character and companions use state machines for movement and actions.
- Switching companions swaps visible/active companion and their inventory.
- Inventories can be managed via UI.
- Enemies use state machines for their AI.
- Extend with pickups, skills, spells, etc.

---

## 7. Extending the Game

- Add new states (attack, cast spell, climb, swim, etc.)
- Implement more advanced AI for enemies.
- Create more complex companion behaviors.
- Expand inventory with pickups, upgrades, crafting.
- Add save/load system for progress.

---

## Example Project Structure

```
Metroidvania2D/
├── scenes/
│   ├── Main.tscn
│   ├── characters/
│   │   ├── MainCharacter.tscn
│   │   ├── Companion1.tscn
│   │   └── Companion2.tscn
│   ├── enemies/
│   │   ├── Enemy.tscn
│   └── ui/
│       ├── InventoryUI.tscn
├── scripts/
│   ├── MainCharacter.gd
│   ├── Companion.gd
│   ├── CompanionManager.gd
│   ├── Enemy.gd
│   ├── Inventory.gd
│   └── states/
│       ├── BaseState.gd
│       ├── IdleState.gd
│       ├── RunState.gd
│       ├── JumpState.gd
│       ├── CompanionFollowState.gd
│       ├── CompanionAssistState.gd
│       ├── EnemyPatrolState.gd
│       └── EnemyChaseState.gd
```

---

## Resources

- [Godot Docs: State Machine patterns](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)
- [Godot Docs: GDScript basics](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
- [Metroidvania Game Design](https://www.gamedeveloper.com/design/metroidvania-game-design)

---

Feel free to ask for code samples for specific features: movement, inventory UI, spell casting, companion abilities, etc!
