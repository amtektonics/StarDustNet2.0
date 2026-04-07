extends CharacterBody3D

class_name SDFPSNetBody3D
##this is a very basic extensable 3d player movement object for First Person Games 
##with basic look movement that works automatically in StarDustNet Multiplayer system


@export var Camera:Camera3D

#TODO add collision mask information

var _camera_active : bool = true

var instance_id:int = 0

# var movement_sync_node:SDFPSMoveSyncNode

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _no_clip:bool = false

var _gravity_enabled: = true

##this is where the peer id is stored when the entity is created
##if this is being used for a NPC you can just set the id to 0
var owner_id:int = 0

var _input_vec:Vector2 = Vector2.ZERO

var _input_rot:float = 0.0

var _input_tilt:float = 0.0

var _input_updated:bool = false

var _run:bool = false

var _jump:bool = false

var _crouch: bool = false

var _use:bool = false

var _use_input_edge:bool = false

var _secondary:bool = false

var _secondary_input_edge:bool = false

var _primary:bool = false

var _primary_input_edge:bool = false

var _switch:bool = false

var _switch_input_edge : bool = false

var _drop:bool = false

var _drop_input_edge : bool = false

var _cycle_direction : int = 0

var _hotbar_selection  :  int = 0

var _hotbar_changed =  false

var _hotbar_locked = false

var _build : bool = false

var _build_input_edge :  bool = false

var _building_rotate = 0

var _building_rotate_edge = false

var _snap : bool =  false

var _snap_input_edge = false

var _sub_id_SDFPS = -1

var _message_limiter = SDN_Utils.SDN_MessageLimiter.new(30, _limited_update)


func _ready():
	if(Camera == null):
		assert("The Camera Node needs to be set")
	
	#enable the camera if you you the the local entity
	if(StarDustNet.get_net_id() == owner_id):
		Camera.current = true
	else:
		Camera.current = false

	

func set_input_move_vector(input_vec:Vector2):
	_input_vec = input_vec

func set_input_rotate(new_rotation:float):
	_input_rot = new_rotation

func set_input_tilt(tilt:float):
	_input_tilt = tilt

func set_input_run(value:bool):
	_run  = value

func set_input_jump(value:bool):
	_jump = value

func set_input_crouch(value:bool):
	_crouch = value

func set_input_use(value:bool):
	_use = value


func set_primary_action(value:bool):
	_primary = value


func set_secondary_action(value:bool): 
	_secondary = value


func set_switch_action(value:bool):
	_switch = value


func set_drop_action(value:bool):
	_drop = value


func set_snap_action(value : bool):
	_snap = value


func set_cycle_direction(new_cycle_direction : int):
	_cycle_direction = new_cycle_direction


func _unhandled_input(event):
	if(multiplayer.get_unique_id() == owner_id):
		if  event.is_action_pressed("run"):
			set_input_run(true)
		elif event.is_action_released("run"):
			set_input_run(false)
		
		elif event.is_action_pressed("jump"):
			set_input_jump(true)
		elif event.is_action_released("jump"):
			set_input_jump(false)
		
		elif (event.is_action_pressed("crouch")):
			set_input_crouch(true)
		elif event.is_action_released("crouch"):
			set_input_crouch(false)
		
		elif(event.is_action_pressed("Use")):
			set_input_use(true)
		elif event.is_action_released("Use"):
			set_input_use(false)
		
		elif(event.is_action_pressed("Primary")):
			set_primary_action(true)
		elif event.is_action_released("Primary"):
			set_primary_action(false)
		
		elif event.is_action_pressed("Secondary"):
			set_secondary_action(true)
		elif event.is_action_released("Secondary"):
			set_secondary_action(false)
		
		elif event.is_action_pressed("Switch"):
			set_switch_action(true)
		elif event.is_action_released("Switch"):
			set_switch_action(false)
		
		elif event.is_action_pressed("Drop"):
			set_drop_action(true)
		elif event.is_action_released("Drop"):
			set_drop_action(false)
		
		elif event.is_action_pressed("building_toggle_snap"):
			set_snap_action(true)
		elif event.is_action_released("building_toggle_snap"):
			set_snap_action(false)
		
		elif event.is_action_pressed("Hotbar1"):
			_hotbar_selection = 0
			_hotbar_changed =  true
		elif event.is_action_pressed("Hotbar2"):
			_hotbar_selection = 1
			_hotbar_changed = true
		elif event.is_action_pressed("Hotbar3"):
			_hotbar_selection = 2
			_hotbar_changed = true
		elif event.is_action_pressed("Hotbar4"):
			_hotbar_selection = 3
			_hotbar_changed = true
		elif event.is_action_pressed("Hotbar5"):
			_hotbar_selection = 4
			_hotbar_changed = true
		elif event.is_action_pressed("Hotbar6"):
			_hotbar_selection = 5
			_hotbar_changed  = true
		elif event.is_action_pressed("Hotbar7"):
			_hotbar_selection = 6
			_hotbar_changed = true
		elif event.is_action_pressed("Hotbar8"):
			_hotbar_selection = 7
			_hotbar_changed = true
		elif event.is_action_pressed("Hotbar9"):
			_hotbar_selection = 8
			_hotbar_changed = true
		elif event.is_action_pressed("Hotbar0"):
			_hotbar_selection = 9
			_hotbar_changed = true
		
		if !_hotbar_locked:
			if event.is_action_pressed("CycleUp"):
				_hotbar_changed = true
				_hotbar_selection -= 1
				if _hotbar_selection < 0:
					_hotbar_selection = 9
				set_cycle_direction(1)
			elif event.is_action_pressed("CycleDown"):
				_hotbar_changed = true
				_hotbar_selection += 1
				if _hotbar_selection > 9:
					_hotbar_selection = 0
				set_cycle_direction(-1)
		
		if event.is_action_pressed("Build"):
			_build = true
		elif event.is_action_released("Build"):
			_build = false
		
		else: #Hotbar Locked
			if event.is_action_pressed("CycleUp"):
				set_cycle_direction(1)
			elif event.is_action_pressed("CycleDown"):
				set_cycle_direction(-1)

		if event.is_action_pressed("building_rotate_negative"):
			_building_rotate = -1
		elif event.is_action_pressed("building_rotate_positive"):
			_building_rotate = 1
		else:
			_building_rotate = 0
		
			#Local Only, these functions are NOT sent to the server *for now*
		if event.is_action_pressed("Inventory"):
			inventory_pressed()
		if event.is_action_pressed("menu_escape"):
			local_menu_escape_pressed()
		if multiplayer.is_server():
			if event.is_action_pressed("Debug"):
				debug_pressed()


func _physics_process(delta: float) -> void:
	if(StarDustNet.get_net_id() == owner_id): #Called by owner client
		var move = Input.get_vector("player_left","player_right","player_forward","player_back")
		var mouse = Input.get_last_mouse_velocity()
		
		if  Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			set_input_move_vector(move)
		else:
			set_input_move_vector(Vector2(0,0))
			
		#I don't think this is right
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and _camera_active:
			set_input_rotate(-mouse.x)
			set_input_tilt(-mouse.y)
		else:
			set_input_rotate(0.0)
			set_input_tilt(0.0)
			
		_message_limiter.process(delta)
		
	elif(multiplayer.is_server()): #Server but not server player
		var px =  StarDustNet.get_newest_input(owner_id, "px")
		var py =  StarDustNet.get_newest_input(owner_id, "py")
		var input_rot = StarDustNet.get_newest_input(owner_id, "mx")
		var input_tilt = StarDustNet.get_newest_input(owner_id, "my")
		var jump = StarDustNet.get_newest_input(owner_id, "j")
		var run = StarDustNet.get_newest_input(owner_id,"r")
		var crouch = StarDustNet.get_newest_input(owner_id, "c")
		var primary = StarDustNet.get_newest_input(owner_id, "pa")
		var secondary = StarDustNet.get_newest_input(owner_id, "sa")
		var use = StarDustNet.get_newest_input(owner_id, "ua")
		var switch = StarDustNet.get_newest_input(owner_id, "xa")
		var drop = StarDustNet.get_newest_input(owner_id, "qa")
		var build = StarDustNet.get_newest_input(owner_id, "b")
		var cycle_direction = StarDustNet.get_newest_input(owner_id, "cyc")
		var hb = StarDustNet.get_newest_input(owner_id, "hb")
		var rot = StarDustNet.get_newest_input(owner_id, "rot")
		var snap = StarDustNet.get_newest_input(owner_id, "snp")
		
		if (px != null && py != null): _input_vec = Vector2(px, py)
		if input_rot != null: _input_rot = input_rot
		if input_tilt != null: _input_tilt = input_tilt
		if run != null: _run = run
		if jump != null: _jump = jump
		if crouch != null: _crouch = crouch
		if primary != null: _primary = primary
		if secondary != null: _secondary = secondary
		
		if rot != null: _building_rotate = rot
		else: _building_rotate = 0
		
		if use != null: 
			_use = use
		else:
			_use = false
		
		if switch != null: 
			_switch = switch
		else:
			_switch =  false
		
		if drop != null:
			_drop = drop
		else:
			_drop = false
		
		if build != null:
			_build = build
		else:
			_build = false
		
		if snap != null:
			_snap = snap
		else:
			_snap = false
		
		if  cycle_direction != null: _cycle_direction = cycle_direction
		
		if hb != null: 
			if hb != _hotbar_selection:
				_hotbar_selection = hb
				_hotbar_changed =  true
		else: _hotbar_selection = 0

		#Edge Detection
		#I don't want to fuck with inputs outside of their own functions
	if multiplayer.is_server():
		if (_primary):
			if _primary_input_edge == false:
				_primary_action_just_pressed()
				_primary_input_edge = true
				#_primary_action_pressed() #I think both need to fire?
			else:
				_primary_action_pressed()
		elif (_primary_input_edge && !_primary):
			if _primary_input_edge:
				_primary_action_just_released()
				_primary_input_edge = false
		
		if (_secondary):
			if _secondary_input_edge == false:
				_secondary_input_edge = true
				_secondary_action_just_pressed()
				#_secondary_action_pressed()
				if multiplayer.get_unique_id() == owner_id:
					_local_secondary_action_just_pressed()
			else:
				_secondary_action_pressed()
				if multiplayer.get_unique_id() == owner_id:
					_local_secondary_action_pressed()
		elif _secondary_input_edge:
			_secondary_action_just_released()
			_secondary_input_edge = false
			if multiplayer.get_unique_id() == owner_id:
				_local_secondary_action_just_released()
		if(_use_input_edge == false && _use):
			_use_input_edge = true
			_use_just_pressed()
		elif (_use_input_edge && !_use):
			_use_input_edge = false
		
		if _drop_input_edge == false && _drop:
			_drop_input_edge = true
			_drop_just_pressed()
		elif (_drop_input_edge && !_drop):
			_drop_input_edge = false
		
		if _switch_input_edge == false && _switch:
			_switch_input_edge = true
			_switch_just_pressed()
		elif(_switch_input_edge && !_switch):
			_switch_input_edge = false
		
		if _build_input_edge == false && _build:
			_build_input_edge = true
			_build_just_pressed()
		elif(_build_input_edge && !_build):
			_build_input_edge = false
		
		if _snap_input_edge == false && _snap:
			_snap_input_edge = true
			_snap_just_pressed()
		elif(_snap_input_edge && ! _snap):
			_snap_input_edge = false
		
		if _cycle_direction != 0:
			if _cycle_direction == 1:
				cycle_up()
			elif _cycle_direction == -1:
				cycle_down()
			_cycle_direction = 0
		
		if _hotbar_changed:
			hotbar_selection(_hotbar_selection)
			_hotbar_changed = false
		
		if _building_rotate == 1:
			if !_building_rotate_edge:
				building_rotate_pos()
				_building_rotate_edge = true
		elif _building_rotate ==  -1:
			if !_building_rotate_edge:
				building_rotate_neg()
				_building_rotate_edge = true
		else:
			_building_rotate_edge = false 


func _limited_update(delta:float):
	if !multiplayer.is_server():
			#Any button that cares if it is held or not should be sent every frame
			#Any button that only cares about positive edge should ONLY be sent on the positive edge
		var input_data = {
				"px":_input_vec.x, 
				"py":_input_vec.y, 
				"r": _run,
				"j":_jump, 
				"c" :_crouch,
				"mx":_input_rot, 
				"my":_input_tilt,
				"pa":_primary,
				"sa":_secondary,
				"cyc": _cycle_direction,
				"ua" : _use,}
		if _use: 
				input_data["ua"] = _use
		if _switch:
				input_data["xa"] = _switch
		if _drop:
				input_data["qa"] = _drop
		if _build:
				input_data["b"] = _build
		if _snap:
				input_data["snp"] = _snap
			
		if _cycle_direction != 0:
				input_data["cyc"] = _cycle_direction
				_cycle_direction = 0
			
		if _hotbar_selection >= 0 :
				input_data ["hb"] = _hotbar_selection
			
		if _building_rotate != 0:
				input_data["rot"] =  _building_rotate
			
		StarDustNet.send_input(input_data)


# func _new_position(frame:SDFPSMoveSyncData):
# 	var new_pos = frame.position
# 	var new_rot = frame.rotation
# 	var new_tilt = frame.tilt
# 	var best_frame = null
# 	var ping = NetController.get_ping_average(owner_id)
# 	if(last_frame != null):
# 		var tick_diff = NetController.get_current_tick() - frame.frame_id
# 		new_pos = StarDustUtil.compensate_lag_Vector3(last_frame.position, frame.position, tick_diff)
# 		new_rot = StarDustUtil.compensate_lag_angle(last_frame.rotation, frame.rotation, tick_diff)
# 		new_tilt = StarDustUtil.compensate_lag_angle(last_frame.tilt, frame.tilt, tick_diff)
	
# 	set_position(new_pos)
# 	rotation.y = new_rot
# 	Camera.rotation.x = new_tilt
# 	last_frame = frame

var _last_SDFPSPacket:SDFPSNetData = null

func packet_received(net_packet:NetPacket):
	if(net_packet.type == SDN_TypeCodes.TYPE_SDFPS_DATA):
		var p = SDFPSNetData.map_data(net_packet.data)
		if(instance_id == p.instance_id):
			var new_pos = p.position
			var new_rot = p.rotation
			var new_tilt = p.tilt
			if(_last_SDFPSPacket != null):
				new_pos = SDN_Utils.compensate_lag_vec3(_last_SDFPSPacket.position, p.position)
				new_rot = SDN_Utils.compensate_lag_angle_float(_last_SDFPSPacket.rotation, p.rotation)
				new_tilt = SDN_Utils.compensate_lag_angle_float(_last_SDFPSPacket.tilt, p.tilt)
			
			set_position(new_pos)
			rotation.y = new_rot
			Camera.rotation.x = new_tilt
			_last_SDFPSPacket = p

func dispose_instance():
	if(_sub_id_SDFPS != -1):
		StarDustNet.remove_subscription_by_id(_sub_id_SDFPS)
	queue_free()


func set_instance_id(instance_id:int):
	self.instance_id = instance_id
	#if(!StarDustNet.is_server()):
	_sub_id_SDFPS = StarDustNet.subscribe_to_packet(self, SDN_TypeCodes.TYPE_SDFPS_DATA)

#overridable actions
func _primary_action_just_pressed():
	pass


func _primary_action_pressed():
	pass


func _primary_action_just_released():
	pass


func _secondary_action_just_pressed():
	pass


func _secondary_action_pressed():
	pass


func _local_secondary_action_pressed():
	pass


func _local_secondary_action_just_released():
	pass


func _local_secondary_action_just_pressed():
	pass


func _secondary_action_just_released():
	pass


func _use_just_pressed():
	pass


func _drop_just_pressed():
	pass


func _switch_just_pressed():
	pass


func _build_just_pressed():
	pass


func _snap_just_pressed():
	pass


func hotbar_selection(new_hb):
	pass


func cycle_up():
	pass


func cycle_down():
	pass


func building_rotate_pos():
	pass


func building_rotate_neg():
	pass


func building_mode_pressed():
	pass


#Menu actions
func inventory_pressed():
	pass


func local_menu_escape_pressed():
	pass


func debug_pressed():
	pass


func camera_active():
	return true

static func create_spawn_info(owner_id:int, position:Vector3, rotation:float, tilt:float):
	var data = {
 		"oid":owner_id,
 		"px":position.x,
 		"py":position.y,
 		"pz":position.z,
 		"r":rotation,
 		"tt":tilt
 	}
	return data


func update_spawn_info():
	var data = {
 		"oid":owner_id,
 		"px":get_global_position().x,
 		"py":get_global_position().y,
 		"pz":get_global_position().z,
 		"r":get_global_rotation().y,
 		"tt":Camera.get_global_rotation().x
 	}
	return data

func handle_spawn_info(data:Dictionary):
	if(data.has("oid")):
		owner_id = int(data["oid"])
		set_name(str(int(data["oid"])))
	if(data.has("px") && data.has("py") && data.has("pz")):
		set_position(Vector3(data["px"], data["py"], data["pz"]))
	if(data.has("r")):
		rotation.y = data["r"]
	if(data.has("tt")):
		Camera.rotation.x = data["tt"]

func remove_from_net():
	if(_sub_id_SDFPS != -1):
		StarDustNet.remove_subscription_by_id(_sub_id_SDFPS)
		SDN_InstanceManager.remove_net_instance(instance_id)
	
# 	FrameSyncController.remove_sync_node(movement_sync_node.sync_id)
# 	CreationController.remove_net_node(_res_id)
