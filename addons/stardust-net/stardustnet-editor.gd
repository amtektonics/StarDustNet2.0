@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("StarDustNet", "res://addons/stardust-net/StarDustNet.gd")
	add_autoload_singleton("SDN_InstanceManager", "res://addons/stardust-net/Scripts/Singleton/InstanceManager.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("StarDustNet")
	remove_autoload_singleton("SDN_InstanceManager")
