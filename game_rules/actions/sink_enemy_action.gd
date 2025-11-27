class_name SinkEnemyAction
extends Action

var _id: int
var _tile: Vector2i

func _init(id: int, tile: Vector2i) -> void:
	_id = id
	_tile = tile
	
func execute(game: Node2D):
	game.map.update(game._history[-1].state)
	var enemy = game.entities[_id]
	game.enemies_node.remove_child(enemy)
	enemy.queue_free()
	game.entities.erase(_id)
	
