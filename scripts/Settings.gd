extends Node

# region TILEMAP
const MAX_LIGHT = 8
const SRC_OBJ = 0
const SRC_LIGHT = 1
const SRC_TILES = 4
const LAY_GRD = 0
const LAY_OBJ = 1
const LAY_LIGHT = 2
const TILE_SIZE = 16
# endregion

#region TIME
const ONE_SEC = 1000.0
const START_PLAY_TIME = 40 * ONE_SEC
const MAX_DARK_TIME = 3 * ONE_SEC
const MAX_BONUS_TIME = 30.0
const POP_UP_TIME = 1.0
const CHEST_RESPAWN_TIME = 30.0
#endregion

const MIN_GOLD = 100
const MAX_GOLD = 500

func CALC_DEATH_BONUS(delta, time_left, looted):
	var danger = time_left / MAX_DARK_TIME / (looted + 1) if looted else 0
	return lerp(1.0, MAX_BONUS_TIME, danger**3) * delta * ONE_SEC
