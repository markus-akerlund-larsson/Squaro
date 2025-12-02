class_name GameState
extends Resource

@export var map: Map
@export var player: Player
@export var enemies: Array[Enemy]
@export var fires: Array[Fire]

func _init(p_map = Map.new(), p_player = Player.new(), p_enemies: Array[Enemy] = [], p_fires: Array[Fire] = []):
	map = p_map
	player = p_player
	enemies = p_enemies
	fires = p_fires

func blocked_tile(tile: Vector2i) -> bool:
	var res = false
	if player.position == tile:
		res = true
	if enemy_tile(tile):
		res = true
	return res

func enemy_tile(tile: Vector2i) -> bool:
	for e in enemies:
		if e.position == tile:
			return true
	return false

func enemy_at(tile: Vector2i) -> Enemy:
	for e in enemies:
		if e.position == tile:
			return e
	return null

func fire_at(tile: Vector2i) -> Fire:
	for f in fires:
		if f.position == tile:
			return f
	return null
