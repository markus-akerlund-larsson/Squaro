class_name Fire
extends Resource

@export var id: int
@export var position: Vector2i

func _init(p_id: int = 0, p_position: Vector2i = Vector2i.ZERO):
	id = p_id
	position = p_position
