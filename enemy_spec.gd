class_name EnemySpec
extends Resource

@export var name: StringName
@export var tags: Dictionary[EnemyState.Tag, int]
@export var tags_s: Dictionary[StringName, int]
@export var color: Color

func _init(p_name = "", p_tags: Dictionary[EnemyState.Tag, int] = {}, p_color = Color.WEB_GRAY):
	name = p_name
	tags = p_tags
	color = p_color
	tags_s = {}
