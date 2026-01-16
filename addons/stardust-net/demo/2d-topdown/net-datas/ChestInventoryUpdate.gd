extends SDN_NetData

class_name ChestInventoryUpdate

var inventory = []

func _init():
	pass


static func map_data(data:Dictionary):
	return ChestInventoryUpdate.new()


func get_as_data()->Dictionary:
	return {}
