class_name Light_Source extends Node2D
@onready var map: TileMap = get_parent() 
@onready var mapPos:Vector2i = map.local_to_map(transform.get_origin())
@export var LIGHT:int = 8
@export var SCALE:float = 0.66
func _ready():
	var width=ceil(LIGHT*SCALE)
	for y in range(-width, width+1):
		for x in range(-width, width+1):
			var pos = mapPos + Vector2i(x,y)
			var tilePos = map.get_cell_atlas_coords(SETTINGS.LAY_LIGHT, pos)
			var light_level = max(LIGHT-floor((x**2 + y**2)**SCALE), tilePos.y)
			map.set_cell(SETTINGS.LAY_LIGHT, pos, SETTINGS.SRC_LIGHT, Vector2i(tilePos.x, light_level))
