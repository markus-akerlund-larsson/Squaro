class_name GameRules
extends Object

static var player_id = 1

static func player_bump(p_state: GameState, target: Vector2i) -> Update:
	var state = p_state.duplicate(true)
	var actions: Array[Action] = []
	
	var enemy = state.enemy_at(target)
	var dir = enemy.position - state.player.position
	
	var endTile = enemy.position+dir
	if state.blocked_tile(endTile): return null
	enemy.position = endTile
	if enemy.tags.has(Enemy.Tag.FLYING):
		if !state.blocked_tile(endTile+dir):
			endTile += dir
			enemy.position = endTile
		
	enemy.status[Enemy.Status.BUMPED] = 0
	actions.append(BumpAction.new(enemy.id, endTile))
	
	if state.map.get_tile(endTile) == &"Water" and !enemy.tags.has(Enemy.Tag.FLYING):
		state.enemies.erase(enemy)
		state.map.set_tile(endTile, &"Ground")
		actions.append(SinkEnemyAction.new(enemy.id, endTile))
	
	return Update.new(actions, state)

static func player_move(p_state: GameState, to: Vector2i) -> Update:
	print("Player move to "+str(to))
	var state = p_state.duplicate(true)
	
	state.player.last_move_dir= to - state.player.position
	state.player.position = to;
	return enemy_turn([MoveAction.new(player_id, to)], state)
	
static func enemy_turn(actions: Array[Action], p_state: GameState) -> Update:
	print("Enemy turn start")
	var state = p_state.duplicate(true)
	
	state.enemies.shuffle()
	state.enemies.sort_custom(func(a, b): _enemy_distance_sort(a, b, state.player.position))
	
	for enemy: Enemy in state.enemies:
		# Enemy turn logic goes here
		
		var dir = _select_enemy_dir(state, enemy)
		
		if Map.gridDistance(state.player.position, enemy.position) == 1:
			actions.append_array(_enemy_attack(state, enemy))
		
		if enemy.status.has(Enemy.Status.RESTING):
			dir = Vector2i.ZERO
		
		if _valid_enemy_move(state, enemy, enemy.position+dir) and not enemy.status.has(Enemy.Status.BUMPED):
			enemy.position += dir
			actions.append(MoveAction.new(enemy.id, enemy.position))
			
		if enemy.tag.has(Enemy.Tag.FLYING) and not enemy.status.has(Enemy.Status.BUMPED):
			dir = _select_enemy_dir(state, enemy)
			if _valid_enemy_move(state, enemy, enemy.position+dir):
				print(str(dir))
				enemy.position += dir
				actions.append(MoveAction.new(enemy.id, enemy.position))
				
		_count_down_status(enemy, Enemy.Status.RESTING)
		_count_down_status(enemy, Enemy.Status.RETREATING)
		_count_down_status(enemy, Enemy.Status.BUMPED)
			
	return Update.new(actions, state)
	
static func _enemy_attack(state: GameState, enemy: Enemy) -> Array[Action]:
	var actions: Array[Action] = []
	if(!enemy.tag.has(Enemy.Tag.HARMLESS)):
		state.player.health -= 1
		actions.append(PlayerDamageAction.new(state.player.health))
	if(enemy.tag.has(Enemy.Tag.HIT_AND_RUN)):
		enemy.status[Enemy.Status.RETREATING] = 3
	if(enemy.tag.has(Enemy.Tag.COOLDOWN)):
		enemy.status[Enemy.Status.RESTING] = 3
	return actions
	
	
static func _enemy_distance_sort(a: Enemy, b: Enemy, position: Vector2i) -> bool:
	return Map.gridDistance(a.position, position) > Map.gridDistance(b.position, position)
	
static func _valid_enemy_move(state: GameState, enemy: Enemy, pos: Vector2i) -> bool:
	return (enemy.position != pos
			and (state.map.get_tile(pos) == &"Ground" or (enemy.tag.has(Enemy.Tag.FLYING) and state.map.get_tile(pos) == &"Water"))
			and not state.blocked_tile(pos))
			
static func _select_enemy_dir(state: GameState, enemy: Enemy) -> Vector2i:
		var playerDir = state.player.position - enemy.position
		var dir: Vector2i
		var alternate := Vector2i.ZERO
		#move along the axis most distant to the player
		if abs(playerDir.x) > abs(playerDir.y):
			dir = Vector2i(sign(playerDir).x, 0)
			alternate = Vector2i(0, sign(playerDir).y)
		elif abs(playerDir.y) > abs(playerDir.x):
			dir = Vector2i(0, sign(playerDir).y)
			alternate = Vector2i(sign(playerDir).x, 0)
		else: 
			#if they're the same, pick based on player's last move
			# > : move along the same axis as the player did (more like Auro)
			# < : move along the opposite axis as the player did (more "chasing")
			if abs(state.player.last_move_dir.x) > abs(state.player.last_move_dir.y):
				dir = Vector2i(sign(playerDir).x, 0)
			else:
				dir = Vector2i(0, sign(playerDir).y)
		
		if enemy.status.has(Enemy.Status.RETREATING):
			dir = -dir
			alternate = -alternate
		
		if not _valid_enemy_move(state, enemy, enemy.position+dir):
			dir = alternate
			
		return dir
		
static func _count_down_status(enemy: Enemy, status: Enemy.Status) -> void:
	if enemy.status.has(status):
		enemy.status[status] -= 1
		if enemy.status[status] < 1:
			enemy.status.erase(status)
	
