extends Node

var _instance_id_counter = 1
var _instance_nodes = {}
var _instance_data = {}

func _ready():
	StarDustNet.subscribe_to_packet(self, SDN_TypeCodes.TYPE_CREATE_INSTANCE)
	StarDustNet.subscribe_to_packet(self, SDN_TypeCodes.TYPE_REMOVE_INSTANCE)


func create_local_instance(instance_id:int, res_path:String, tree_path:String):
	var scene = load(res_path)
	var instance:Node = scene.instantiate()
	if(instance.has_method("set_instance_id")):
		instance.set_instance_id(instance_id)
	else:
		assert("Instance " + str(instance_id) + " at path " + tree_path + " is missing set_instance_id")
	
	get_node(NodePath(tree_path)).add_child(instance)
	_instance_nodes[instance_id] = instance
	_instance_data[instance_id] = InstanceData.new().set_values(instance_id, res_path, tree_path)

func create_net_instance(res_path:String, tree_path:String):
	if(StarDustNet.is_server()):
		var id = _instance_id_counter
		_instance_id_counter = _instance_id_counter + 1
		var inst_dat:InstanceData = InstanceData.new()
		inst_dat.set_values(id, res_path, tree_path)
		var np:NetPacket = NetPacket.new(SDN_TypeCodes.TYPE_CREATE_INSTANCE, inst_dat.get_as_data())
		StarDustNet.send_packet_reliable(np)
		
		#TODO - add some code here that checks to see if the server is headless
		create_local_instance(inst_dat.instance_id, inst_dat.scene_resource_path, inst_dat.scene_tree_path)
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

func sync_instances(player_id:int):
	if(StarDustNet.is_server()):
		for i in _instance_data:
			var inst:InstanceData = _instance_data[i]
			var np:NetPacket = NetPacket.new(SDN_TypeCodes.TYPE_CREATE_INSTANCE, inst.get_as_data(), player_id)
			StarDustNet.send_packet_reliable(np)

func packet_received(packet:NetPacket):
	if(!StarDustNet.is_server()):
		if(packet.type == SDN_TypeCodes.TYPE_CREATE_INSTANCE):
			var inst_dat = InstanceData.map_data(packet.data)
			create_local_instance(inst_dat.instance_id, inst_dat.scene_resource_path, inst_dat.scene_tree_path)
		if(packet.type == SDN_TypeCodes.TYPE_REMOVE_INSTANCE):
			var inst_dat = InstanceData.map_data(packet.data)
			remove_local_instance(inst_dat.instance_id)
