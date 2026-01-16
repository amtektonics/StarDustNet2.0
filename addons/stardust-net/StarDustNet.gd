extends Node



var _is_connected = false

var _tick = 0

var _connected_players = []

var _reliable_packets = []
var _unreliable_packets = []
#var _packets = []

var _subscriptions = {}
var _subscription_id = 1

signal server_started

signal server_disconnected

signal player_connected

signal player_disconnected

signal peer_closed

var platform = ""
var steam_api:Object = null

func _ready():
	if Engine.has_singleton("Steam"):
		platform = "steam"
		steam_api = Engine.get_singleton("Steam")
		var initalized = steam_api.steamInitEx(false)

func _physics_process(delta: float) -> void:
	if(_is_connected):
		_tick += 1
	
		if(is_server()):
			if(_tick % int((Engine.get_physics_ticks_per_second() * .125)) == 0):
				pass
		
		_process_reliable_packet_subscriptions()
		_process_unreliable_packet_subscriptions()
		
		if(is_steam_enabled()):
			steam_api.run_callbacks()



#it goes through the subscriptions and packets and sends them to the 
#endpoints that requested the data as a subscriber
func _process_reliable_packet_subscriptions():
	for p:NetPacket in _reliable_packets:
		if(p.processed):
			continue
		var is_in_subscription = false
		for s in _subscriptions:
			if(p.type == _subscriptions[s]["type"]):
				#basic no filter request
				if(_subscriptions[s]["filter"] == {}):
					var node:Node = _subscriptions[s]["sub"]
					if(node.has_method("packet_received")):
						node.packet_received(p)
						p.processed = true
					else:
						assert("your subscribed node at " + str(node.get_path()) + " is missing packet_recived function")
				#oh no they have a filter
				else:
					var filter = _subscriptions[s]["filter"]
					var filter_match = true
					for f in filter:
						if(p.data.has(f)):
							if(int(p.data[f]) != int(filter[f])):
								filter_match = false
						else:
							filter_match = false
						if(!filter_match): 
							return
					if(filter_match):
						var node:Node = _subscriptions[s]["sub"]
						if(node.has_method("packet_received")):
							node.packet_received(p)
							p.processed = true
						else:
							assert("your subscribed node at " + str(node.get_path()) + " is missing packet_recived function")
	
	var pop_index = 0
	for i in range(_reliable_packets.size()):
		if(!_reliable_packets[i].processed):
			return
		pop_index = pop_index + 1
	
	for j in range(pop_index-1):
		_reliable_packets.pop_front()

func _process_unreliable_packet_subscriptions():
	for p:NetPacket in _unreliable_packets:
		if(p.processed):
			continue
		var is_in_subscription = false
		for s in _subscriptions:
			if(p.type == _subscriptions[s]["type"]):
				#basic no filter request
				if(_subscriptions[s]["filter"] == {}):
					var node:Node = _subscriptions[s]["sub"]
					if(node.has_method("packet_received")):
						node.packet_received(p)
						p.processed = true
					else:
						assert("your subscribed node at " + str(node.get_path()) + " is missing packet_recived function")
				#oh no they have a filter
				else:
					var filter = _subscriptions[s]["filter"]
					var filter_match = true
					for f in filter:
						if(p.data.has(f)):
							if((p.data[f] != filter[f]) && (int(p.data[f]) != int(filter[f]))):
								filter_match = false
						else:
							return
					if(filter_match):
						var node:Node = _subscriptions[s]["sub"]
						if(node.has_method("packet_received")):
							node.packet_received(p)
							p.processed = true
						else:
							assert("your subscribed node at " + str(node.get_path()) + " is missing packet_recived function")
	
	var pop_index = 0
	for i in range(_unreliable_packets.size()):
		if(!_unreliable_packets[i].processed):
			return
		pop_index = pop_index + 1
	
	for j in range(pop_index-1):
		_unreliable_packets.pop_front()



func start_enet_server(port:int)-> int:
	var _multiplayer_peer = ENetMultiplayerPeer.new()
	var status = _multiplayer_peer.create_server(port)
	if(status == OK):
		multiplayer.multiplayer_peer = _multiplayer_peer
		_is_connected = true
		_register_enet_server_signals()
		emit_signal("server_started")
	return status

func _register_enet_server_signals():
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)

func _disconnect_enet_server_signals():
	multiplayer.peer_connected.disconnect(_peer_connected)
	multiplayer.peer_disconnected.disconnect(_peer_disconnected)

func _peer_connected(id:int):
	_connected_players.append(id)
	emit_signal("player_connected", id)

func _peer_disconnected(id:int):
	if(_connected_players.has(id)):
		_connected_players.erase(id)
		emit_signal("player_disconnected", id)

func start_enet_client(ip_address:String, port:int)->int:
	var _multplayer_peer = ENetMultiplayerPeer.new()
	var status = _multplayer_peer.create_client(ip_address, port)
	if(status == OK):
		multiplayer.multiplayer_peer = _multplayer_peer
		_register_enet_client_signals()
		_is_connected = true
		SDN_PlayerDataManager.init_manager()
	return status

func _register_enet_client_signals():
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)

func _disconnect_enet_client_signals():
	multiplayer.connected_to_server.disconnect(_connected_to_server)
	multiplayer.connection_failed.disconnect(_connection_failed)
	multiplayer.server_disconnected.disconnect(_server_disconnected)

func close_enet_peer():
	_connected_players.clear()
	
	if(self.is_net_connected()):
		if(self.is_server()):
			_disconnect_enet_server_signals()
		else:
			_disconnect_enet_client_signals()
		
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null

func _connected_to_server():
	emit_signal("connected_to_server")

func _connection_failed():
	pass

func _server_disconnected():
	emit_signal("server_disconnected")

#----------------------------------------------
#subscription system
##subscribing nodes need to add the packet_received(np:NetPacket) method
func subscribe_to_packet(subscriber: Node, type:String, filter:Dictionary={}) -> int:
	var id = _subscription_id
	_subscriptions[id] = { "sub":subscriber, "type":type, "filter":filter}
	_subscription_id = _subscription_id + 1
	return id

func remove_subscription_by_id(id:int):
	if(_subscriptions.has(id)):
		_subscriptions.erase(id)

func remove_all_subscription(subscriber:Node):
	var ids = []
	for sid in _subscriptions:
		if(_subscriptions[sid]["sub"] == subscriber):
			ids.append(sid)
	
	for id in ids:
		_subscriptions.erase(id)
#----------------------------------------------



func send_packet_reliable(packet:NetPacket):
	var dt = packet.serialize()
	if(packet.receiver_id == 0):
		rpc("_packet_received_reliable", dt)
	else:
		rpc_id(packet.receiver_id, "_packet_received_reliable", dt)

@rpc("any_peer", "reliable", "call_remote")
func _packet_received_reliable(data:String):
	var np = NetPacket.deserialize(data)
	_reliable_packets.append(np)

func send_packet_unreliable(packet:NetPacket):
	var dt = packet.serialize()
	if(packet.receiver_id == 0):
		rpc("_packet_received_unreliable", dt)
	else:
		rpc_id(packet.receiver_id, "_packet_received_unreliable", dt)

@rpc("any_peer", "unreliable", "call_remote")
func _packet_received_unreliable(data:String):
	var np = NetPacket.deserialize(data)
	_unreliable_packets.append(np)

#helper functions
func is_net_connected():
	return _is_connected

func is_server():
	return multiplayer.is_server()

func get_tick():
	return _tick

func get_player_net_id():
	return multiplayer.get_unique_id()

func get_net_id():
	return multiplayer.get_unique_id()

func is_steam_enabled():
	if(platform == "steam" && steam_api != null):
		return true
	return false

static func get_server_id():
	return 1
