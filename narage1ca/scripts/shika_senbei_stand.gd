extends Interactable


func _on_interacted(body: Variant) -> void:
	GameState.set_value("cookie", GameState.get_value("cookie") + 5)
	$AudioStreamPlayer3D.play()
