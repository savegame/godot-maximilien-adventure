tool
extends Area2D

export (String) var letter = 'M'
export (bool) var flip = false

var previous_flip: bool = !flip
var previous_letter: String = ''


func _ready() -> void:
	connect('body_entered', self, '_on_Player_enter')
	connect('body_exited', self, '_on_Player_exited')
	$Letter/Label.text = letter
	$AnimationPlayer.play('Idle')
	$AnimationPlayer.connect('animation_finished', self, '_on_Chest_animation_finished')
	$Sprite.flip_h = flip
	if not Engine.editor_hint:
		$Inputs.hide()
	if flip:
		$Sprite.position = Vector2(-7, -7)
	else:
		$Sprite.position = Vector2(10, -7)
	
	if not ProjectSettings.get_setting('Debug/sound'):
		$AudioStreamPlayer.stream = null


#warning-ignore:unused_argument
func _process(delta) -> void:
	if Engine.editor_hint:
		if previous_letter != letter:
			$Inputs.show()
			$Letter/Label.text = letter
			previous_letter = letter
		if flip != previous_flip:
			$Inputs.show()
			$Sprite.flip_h = flip
			previous_flip = flip
			if flip:
				$Sprite.position = Vector2(-7, -7)
			else:
				$Sprite.position = Vector2(10, -7)


func _on_Player_enter(body: Player) -> void:
	assert body is Player
	body.can_open_chest = true
	body.chest_position = position
	$Inputs.show()
	ChestManager.connect('active_chest', self, '_on_Chest_open')


func _on_Player_exited(body: Player) -> void:
	assert body is Player
	$Inputs.hide()
	ChestManager.disconnect('active_chest', self, '_on_Chest_open')


func _on_Chest_open() -> void:
	ChestManager.disconnect('active_chest', self, '_on_Chest_open')
	disconnect('body_entered', self, '_on_Player_enter')
	disconnect('body_exited', self, '_on_Player_exited')
	$Inputs.hide()
	GameManager.find_new_letter(letter)
	$AnimationPlayer.play('Open')


func _on_Chest_animation_finished(anim_name: String) -> void:
	if anim_name == 'Open':
		ChestManager.inactive_chest()