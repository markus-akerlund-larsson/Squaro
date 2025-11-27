class_name Enemy
extends Resource

#Careful, only add new Tags and Statuses at the end or resources break
enum Tag {HARMLESS, BUMP, FLYING, HIT_AND_RUN, COOLDOWN}
enum Status {RETREATING, FROZEN, RESTING, BUMPED}

@export var id: int
@export var name: String
@export var position: Vector2i
@export var tag: Dictionary[Tag, int]
@export var status: Dictionary[Status, int]

func _init(p_id: int = 0, p_name: String = "", p_position: Vector2i = Vector2i.ZERO, p_tag: Dictionary[Tag, int] = {}, p_status: Dictionary[Status, int] = {}):
	id = p_id
	name = p_name
	position = p_position
	tag = p_tag
	status = p_status
