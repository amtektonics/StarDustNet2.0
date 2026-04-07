extends Node

var _instance_id_counter = 1
var _instance_nodes = {}
var _instance_data = {}

func _ready():
	StarDustNet.subscribe_to_packet(self, SDN_TypeCodes.TYPE_CREATE_INSTANCE)
	StarDustNet.subscribe_to_packet(self, SDN_TypeCodes.TYPE_REMOVE_INSTANCE)
	StarDustNet.player_connected.connect(_player_connected)


func create_local_instance(instance_id:int, res_path:String, tree_path:String, spawn_info = {}, owner_id = 0):
	var scene = load(res_path)
	var instance:Node = scene.instantiate()
	if(instance.has_method("set_instance_id")):
		instance.set_instance_id(instance_id)
	else:
		assert("Instance " + str(instance_id) + " at path " + tree_path + " is missing set_instance_id")
	
	
	if(instance.has_method("handle_spawn_info")):
		instance.handle_spawn_info(spawn_info)
	else:
		push_warning(str(instance) + " Is missing the method handle_spawn_info")
	get_node(NodePath(tree_path)).add_child(instance)
	_instance_nodes[instance_id] = instance
	_instance_data[instance_id] = InstanceData.new().set_values(instance_id, res_path, tree_path, spawn_info, owner_id)

func create_net_instance(res_path:String, tree_path:String, spawn_info={}, owner_id = 0):
	if(StarDustNet.is_server()):
		var id = _instance_id_counter
		_instance_id_counter = _instance_id_counter + 1
		var inst_dat:InstanceData = InstanceData.new()
		inst_dat.set_values(id, res_path, tree_path, spawn_info, owner_id)
		var np:NetPacket = NetPacket.new(SDN_TypeCodes.TYPE_CREATE_INSTANCE, inst_dat.get_as_data())
		StarDustNet.send_packet_reliable(np)
		
		#TODO - add some code here that checks to see if the server is headless
		create_local_instance(inst_dat.instance_id, inst_dat.scene_resource_path, inst_dat.scene_tree_path, spawn_info, owner_id)
		return id

func remove_local_instance(instance_id:int):
	if(_instance_nodes.has(instance_id)):
		var node:Node = _instance_nodes[instance_id]
		if(node.has_method("dispose_instance")):
			node.dispose_instance()
			_instance_nodes.erase(instance_id)
			_instance_data.erase(instance_id)
		else:
			assert("Instance node missing dispose_instance | instance_id: " + str(instance_id) + " path: " + str(node.get_path()))

func remove_net_instance(instance_id:int):
	if(StarDustNet.is_server()):
		if(_instance_nodes.has(instance_id)):
			var inst_dat:InstanceData = InstanceData.new()
			inst_dat.set_values(instance_id, "", "")
			var np = NetPacket.new(SDN_TypeCodes.TYPE_REMOVE_INSTANCE, inst_dat.get_as_data())
			StarDustNet.send_packet_reliable(np)
			
		#TODO - add some code here that checks to see if the server is headless
		remove_local_instance(instance_id)

func get_instance_node(instance_id:int):
	if(_instance_nodes.has(instance_id)):
		return _instance_nodes[instance_id]
	else:
		return null

func update_spawn_info(instance_id:int):
	if(StarDustNet.is_server()):
		var instance = get_instance_node(instance_id)
		if(instance.has_method("update_spawn_info")):
			var dat = instance.update_spawn_info()
			var instance_dat:InstanceData = _instance_data[instance_id]
			instance_dat.spawn_info = dat
			
		else:
			push_warning(str(instance) + " missing method update_spawn_info")

func get_instance_owner(instance_id:int):
	return _instance_data[instance_id].owner_id

func get_owner_instance(owner_id:int) -> int:
	for i in _instance_data:
		if(_instance_data[i].owner_id == owner_id):
			return i
	return -1

func sync_instances(player_id:int):
	if(StarDustNet.is_server()):
		_instance_data.sort()
		for i in _instance_data:
			update_spawn_info(i)
			var inst:InstanceData = _instance_data[i]
			var np:NetPacket = NetPacket.new(SDN_TypeCodes.TYPE_CREATE_INSTANCE, inst.get_as_data(), [player_id])
			StarDustNet.send_packet_reliable(np)

func packet_received(packet:NetPacket):
	if(!StarDustNet.is_server()):
		if(packet.type == SDN_TypeCodes.TYPE_CREATE_INSTANCE):
			var inst_dat = InstanceData.map_data(packet.data)
			create_local_instance(inst_dat.instance_id, inst_dat.scene_resource_path, inst_dat.scene_tree_path, inst_dat.spawn_info, inst_dat.owner_id)
		if(packet.type == SDN_TypeCodes.TYPE_REMOVE_INSTANCE):
			var inst_dat = InstanceData.map_data(packet.data)
			remove_local_instance(inst_dat.instance_id)

func get_owned_instances():
	var instances = []
	for i in _instance_data:
		var data:InstanceData =  _instance_data[i]
		if(data.owner_id != 0):
			instances.append(i)
	return instances

func get_instance_distance_position_3d(instance_id:int, position:Vector3):
	var instance = get_instance_node(instance_id)
	if(instance == null):
		push_warning("instances is null " + str(instance))
		return -1
	
	if(instance is Node3D):
		var instance_pos = instance.get_global_position()
		return position.distance_to(instance_pos)
		
	else:
		push_warning("Instance is not a 3D node " + str(instance))
		return -1


func get_instance_distance_position_2d(instance_id:int, position:Vector2):
	var instance = get_instance_node(instance_id)
	if(instance == null):
		push_warning("instances is null " + str(instance))
		return -1
	
	if(instance is Node2D):
		var instance_pos = instance.get_global_position()
		return position.distance_to(instance_pos)
		
	else:
		push_warning("Instance is not a 2D node " + str(instance))
		return -1


func get_distance_3d(first_id:int, second_id:int):
	var first = get_instance_node(first_id)
	var second = get_instance_node(second_id)
	if(first == null || second == null):
		push_warning("One of the instances is null " + str(first) + " | " + str(second))
		return -1
	
	if (first is Node3D && second is Node3D):
		return first.get_global_position().distance_to(second.get_global_position())
	else:
		push_warning("one or more node is not a 3D node " + str(first) + " | " + str(second))
		return -1

func get_distance_2d(first_id:int, second_id:int):
	var first = get_instance_node(first_id)
	var second = get_instance_node(second_id)
	if(first == null || second == null):
		push_warning("One of the instances is null " + str(first) + " | " + str(second))
		return -1
	
	if (first is Node2D && second is Node2D):
		return first.get_global_position().distance_to(second.get_global_position())
	else:
		push_warning("one or more node is not a 3D node " + str(first) + " | " + str(second))
		return -1

func _player_connected(id:int):
	sync_instances(id)
