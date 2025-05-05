extends Node

var state := {
	"cookie": 0
}

func get_value(key):
	if state.has(key):
		return state[key]
		
		
func set_value(key, value):
	state[key] = value
