extends Resource

class_name NetPacket

var type:String = ""
var sender_id:int = 0
var receiver_ids = []
var tick = 0
var data:Dictionary = {}
var processed:bool = false


func _init(type:String, data:Dictionary, receiver_ids:Array = []):
	self.type = type
	self.sender_id = StarDustNet.get_net_id()
	self.data = data
	self.receiver_ids = receiver_ids
	self.tick = StarDustNet.get_tick()


func serialize():
	var packet = {
		"t":type,
		"sid":sender_id,
		"rid":receiver_ids,
		"tk":tick,
		"data":data
	}
	var result = JSON.stringify(packet)
	return result

static func deserialize(packet:String) -> NetPacket:
	var dat = JSON.parse_string(packet)
	var np = NetPacket.new(dat["t"], dat["data"], dat["rid"])
	np.sender_id = dat["sid"]
	np.tick = dat["tk"]
	return np

func is_sender_server():
	if(sender_id == 1):
		return true
	return false
