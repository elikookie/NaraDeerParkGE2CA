extends Control

func _ready():
	$AnimationPlayer.play("RESET")
	hide()

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()

func sliders():
	if Input.is_action_just_pressed("menu") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("menu") and get_tree().paused:
		resume()


func _on_resume_pressed():
	resume()


func _on_quit_pressed():
	get_tree().quit()


func _on_options_pressed():
	resume()

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)


func _on_mute_toggled(toggled_on: bool) -> void:
	pass 
	
func _process(delta: float) -> void:
	sliders()


func _on_quit_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.
