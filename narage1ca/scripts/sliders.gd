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


func _on_deer_number_value_changed(count: int) -> void:
	pass
	#var current_deer = get_tree().get_nodes_in_group("deer")
	#var parent = current_deer[0].get_parent() if current_deer.size() > 0 else get_node("/root/Main/DeerContainer")
	#var deer_scene = preload("res://scenes/deer.tscn")
#
	## Add or remove deer
	#while current_deer.size() < count:
		#var d = deer_scene.instantiate()
		#parent.add_child(d)
		#current_deer = get_tree().get_nodes_in_group("deer")
	#while current_deer.size() > count:
		#current_deer[0].queue_free()
		#current_deer = get_tree().get_nodes_in_group("deer")


func _on_walk_speed_value_changed(value: float) -> void:
	for deer in get_tree().get_nodes_in_group("deer"):
		deer.speed = clamp(value, deer.min_speed, deer.max_speed)


func _on_option_button_item_selected(index: int) -> void:
	var state = ["wander", "hungry", "graze", "flock"][index]
	for deer in get_tree().get_nodes_in_group("deer"):
		match state:
			"wander":
				deer.start_wander()
			"hungry":
				deer.start_hungry()
			"graze":
				deer.start_graze()
			"flock":
				deer.become_flock_leader()


func _on_add_deer_pressed() -> void:
	pass
	#var deer_scene = preload("res://scenes/deer.tscn")
	#var deer_parent = get_node("DeerContainer")
#
	#var deer = deer_scene.instantiate()
	#deer_parent.add_child(deer)
