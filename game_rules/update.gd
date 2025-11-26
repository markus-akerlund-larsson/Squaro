class_name Update
extends RefCounted

var actions: Array[Action]
var state: GameState

func _init(p_actions: Array[Action], p_state: GameState) -> void:
	actions = p_actions
	state = p_state
