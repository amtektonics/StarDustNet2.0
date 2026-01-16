extends SDN_NetData

class_name PlayerData

static var TYPE_PLAYER_DATA = "pdt"

static var INSTANCE_ID_CODE = "iid"
static var PLAYER_NET_ID_CODE = "nid"


var instance_id:int
var player_net_id:int

func _init(instance_id:int, player_net_id:int) -> void:
	self.instance_id = instance_id
	self.player_net_id = player_net_id

static func map_data(data:Dictionary):
	return PlayerData.new(data[INSTANCE_ID_CODE], data[PLAYER_NET_ID_CODE])

func get_as_data()->Dictionary:
	return {INSTANCE_ID_CODE: instance_id, PLAYER_NET_ID_CODE: player_net_id}
