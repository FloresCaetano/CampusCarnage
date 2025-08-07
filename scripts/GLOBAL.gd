extends Node
var look_sensitivity : float = 0.1

#GLOBAL NODES
@onready var dialog_bubble : DialogBubble = get_tree().get_first_node_in_group("DialogueBubble")

func change_sensitivity(new_sens):
	look_sensitivity = new_sens * 0.3 / 100
	print(look_sensitivity)
