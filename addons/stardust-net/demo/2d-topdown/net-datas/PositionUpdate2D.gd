extends SDN_NetData

class_name PositionUpdate2D

static var TYPE_UPDATE_POSITION_2D = "p2d"

static var INSTANCE_ID_CODE = "iid"
static var POS_X_CODE = "pox"
static var POS_Y_CODE = "poy"
static var ROT_CODE = "rot"


var instance_id:int
var position_x:float
var position_y:float
var rotation:float

func _init(instance_id:int, position_x:float, position_y:float, rotation:float):
	self.instance_id = instance_id
	self.position_x = position_x
	self.position_y = position_y
	self.rotation = rotation

static func map_data(data:Dictionary):
	var dat = PositionUpdate2D.new(data[INSTANCE_ID_CODE], data[POS_X_CODE], data[POS_Y_CODE], data[ROT_CODE])
	return dat


func get_as_data()->Dictionary:
	return {
		INSTANCE_ID_CODE: instance_id,
		POS_X_CODE: position_x,
		POS_Y_CODE: position_y,
		ROT_CODE: rotation
	}
