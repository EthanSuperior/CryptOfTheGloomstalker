@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("LightSource", "Node2D", preload("./Light_Source.gd"), preload("res://icon.svg"))


func _exit_tree():
	remove_custom_type("LightSource")
