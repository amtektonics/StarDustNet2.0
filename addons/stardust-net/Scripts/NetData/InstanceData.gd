extends SDN_NetData

class_name InstanceData

static var TYPE_CREATE_INSTANCE = "cri"
static var TYPE_REMOVE_INSTANCE = "rmi"
#
static var INSTANCE_ID_CODE = "iid"
static var SCENE_RESOURCE_PATH_CODE = "srp"
static var SCENE_TREE_PATH_CODE = "stp"

var instance_id = 0
var scene_resource_path = ""
var scene_tree_path = ""



func set_values(instance_id:int, scene_resource_path:String, scene_tree_path:String):
	self.instance_id = instance_id
	self.scene_resource_path = scene_resource_path
	self.scene_tree_path = scene_tree_path
	return self

static func map_data(data:Dictionary):
	var id = InstanceData.new()
	id.instance_id = data[INSTANCE_ID_CODE]
	id.scene_resource_path = data[SCENE_RESOURCE_PATH_CODE]
	id.scene_tree_path = data[SCENE_TREE_PATH_CODE]
	return id


func get_as_data()->Dictionary:
	var dat = {
			INSTANCE_ID_CODE:instance_id, 
			SCENE_RESOURCE_PATH_CODE: scene_resource_path,
			SCENE_TREE_PATH_CODE: scene_tree_path
			}
	return dat

func serialize() -> String:
	var dat = {
			INSTANCE_ID_CODE:instance_id, 
			SCENE_RESOURCE_PATH_CODE: scene_resource_path,
			SCENE_TREE_PATH_CODE: scene_tree_path
			}
	return JSON.stringify(dat)
