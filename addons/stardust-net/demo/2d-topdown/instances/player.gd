extends CharacterBody2D

var instance_id = 0
var game_world:GameWorld

var _last_update:PositionUpdate2D
var _last_packet:NetPacket

var movement_dir:Vector2


@onready var _message_limiter = SDN_Utils.SDN_MessageLimiter.new(20, _limited_node_update)

func _ready():
	SDN_PlayerDataManager.property_updated.connect(_player_property_updated)

func set_instance_id(id:int):
	instance_id = id
	if(!StarDustNet.is_server()):
		StarDustNet.subscribe_to_packet(self, PositionUpdate2D.TYPE_UPDATE_POSITION_2D, {PositionUpdate2D.INSTANCE_ID_CODE:instance_id})
	
func _player_property_updated(name:String, target_player:int, value):
	if(name == SDN_TypeCodes.INSTANCE_ID_CODE):
		if(target_player == StarDustNet.get_net_id() && int(value) == instance_id):
			$Camera.enabled = true

#added this call to the game world node to allow all the starting information
#to get setup before we start working with it
func late_server_init():
	var local_instance = game_world.get_local_player_instance()
	if(local_instance != instance_id):
		$Camera.enabled = false


func _physics_process(delta: float) -> void:
	_message_limiter.process(delta)
	
	
	if(StarDustNet.is_server()):
		_simulate_movement(delta)
	else:
		var local_instance = get_parent().get_local_player_instance()
		if(local_instance == instance_id):
			_simulate_movement(delta)


	
	
	
	if(!StarDustNet.is_server()):
		if(_last_packet != null):
			var new_pos = Vector2(global_position.x, global_position.y)
			var last_pos = Vector2(_last_update.position_x, _last_update.position_y)
			
			var last_rot = _last_update.rotation
			var pos = SDN_Utils.compensate_lag_vec2(last_pos, new_pos)
			var rot = SDN_Utils.compensate_lag_angle_float(last_rot, global_rotation)
			
			set_position(pos)
			set_rotation(rot)
	
	

func _simulate_movement(delta):
	velocity = velocity.move_toward(Vector2.ZERO, 0.5)
	velocity += movement_dir * 1.0 * 100 * delta
	move_and_slide()

func _limited_node_update(delta:float):
	if(StarDustNet.is_server()):
		var players = game_world.get_nearby_players_net_id(instance_id, 10000)
		
		var pos_dat:PositionUpdate2D = PositionUpdate2D.new(instance_id,\
		get_global_position().x,\
		get_global_position().y,\
		get_global_rotation())
		
		for pid in players:
			var np = NetPacket.new(PositionUpdate2D.TYPE_UPDATE_POSITION_2D,\
			pos_dat.get_as_data(),\
			pid)
			StarDustNet.send_packet_unreliable(np)
	else:
		var mov = Input.get_vector("left","right","up", "down")
		var np = NetPacket.new(InputData.TYPE_INPUT, InputData.new(mov).get_as_data(), 1)
		
		var local_instance = get_parent().get_local_player_instance()
		if(local_instance != instance_id):
			movement_dir = mov
		StarDustNet.send_packet_unreliable(np)

func packet_received(net_packet:NetPacket):
	if(!StarDustNet.is_server()):
		if(net_packet.type == PositionUpdate2D.TYPE_UPDATE_POSITION_2D):
			var pos_dat = PositionUpdate2D.map_data(net_packet.data)
			if(instance_id == instance_id):
				_last_update = pos_dat
				_last_packet = net_packet


func dispose_instance():
	StarDustNet.remove_subscription_by_id(instance_id)
	queue_free()
