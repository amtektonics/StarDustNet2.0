extends SDN_NetData
class_name SDN_PlayerData

var name:String
var value
var target_player:int

func _init(name:String, target_player:int, value):
	self.name = name
	self.value = value
	self.target_player = target_player

static func map_data(data:Dictionary):
	return SDN_PlayerData.new(data[SDN_TypeCodes.NAME_CODE], data[SDN_TypeCodes.TARGET_PLAYER_ID_CODE], data[SDN_TypeCodes.VALUE_CODE])

func get_as_data()->Dictionary:
	return {SDN_TypeCodes.NAME_CODE: name, SDN_TypeCodes.TARGET_PLAYER_ID_CODE:target_player, SDN_TypeCodes.VALUE_CODE: value}
