extends CollisionObject3D
class_name Interactable

@export var prompt_message = "Interactable"
@export var prompt_input = "interact"

func get_prompt():
	var key_name = ""
	for action in InputMap.action_get_events(prompt_input):
		if action is InputEventKey:
			key_name - action.as_text_physical_keycode()
			break
			
	return prompt_message + "\n[" + key_name + "]"


func interact(body):
	print(body.name, " interacted with ", name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
