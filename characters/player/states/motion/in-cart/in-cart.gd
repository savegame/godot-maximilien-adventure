extends Motion

func enter(host: Player) -> void:
	host.get_node('AnimationPlayer').play('Idle')
	host.input_enable = false
	host.gravity_enable = false
	host.velocity = Vector2.ZERO
	CartManager.connect('move_cart', self, '_move_Cart', [host])


# warning-ignore:unused_argument
func exit(host: Player) -> void:
	CartManager.disconnect('move_cart', self, '_move_Cart')


#warning-ignore:unused_argument
func update(host: Character, delta: float) -> void:
	update_look_direction(host, Vector2(1,0))



func _move_Cart(velocity: Vector2, host:Player) -> void:
	host.velocity = velocity
	emit_signal('finished', 'MoveCart')