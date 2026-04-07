extends SDN_NetData

class_name SDFPSNetData


var position:Vector3 = Vector3()
var rotation = 0.0
var tilt = 0.0
var instance_id = 0


func _init(position:Vector3, rotation:float, tilt:float, instance_id:int):
	self.position = position
	self.rotation = rotation
	self.tilt = tilt
	self.instance_id = instance_id


static func map_data(data:Dictionary):
	var pos = Vector3(data[SDN_TypeCodes.POSITION_X_CODE], data[SDN_TypeCodes.POSITION_Y_CODE], data[SDN_TypeCodes.POSITION_Z_CODE])
	var dat = SDFPSNetData.new(pos, data[SDN_TypeCodes.HEAD_ROTATION_CODE], data[SDN_TypeCodes.HEAD_TILT_CODE], data[SDN_TypeCodes.INSTANCE_ID_CODE])
	return dat

func get_as_data()->Dictionary:
	return {
		SDN_TypeCodes.POSITION_X_CODE: position.x,
		SDN_TypeCodes.POSITION_Y_CODE: position.y,
		SDN_TypeCodes.POSITION_Z_CODE: position.z,
		SDN_TypeCodes.HEAD_ROTATION_CODE: rotation,
		SDN_TypeCodes.HEAD_TILT_CODE:tilt,
		SDN_TypeCodes.INSTANCE_ID_CODE: instance_id
	}
