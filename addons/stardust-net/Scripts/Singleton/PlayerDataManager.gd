extends Node


var _properties = {}

signal property_updated


func init_manager():
	if(!StarDustNet.is_server()):
		StarDustNet.subscribe_to_packet(self, SDN_TypeCodes.TYPE_PLAYER_DATA)

func update_property(name:String, target_id:int, value):
	if(!_properties.has(target_id)):
		_properties[target_id] = {}
		
	_properties[target_id][name] = value
	if(StarDustNet.is_server()):
		var dat = SDN_PlayerData.new(name, target_id, value)
		var np = NetPacket.new(SDN_TypeCodes.TYPE_PLAYER_DATA, dat.get_as_data()) 
		StarDustNet.send_packet_reliable(np)

func get_property(id:int, name:String):
	if(_properties.has(id)):
		if(_properties[id].has(name)):
			return _properties[id][name]

func packet_received(net_packet:NetPacket):
	if(net_packet.type == SDN_TypeCodes.TYPE_PLAYER_DATA):
		var dat:SDN_PlayerData = SDN_PlayerData.map_data(net_packet.data)
		if(!_properties.has(dat.target_player)):
			_properties[dat.target_player] = {}
		
		_properties[dat.target_player][dat.name] = dat.value
		emit_signal("property_updated", dat.name, dat.target_player, dat.value)
