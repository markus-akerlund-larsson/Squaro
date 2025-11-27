class_name Map
extends Resource

@export var width: int
@export var height: int
@export var map: Array[StringName]

func _init(p_width: int = 1, p_height: int = 1, p_map: Array[StringName] = [&"Water"]):
	width = p_width
	height = p_height
	map = p_map
	assert(p_height*p_width == map.size())
	
func get_tile_xy(x: int, y: int) -> StringName:
	return map[y*width+x]
	
func get_tile(position: Vector2i) -> StringName:
	return get_tile_xy(position.x, position.y)
	
func set_tile_xy(x: int, y: int, tile: StringName):
	map[y*width+x] = tile
	
func set_tile(position: Vector2i, tile: StringName):
	set_tile_xy(position.x, position.y, tile)

static func gridDistance(a: Vector2i, b: Vector2i) -> int:
	var res = a-b
	return(abs(res.x)+abs(res.y))
