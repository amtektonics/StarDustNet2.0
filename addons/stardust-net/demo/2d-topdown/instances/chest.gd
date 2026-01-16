extends Node2D

var instance_id:int

func set_instance_id(id:int):
	instance_id = id
	if(!StarDustNet.is_server()):
		StarDustNet.subscribe_to_packet(self, PositionUpdate2D.TYPE_UPDATE_POSITION_2D, {PositionUpdate2D.INSTANCE_ID_CODE:instance_id})
	
	

func packet_received(net_packet:NetPacket):
	if(net_packet.type == PositionUpdate2D.TYPE_UPDATE_POSITION_2D):
		var pos_dat = PositionUpdate2D.map_data(net_packet.data)
		pos_dat.position_x
