@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("StarDustNet", "res://addons/stardust-net/StarDustNet.gd")
	add_autoload_singleton("SDN_InstanceManager", "res://addons/stardust-net/Scripts/Singleton/InstanceManager.gd")
	add_autoload_singleton("SDN_TypeCodes", "res://addons/stardust-net/Scripts/Singleton/TypeCodes.gd")
	add_autoload_singleton("SDN_PlayerDataManager", "res://addons/stardust-net/Scripts/Singleton/PlayerDataManager.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("StarDustNet")
	remove_autoload_singleton("SDN_InstanceManager")
	remove_autoload_singleton("SDN_TypeCodes")
	remove_autoload_singleton("SDN_PlayerDataManager")
	
