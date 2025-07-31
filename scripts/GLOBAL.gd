extends Node
var look_sensitivity : float = 0.1


func change_sensitivity(new_sens):
	look_sensitivity = new_sens * 0.3 / 100
	print(look_sensitivity)
