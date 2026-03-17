extends SDN_NetData

class_name InstanceData

var instance_id = 0
var scene_resource_path = ""
var scene_tree_path = ""
var owner_id = 0


func set_values(instance_id:int, scene_resource_path:String, scene_tree_path:String, owner_id:int = 0):
	self.instance_id = instance_id
	self.scene_resource_path = scene_resource_path
	self.scene_tree_path = scene_tree_path
	self.owner_id = owner_id
	return self

static func map_data(data:Dictionary):
	var id = InstanceData.new()
	id.instance_id = data[SDN_TypeCodes.INSTANCE_ID_CODE]
	id.scene_resource_path = data[SDN_TypeCodes.SCENE_RESOURCE_PATH_CODE]
	id.scene_tree_path = data[SDN_TypeCodes.SCENE_TREE_PATH_CODE]
	id.owner_id = data[SDN_TypeCodes.OWNER_ID_CODE]
	return id


func get_as_data()->Dictionary:
	var dat = {
			SDN_TypeCodes.INSTANCE_ID_CODE:instance_id, 
			SDN_TypeCodes.SCENE_RESOURCE_PATH_CODE: scene_resource_path,
			SDN_TypeCodes.SCENE_TREE_PATH_CODE: scene_tree_path,
			SDN_TypeCodes.OWNER_ID_CODE : owner_id
			}
	return dat
