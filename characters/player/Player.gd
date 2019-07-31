extends Character
class_name Player

signal player_position_changed(new_position)
signal player_global_position_changed(new_position)

signal player_death

# cache
onready var Physics2D: Node2D = $Physics2D

var previous_position: Vector2 = Vector2()
var grounded_position: Vector2 = Vector2()


func _ready() -> void:
	# Signals
	$AnimationPlayer.connect('animation_finished', self, '_on_Animation_finished')
	$Health.connect('take_damage', self, '_on_Getting_hit')
	$Health.connect('health_changed', $UI/PlayerHUD/HealthBar, '_on_Health_changed')
	$Sprite/LastGroundedPositionChecker.connect('body_exited', self, '_on_last_grounded_position_changed')
	GameManager.set_new_checkpoint(position) 
	._initialize_state()


# Delegate the call to theer
func _physics_process(delta: float) -> void:
	current_state.update(self, delta)
	Physics2D.compute_gravity(self, delta)
	if previous_position != position:
		_on_position_changed()
		_on_global_position_changed()
		if ProjectSettings.get_setting('Debug/debug_mode'):
			DebugManager.set_player_velocity(velocity)


# Connect to Health
func _on_Getting_hit(alive: bool) -> void:
	is_alive = alive
	if is_alive:
		$FlashPlayer.play('Flash')
	else:
		print('Player is death')
		GameManager.player_loose_life()
		position = GameManager.get_last_checkpoint()
		$Health.reset() # TODO: change this when game over screen


func _change_state(state_name: String) -> void:
	if ProjectSettings.get_setting('Debug/debug_mode'):
		DebugManager.set_player_state(state_name)
	._change_state(state_name)


# Catch input
func _input(event: InputEvent) -> void:
	current_state.handle_input(self, event)


func start_cooldown():
	$CooldownTimer.start()
	$CooldownBar.start()


func respawn() -> void:
	print('Player has respawn')
	if is_alive:
		position = grounded_position


# Should send the last position where the player was on the ground
#warning-ignore:unused_argument
func _on_last_grounded_position_changed(body: PhysicsBody2D) -> void:
	grounded_position = position
	DebugManager.set_player_respawn(grounded_position)
	

func _on_position_changed() -> void:
	previous_position = position
	emit_signal('player_position_changed', position)
	

func _on_global_position_changed() -> void:
	previous_position = position
	emit_signal('player_global_position_changed', get_global_position())


func _toggle_collision_shape() -> void:
	$StandCollisionShape.disabled = !$StandCollisionShape.disabled
	$SlideCollisionShape.disabled = !$SlideCollisionShape.disabled