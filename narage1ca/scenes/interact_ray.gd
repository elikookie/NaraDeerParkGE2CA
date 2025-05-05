extends RayCast3D

@onready var prompt = $Prompt

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	prompt.text = ""
	
	if is_colliding():
		
		prompt.text = "detecting "
