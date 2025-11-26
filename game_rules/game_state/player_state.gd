class_name PlayerState
extends Resource

@export var position: Vector2i
@export var health: int
@export var last_move_dir: Vector2i

func _init(p_position: Vector2i = Vector2i.ZERO, p_health = 5, p_last_move_dir: Vector2i = Vector2i.UP):
	position = p_position
	last_move_dir = p_last_move_dir
	health = p_health

static func validMove(tile: Vector2i, state: GameState) -> bool:
	var validDistance = MapState.gridDistance(tile, state.player.position) == 1
	var validTile = state.map.get_tile(tile) == &"Ground"
	var enemy = state.enemy_tile(tile)
	return validDistance && (validTile or enemy)
