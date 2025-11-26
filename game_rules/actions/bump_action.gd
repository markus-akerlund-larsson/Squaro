class_name MoveAction
extends Action

var _id: int
var _to: Vector2i

func _init(id: int, to: Vector2i) -> void:
	_id = id
	_to = to
	
func execute(game: Node2D):
	var tween = game.get_tree().create_tween()
	tween.tween_property(game.entities[_id], "position", game.map.map_to_local(_to), 0.1)
	await tween.finished
	
