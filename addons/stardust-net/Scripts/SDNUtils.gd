extends Node
class_name SDN_Utils

func encode_vec2(vec:Vector2):
	return str(str(vec.x) + "," + str(vec.y))
	
func decode_vec2(value:String):
	var values  = value.split(",")
	return Vector2(float(values[0]), float(values[1]))

func encode_vec3(vec:Vector3):
	return str(str(vec.x) + "," + str(vec.y) + "," + str(vec.z))

func decode_vec3(value:String):
	var values  = value.split(",")
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


static func compensate_lag_vec3(last_vec:Vector3, new_vec:Vector3) -> Vector3:
	var ping = SDN_PlayerDataManager.get_property(StarDustNet.get_net_id(), SDN_TypeCodes.TYPE_PING)
	if(ping == null):
		ping = 0
	else:
		ping = int(ping)
	var lerp_value = .25
	if(ping > 4):
		lerp_value = 1.0 / (ping) * (last_vec.distance_to(new_vec) * 4)
	return last_vec.lerp(new_vec, lerp_value)

static func compensate_lag_vec2(last_vec:Vector2, new_vec:Vector2) -> Vector2:
	var ping = SDN_PlayerDataManager.get_property(StarDustNet.get_net_id(), SDN_TypeCodes.TYPE_PING)
	if(ping == null):
		ping = 0
	else:
		ping = int(ping)
	var lerp_value = .25
	if(ping > 50):
		lerp_value = 1.0 / (ping) * (last_vec.distance_to(new_vec) * 4)
	var result = last_vec.lerp(new_vec, lerp_value)
	return result
	
static func compensate_lag_angle_float( last_value:float, new_value:float) -> float:
	var ping = SDN_PlayerDataManager.get_property(StarDustNet.get_net_id(), SDN_TypeCodes.TYPE_PING)
	if(ping == null):
		ping = 0
	else:
		ping = int(ping)
	var lerp_value = .25
	if(ping > 50):
		lerp_value = 1.0 / (ping) * (angle_difference(last_value, new_value) * 4)
	return lerp_angle(last_value, new_value, lerp_value)

class SDN_MessageLimiter:
	var _tups = 0
	var _callback:Callable
	var _delta_sum = 0
	func _init(target_updates_per_second:int, callback_function:Callable) -> void:
		_tups = target_updates_per_second
		_callback = callback_function
	
	func process(delta:float):
		if(_delta_sum >= (1 / _tups)):
			_callback.call(delta)
			_delta_sum -= (1 / _tups)
		_delta_sum += delta
