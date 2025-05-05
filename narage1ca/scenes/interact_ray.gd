extends RayCast3D

@onready var prompt = $Prompt

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	prompt.text = ""
	
	if is_colliding():
		var collider = get_collider()
		
		if collider is Interactable:
			prompt.text = collider.prompt_message
			
			if Input.is_action_just_pressed("interact"):
				collider.interact(owner)
