extends Node2D

var is_open = false
@onready var icon = $Icon

# Called when the node enters the scene tree for the first time.
func OpenChest():
	if is_open: return 0
	is_open = true
	var value:int = randi_range(SETTINGS.MIN_GOLD,SETTINGS.MAX_GOLD)
	_animate(value)
	return value


func _animate(val:int):
	icon.play("open")
	var goldPopup: Label = Label.new()  # or Label.new() if using Label
	goldPopup.set_text("+%d" % val)
	goldPopup.scale = Vector2(.2,.2)
	goldPopup.modulate = Color(1, .843, 0, 1)
	add_child(goldPopup)
	goldPopup.position.x -= 4.0
	goldPopup.set_anchors_preset(Control.PRESET_CENTER)
	var tween = goldPopup.create_tween()
	tween.tween_property(goldPopup, 'position', Vector2(-4, -4), 1).set_ease(Tween.EASE_OUT)
	tween.tween_property(goldPopup, 'modulate', Color(1, .843, 0, 0), 1).set_ease(Tween.EASE_IN)
	
	# Add a timer to remove the Label after a certain duration
	get_tree().create_timer(SETTINGS.POP_UP_TIME).timeout.connect(goldPopup.queue_free)
	get_tree().create_timer(SETTINGS.CHEST_RESPAWN_TIME).timeout.connect(closeChest)
		
		
func closeChest():
	is_open = false
	icon.play_backwards('open')
	

