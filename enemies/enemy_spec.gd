class_name EnemySpec
extends Resource

@export var name: StringName
@export var tags: Dictionary[Enemy.Tag, int]
@export var color: Color

func _init(p_name = "", p_tags: Dictionary[Enemy.Tag, int] = {}, p_color = Color.WEB_GRAY):
	name = p_name
	tags = p_tags
	color = p_color
