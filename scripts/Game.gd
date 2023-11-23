extends Node2D

@onready var MAP:TileMap = $TileMap
var tileChildren:Dictionary = {}

func _ready():
	var torches = GenerateTerrain()
	for pos in MAP.get_used_cells(SETTINGS.LAY_GRD):
		MAP.set_cell(SETTINGS.LAY_LIGHT, pos, SETTINGS.SRC_LIGHT, Vector2i())
	PlaceTorches(torches)
	PopulateChildren.call_deferred()


func PopulateChildren():
	for c in MAP.get_children(true):
		var pos = MAP.local_to_map(c.position)
		tileChildren[pos] = [c, MAP.get_cell_alternative_tile(SETTINGS.LAY_OBJ, pos)]


func GenerateTerrain():
	var all_ground_path_tiles = []
	MAP.set_cells_terrain_connect(SETTINGS.LAY_GRD, all_ground_path_tiles, 0, 0)
	return []


func get_cell_node(coords: Vector2i, id:int = -1)-> Node2D:
	var nodeInfo = tileChildren.get(coords)
	if nodeInfo == null: return null
	if id==-1: return nodeInfo[0]
	return nodeInfo[0] if nodeInfo[1] == id else null

func PlaceTorches(torches):
	for torch in torches:
		MAP.set_cell(SETTINGS.LAY_OBJ, torch, SETTINGS.SRC_OBJ, Vector2i(), 0)
