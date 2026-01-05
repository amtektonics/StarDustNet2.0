extends Node


func _ready():
	StarDustNet.subscribe_to_packet(self, "INPUT")
