"""
Camera2D manager
"""
extends Camera2D

var zoom_type: String = 'zoom_out'
var previous_zoom := zoom
var previous_offset := offset


func _ready() -> void:
	$Tween.connect('tween_completed', self, '_on_Tween_completed')
	CameraManager.connect('camera_zoom_in', self, '_on_Zoom_in')
	CameraManager.connect('camera_zoom_out', self, '_on_Zoom_out')
	CameraManager.connect('camera_transition', self, '_on_Transition')
	$AnimationPlayer.connect('animation_finished', self, '_on_Animation_finished')
	$Shader/Transition.visible = false


"""
Start a camera transitoin
@param {string} type e.g. Curtain
"""
func _on_Transition(type: String) -> void:
	smoothing_enabled = false
	$AnimationPlayer.play(type)


"""
Zoom and focus on a position
@param {vector2} position_to_zoom
"""
func _on_Zoom_in(position_to_zoom: Vector2) -> void:
	# comptute offset distance
	var distance = get_parent().position.distance_to(position_to_zoom)
	# direction
	var direction: int = (position_to_zoom - get_parent().position).normalized().x
	zoom_type = 'zoom_in'
	previous_zoom = zoom
	previous_offset = offset
	$Tween.interpolate_property(self, 'offset', offset, Vector2(distance * direction, -50), 0.25, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Tween.start()


"""
Reset zoom position
"""
func _on_Zoom_out() -> void:
	zoom_type = 'zoom_out'
	$Tween.interpolate_property(self, 'offset', offset, previous_offset, 0.25, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Tween.interpolate_property(self, 'zoom', zoom, previous_zoom, 0.25, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Tween.start()


"""
Tween callback
"""
#warning-ignore:unused_argument
func _on_Tween_completed(object: Object, key: NodePath) -> void:
	if key == ':offset':
		if zoom_type == 'zoom_in':
			$Tween.interpolate_property(self, 'zoom', zoom, Vector2(1, 1), 0.15, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
			$Tween.start()


"""
On animation finished
"""
func _on_Animation_finished(anim_name: String) -> void:
	if anim_name == 'Curtain':
		$AnimationPlayer.play('Setup')
		CameraManager.transition_finished()