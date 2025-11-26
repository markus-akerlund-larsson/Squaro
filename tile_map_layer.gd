extends TileMapLayer

@export var width = 5
@export var height = 9
@export var waterBuffer = 30

func _ready() -> void:
	pass

func update(state: GameState) -> void:
	for x in range(0, state.map.width):
		for y in range(0, state.map.height):
			if(state.map.get_tile_xy(x, y) == &"Water"):
				set_cell(Vector2i(x,y), 0, Vector2i.ZERO, 1)
			if(state.map.get_tile_xy(x, y) == &"Ground"):
				set_cell(Vector2i(x,y), 0, Vector2i.ZERO, 2)	

func _process(_delta: float) -> void:
	pass
