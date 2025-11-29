extends Node2D

@onready var map = $TileMapLayer
@onready var player = $TileMapLayer/Player
@onready var enemies_node = $TileMapLayer/Enemies
@onready var player_preview = $TileMapLayer/PlayerGhost
@onready var health_display = $TileMapLayer/Player/Camera2D/CanvasLayer/Label

var _history: Array[Update] = []
var _enemy_scene: Resource
var _enemies: Dictionary[StringName, EnemySpec]
var _unused_id: int = 2

enum {AWAITING_INPUT, RESOLVING_ACTIONS}

var input_state = AWAITING_INPUT;
var entities: Dictionary[int, Node2D]

func _init() -> void:
	OS.add_logger(CustomLogger.new())

func _ready() -> void:
	var state = GameState.new()
	_enemy_scene = load("res://enemy.tscn")
	
	# Obviously the rest of this function should happen in a level generator
	# in the future
	
	#Setup map
	var mapData: Array[StringName] = []
	mapData.resize(65*69)
	mapData.fill(&"Water")
	state.map = Map.new(65, 69, mapData)
	for x in range(30, 35):
		for y in range(30, 39):
			state.map.set_tile_xy(x, y, &"Ground")
	state.map.set_tile_xy(32, 35, &"Water")
	map.update(state)
	
	# Setup player
	state.player.position = Vector2i(32, 38)
	entities[GameRules.player_id] = player
	player.position = map.map_to_local(state.player.position)
	
	#Setup fire
	var fire_node = get_node("TileMapLayer/Fire")
	var fire_state = Fire.new()
	fire_state.id = _unused_id
	_unused_id += 1
	fire_state.position = Vector2i(33, 36)
	entities[fire_state.id] = fire_node
	fire_node.position = map.map_to_local(fire_state.position)
	state.fires.append(fire_state)

	# Setup enemies
	_enemies = {
		&"Rat": load("res://enemies/rat.tres"),
		&"KissyRat": load("res://enemies/kissy_rat.tres"),
		&"Bat": load("res://enemies/bat.tres"),
	}
	state = _spawn_enemy(state, _enemies[&"Rat"], Vector2i(31, 33)).state
	state = _spawn_enemy(state, _enemies[&"KissyRat"], Vector2i(34, 36)).state
	state = _spawn_enemy(state, _enemies[&"Bat"], Vector2i(32, 33)).state
	_history.append(Update.new([], state))

func _process(_delta: float) -> void:
	player_preview.visible = false
	# Will this get complex enough later to justify state machine objects?
	match input_state:
		AWAITING_INPUT:
			_receive_input()

func _receive_input() -> void:
	var tile = map.local_to_map(get_global_mouse_position())
	
	if(not Player.validMove(tile, _history[-1].state)):
		return
		
	if Input.is_action_pressed(&"game_move"):
		player_preview.position = map.map_to_local(tile)
		player_preview.visible = true
		
	if Input.is_action_just_released(&"game_move"):
		if _history[-1].state.enemy_tile(tile):
			var res = GameRules.player_bump(_history[-1].state, tile)
			if res != null:
				_history.append(res)
				input_state = RESOLVING_ACTIONS
				for action in _history[-1].actions:
					await action.execute(self)
				input_state = AWAITING_INPUT
		else:
			_history.append(GameRules.player_move(_history[-1].state, tile))
			input_state = RESOLVING_ACTIONS
			for action in _history[-1].actions:
				await action.execute(self)
			input_state = AWAITING_INPUT
			


func _spawn_enemy(p_state: GameState, type: EnemySpec, pos: Vector2i) -> Update:
	var state = p_state.duplicate(true)
	var scene = _enemy_scene.instantiate()
	enemies_node.add_child(scene)
	
	var enemyState = Enemy.new()
	enemyState.position = pos
	enemyState.id = _unused_id
	_unused_id += 1

	enemyState.name = type.name
	enemyState.tag = type.tags.duplicate()
	
	state.enemies.append(enemyState)
	
	scene.position = map.map_to_local(enemyState.position)
	entities[enemyState.id] = scene
	
	scene.polygon.color = type.color
	print("Spawned "+str(type)+" at "+str(pos))
	
	return Update.new([], state)
	
class CustomLogger extends Logger:
	func _log_message(_message: String, _error: bool) -> void:
		pass

	func _log_error(
			_function: String,
			_file: String,
			_line: int,
			_code: String,
			_rationale: String,
			_editor_notify: bool,
			_error_type: int,
			_script_backtraces: Array[ScriptBacktrace]
	) -> void:
		pass
