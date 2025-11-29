class_name RemoveFireAction
extends Action

var _id: int

func _init(id: int) -> void:
	_id = id

func execute(game: Node2D):
	# Remove the fire view node and its entry in entities
	if game.entities.has(_id):
		var fire_node: Node2D = game.entities[_id]
		if fire_node.get_parent() != null:
			fire_node.get_parent().remove_child(fire_node)
		fire_node.queue_free()
		game.entities.erase(_id)
