extends SDN_NetData

class_name InputData

static var TYPE_INPUT = "inp"

static var MOVEMENT_X_CODE = "mvx"
static var MOVEMENT_Y_CODE = "mvy"

var movement:Vector2

func _init(movement:Vector2):
	self.movement = movement

static func map_data(data:Dictionary):
	var dat = InputData.new(Vector2(data[MOVEMENT_X_CODE], data[MOVEMENT_Y_CODE]))
	return dat

func get_as_data()->Dictionary:
	return {
		MOVEMENT_X_CODE: movement.x,
		MOVEMENT_Y_CODE: movement.y
	}
