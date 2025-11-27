class_name PlayerDamageAction
extends Action

var _health: int

func _init(health: int) -> void:
	_health = health
	
func execute(game: Node2D):
	game.health_display.text = "Health: "+str(_health)

	
