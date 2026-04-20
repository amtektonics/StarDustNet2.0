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


#tick base compensation
static func compensate_lag_vec2(old_position:Vector2, new_position:Vector2, tick_diff:float)-> Vector2:
	if(tick_diff != 0):
		return old_position.lerp(new_position,  clampf(.01 * tick_diff, 0, 1))
	else:
		return new_position

static func compensate_lag_vec3(old_position:Vector3, new_position:Vector3, tick_diff:float)-> Vector3:
	if(tick_diff != 0):
		return old_position.lerp(new_position,  clampf(.01 * tick_diff, 0, 1))
	else:
		return new_position

static func compensate_lag_angle_vec2(old_position:Vector2, new_position:Vector2, tick_diff:float)-> Vector2:
	if(tick_diff != 0):
		var x = lerp_angle(old_position.x, new_position.x,  clampf(.01 * tick_diff, 0, 1))
		var y = lerp_angle(old_position.y, new_position.y, clampf(.01 * tick_diff, 0, 1))
		return Vector2(x, y)
	else:
		return new_position

static func compensate_lag_angle_vec3(old_position:Vector3, new_position:Vector3, tick_diff:float)-> Vector3:
	if(tick_diff != 0):
		var x = lerp_angle(old_position.x, new_position.x,  clampf(.01 * tick_diff, 0, 1))
		var y = lerp_angle(old_position.y, new_position.y,  clampf(.01 * tick_diff, 0, 1))
		var z = lerp_angle(old_position.z, new_position.z,  clampf(.01 * tick_diff, 0, 1))
		return Vector3(x, y, z)
	else:
		return new_position

static func compensate_lag_float(old_float:float, new_float:float, tick_diff:float)-> float:
	if(tick_diff != 0):
		return lerp(old_float, new_float,  clampf(.01 * tick_diff, 0, 1))
	else:
		return new_float

static func compensate_lag_angle(old_float:float, new_float:float, tick_diff:float)-> float:
	if(tick_diff != 0):
		return lerp_angle(old_float, new_float,  clampf(.01 * tick_diff, 0, 1))
	else:
		return new_float


#ping based compensation
static func compensate_lag_vec3_ping(last_vec:Vector3, new_vec:Vector3) -> Vector3:
	var ping = SDN_PlayerDataManager.get_property(StarDustNet.get_net_id(), SDN_TypeCodes.TYPE_PING)
	if(ping == null):
		ping = 0
	else:
		ping = int(ping)
	var lerp_value = .25
	if(ping > 4):
		lerp_value = 1.0 / (ping) * (last_vec.distance_to(new_vec) * 4)
	return last_vec.lerp(new_vec, lerp_value)

static func compensate_lag_angle_vec3_ping(last_vec:Vector3, new_vec:Vector3)->Vector3:
	var ping = SDN_PlayerDataManager.get_property(StarDustNet.get_net_id(), SDN_TypeCodes.TYPE_PING)
	if(ping == null):
		ping = 0
	else:
		ping = int(ping)
	var lerp_value = .25
	if(ping > 4):
		lerp_value = 1.0 / (ping) * (last_vec.distance_to(new_vec) * 4)
	var x = lerp_angle(last_vec.x, new_vec.x, lerp_value)
	var y = lerp_angle(last_vec.y, new_vec.y, lerp_value)
	var z = lerp_angle(last_vec.z, new_vec.z, lerp_value)
	return Vector3(x, y, z)

static func compensate_lag_vec2_ping(last_vec:Vector2, new_vec:Vector2) -> Vector2:
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

static func compensate_lag_angle_vec2_ping(last_vec:Vector2, new_vec:Vector2)->Vector2:
	var ping = SDN_PlayerDataManager.get_property(StarDustNet.get_net_id(), SDN_TypeCodes.TYPE_PING)
	if(ping == null):
		ping = 0
	else:
		ping = int(ping)
	var lerp_value = .25
	if(ping > 4):
		lerp_value = 1.0 / (ping) * (last_vec.distance_to(new_vec) * 4)
	var x = lerp_angle(last_vec.x, new_vec.x, lerp_value)
	var y = lerp_angle(last_vec.y, new_vec.y, lerp_value)
	return Vector2(x, y)

static func compensate_lag_angle_float_ping( last_value:float, new_value:float) -> float:
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
