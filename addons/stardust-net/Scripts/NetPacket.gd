extends Resource

class_name NetPacket

var type:String = ""
var sender_id:int = 0
var receiver_ids = []
var instance_targets = []
var tick = 0
var data:Dictionary = {}
var processed:bool = false

##type is a string that indicates
func _init(type:String, data:Dictionary, instance_targets = [], receiver_ids:Array = []):
	self.type = type
	self.sender_id = StarDustNet.get_net_id()
	self.data = data
	self.receiver_ids = receiver_ids
	self.instance_targets = instance_targets
	self.tick = StarDustNet.get_tick()


func serialize():
	var packet = {
		"t":type,
		"sid":sender_id,
		"rid":receiver_ids,
		"itt":instance_targets,
		"tk":tick,
		"data":data
	}
	var result = JSON.stringify(packet)
	return result

static func deserialize(packet:String) -> NetPacket:
	var dat = JSON.parse_string(packet)
	var np = NetPacket.new(dat["t"], dat["data"], dat["itt"], dat["rid"])
	np.sender_id = dat["sid"]
	np.tick = dat["tk"]
	return np

func is_sender_server():
	if(sender_id == 1):
		return true
	return false
