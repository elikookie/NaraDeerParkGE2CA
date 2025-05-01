extends Node3D

@export var deer_scene: PackedScene
@export var number_of_deer: int = 5
@onready var deer_container: Node3D = $DeerContainer

func _ready() -> void:
	randomize()
	spawn_deer()

func spawn_deer() -> void:
	for i in range(number_of_deer):
		var deer = deer_scene.instantiate()
		deer_container.add_child(deer)
		# now that it's in the tree, it's safe to set its transform:
		var x = randf_range(-5.0, 5.0)
		var z = randf_range(-5.0, 5.0)
		deer.global_transform.origin = Vector3(x, 0.0, z)
		
