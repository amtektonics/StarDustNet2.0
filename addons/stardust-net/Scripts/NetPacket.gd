extends Resource

class_name NetPacket

var type:String = ""
var sender_id:int = 0
var reciver_id:int = 0
var tick = 0
var data:Dictionary = {}
var processed:bool = false


func _init(type:String, data:Dictionary, reciver_id:int = 0):
	self.type = type
	self.sender_id = StarDustNet.get_net_id()
	self.data = data
	self.reciver_id = reciver_id
	self.tick = StarDustNet.get_tick()


func serialize():
	var packet = {
		"t":type,
		"sid":sender_id,
		"rid":reciver_id,
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
