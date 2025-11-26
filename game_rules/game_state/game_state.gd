class_name GameState
extends Resource

@export var map: MapState
@export var player: PlayerState
@export var enemies: Array[EnemyState]

func _init(p_map = MapState.new(), p_player = PlayerState.new(), p_enemies: Array[EnemyState] = []):
	map = p_map
	player = p_player
	enemies = p_enemies

func blocked_tile(tile: Vector2i) -> bool:
	var res = false
	if player.position == tile: res = true
	if enemy_tile(tile): res = true
	return res

func enemy_tile(tile: Vector2i) -> bool:
	for e in enemies:
		if e.position == tile: return true
	return false

func enemy_at(tile: Vector2i) -> EnemyState:
	for e in enemies:
		if e.position == tile: return e
	return null
