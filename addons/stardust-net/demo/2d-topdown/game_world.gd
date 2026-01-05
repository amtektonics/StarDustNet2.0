extends Node2D

class_name GameWorld

var _pid_to_instance = {}

func _ready():
	StarDustNet.server_started.connect(_server_started)
	StarDustNet.player_connected.connect(_player_connected)
	StarDustNet.player_disconnected.connect(_player_disconnected)
	randomize()
	

func _physics_process(delta: float) -> void:
	pass
	

func get_nearby_players_net_id(instance_id:int, distance:float):
	var my_node = SDN_InstanceManager.get_instance_node(instance_id)
	var player_id_list = []
	for id in _pid_to_instance:
		var node = SDN_InstanceManager.get_instance_node(_pid_to_instance[id])
		if(node == null):
			continue
		if(node.get_global_position().distance_to(my_node.get_global_position()) <= distance):
			player_id_list.append(id)
	return player_id_list
#signals
func _server_started():
	for i in range(200):
		var instance_id = SDN_InstanceManager.create_net_instance("uid://ch4qe2f2h8pdh", str(get_path()))
		var ai_node = SDN_InstanceManager.get_instance_node(instance_id)
		ai_node.game_world = self
		var pos = Vector2(randf_range(-256, +256), randf_range(-256, +256))
		var rot = randf_range(0, PI * 2)
		ai_node.set_global_position(pos)
		ai_node.set_global_rotation(rot)
		ai_node.set_name("iid_" + str(instance_id))


func _player_connected(id:int):
	SDN_InstanceManager.sync_instances(id)
	var instance_id = SDN_InstanceManager.create_net_instance("uid://ch4qe2f2h8pdh", str(get_path()))
	_pid_to_instance[id] = instance_id
	
	#inital creation of node setup
	var player_node = SDN_InstanceManager.get_instance_node(instance_id)
	player_node.game_world = self
	var pos = Vector2(randf_range(-128, +128), randf_range(-128, +128))
	var rot = randf_range(0, PI * 2)
	player_node.set_global_position(pos)
	player_node.set_global_rotation(rot)
	player_node.set_name(str(id))

func _player_disconnected(id:int):
	SDN_InstanceManager.remove_net_instance(_pid_to_instance[id])
	_pid_to_instance.erase(id)


func _on_join_pressed() -> void:
	var addr = $CanvasLayer/ConnectionScreen/IP.text
	var port = int($CanvasLayer/ConnectionScreen/Port.text)
	if(StarDustNet.start_enet_client(addr, port) == OK):
		$CanvasLayer/ConnectionScreen.visible = false


func _on_host_pressed() -> void:
	var port = int($CanvasLayer/ConnectionScreen/Port.text)
	if(StarDustNet.start_enet_server(port) == OK):
		$CanvasLayer/ConnectionScreen.visible = false
