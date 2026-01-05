extends CharacterBody2D

var instance_id = 0
var game_world:GameWorld

var last_update:PositionUpdate2D

func set_instance_id(id:int):
	instance_id = id
	if(!StarDustNet.is_server()):
		StarDustNet.subscribe_to_packet(self, PositionUpdate2D.TYPE_UPDATE_POSITION_2D, {PositionUpdate2D.INSTANCE_ID_CODE:instance_id})

var rolling_delta = 0
func _physics_process(delta: float) -> void:
	if(StarDustNet.is_server()):
		var pos = get_global_position()
		pos += Vector2(randf_range(-1, 1), randf_range(-1, 1))
		set_global_position(pos)
		
		var rot = get_global_rotation()
		rot += randf_range(-0.5, 0.5)
		set_global_rotation(rot)
		
		if(rolling_delta > 0.05):
			var players = game_world.get_nearby_players_net_id(instance_id, 256)
			var pos_dat:PositionUpdate2D = PositionUpdate2D.new(instance_id,\
			get_global_position().x,\
			get_global_position().y,\
			get_global_rotation())
			
			for pid in players:
				var np = NetPacket.new(PositionUpdate2D.TYPE_UPDATE_POSITION_2D,\
				pos_dat.get_as_data(),\
				pid)
				StarDustNet.send_packet_unreliable(np)
			rolling_delta -= 0.05
			
		rolling_delta += delta
	else:
		pass

func packet_received(net_packet:NetPacket):
	if(!StarDustNet.is_server()):
		if(net_packet.type == PositionUpdate2D.TYPE_UPDATE_POSITION_2D):
			var pos_dat = PositionUpdate2D.map_data(net_packet.data)
			
			var pos = Vector2(pos_dat.position_x, pos_dat.position_y)
			var rot = pos_dat.rotation
			if(instance_id == instance_id):
				if(last_update != null):
					var new_pos = Vector2(pos_dat.position_x, pos_dat.position_y)
					var last_pos = Vector2(last_update.position_x, last_update.position_y)
					var last_rot = last_update.rotation
					pos = last_pos.lerp(new_pos, 0.016)
					rot = lerp_angle(last_rot, pos_dat.rotation, 0.016)
					
				set_position(pos)
				set_rotation(rot)
				last_update = pos_dat
	#client stuff
	else:
		pass


func dispose_instance():
	StarDustNet.remove_subscription_by_id(instance_id)
	queue_free()
