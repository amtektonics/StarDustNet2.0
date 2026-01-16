extends Node
class_name SDN_Utils

func encode_vec2(vec:Vector2):
	return str(str(vec.x) + "," + str(vec.y))
	
func decode_vec2(value:String):
	var values  = value.split(",")
	return Vector2(float(values[0]), float(values[1]))
	

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
