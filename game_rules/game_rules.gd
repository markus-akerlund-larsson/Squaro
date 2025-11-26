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
	if enemy.tags.has(EnemyState.Tag.FLYING):
		if !state.blocked_tile(endTile+dir):
			endTile += dir
			enemy.position = endTile
		
	enemy.status[EnemyState.Status.BUMPED] = 0
	actions.append(BumpAction.new(enemy.id, endTile))
	
	if state.map.get_tile(endTile) == &"Water" and !enemy.tags.has(EnemyState.Tag.FLYING):
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
	
	for enemy: EnemyState in state.enemies:
		# Enemy turn logic goes here
		
		var dir = _select_enemy_dir(state, enemy)
		
		if MapState.gridDistance(state.player.position, enemy.position) == 1:
			# attacking code here
			if(!enemy.tags.has(EnemyState.Tag.HARMLESS)):
				state.player.health -= 1
				actions.append(PlayerDamageAction.new(state.player.health))
			if(enemy.tags.has(EnemyState.Tag.HIT_AND_RUN)):
				enemy.status[EnemyState.Status.RETREATING] = 3
			if(enemy.tags.has(EnemyState.Tag.COOLDOWN)):
				enemy.status[EnemyState.Status.RESTING] = 3
				
		if enemy.status.has(EnemyState.Status.BUMPED):
			enemy.status.erase(EnemyState.Status.BUMPED)
			dir = Vector2i.ZERO
		
		if enemy.status.has(EnemyState.Status.RESTING):
			enemy.status[EnemyState.Status.RESTING] -= 1
			dir = Vector2i.ZERO
			if enemy.status[EnemyState.Status.RESTING] < 1:
				enemy.status.erase(EnemyState.Status.RESTING)
		
		if _valid_enemy_move(state, enemy, enemy.position+dir):
			enemy.position += dir
			actions.append(MoveAction.new(enemy.id, enemy.position))
			
		if enemy.tags.has(EnemyState.Tag.FLYING):
			print("flying")
			dir = _select_enemy_dir(state, enemy)
			if _valid_enemy_move(state, enemy, enemy.position+dir):
				print(str(dir))
				enemy.position += dir
				actions.append(MoveAction.new(enemy.id, enemy.position))
			
	
	return Update.new(actions, state)
	
static func _enemy_distance_sort(a: EnemyState, b: EnemyState, position: Vector2i) -> bool:
	return MapState.gridDistance(a.position, position) > MapState.gridDistance(b.position, position)
	
static func _valid_enemy_move(state: GameState, enemy: EnemyState, pos: Vector2i) -> bool:
	return (enemy.position != pos
			and MapState.gridDistance(enemy.position, state.player.position) > 1
			and (state.map.get_tile(pos) == &"Ground" or (enemy.tags.has(EnemyState.Tag.FLYING) and state.map.get_tile(pos) == &"Water"))
			and not state.blocked_tile(pos))
			
static func _select_enemy_dir(state: GameState, enemy: EnemyState) -> Vector2i:
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
			if abs(state.player.last_move_dir.x) < abs(state.player.last_move_dir.y):
				dir = Vector2i(sign(playerDir).x, 0)
			else:
				dir = Vector2i(0, sign(playerDir).y)
		
		if enemy.status.has(EnemyState.Status.RETREATING):
			dir = -dir
			alternate = -alternate
			print(enemy.name)
			print("enemy retreating")
			print(dir)
			print(alternate)
			enemy.status[EnemyState.Status.RETREATING] -= 1
			if enemy.status[EnemyState.Status.RETREATING] < 1:
				enemy.status.erase(EnemyState.Status.RETREATING)
		
		if not _valid_enemy_move(state, enemy, enemy.position+dir):
			dir = alternate
			
		return dir

	
	
