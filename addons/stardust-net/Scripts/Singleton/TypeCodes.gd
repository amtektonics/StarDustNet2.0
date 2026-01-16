extends Node

#this is for packet messages to indicate what you are calling
#and should be uniqie 
static var TYPE_NONE = "non"
static var TYPE_PING = "png"
static var TYPE_INPUT = "inp"

#PlayerData
static var TYPE_PLAYER_DATA = "pdt"
static var TYPE_STATE_UPDATE ="stu"


#InstanceData
static var TYPE_CREATE_INSTANCE = "cri"
static var TYPE_REMOVE_INSTANCE = "rmi"


#This is for values inside of those data structures to minimize retyping of
#data in dictionaries 

#Player Data
static var NAME_CODE = "nm"
static var VALUE_CODE = "vl"
static var TARGET_PLAYER_ID_CODE = "tid"

#Instance TypeCodes
static var INSTANCE_ID_CODE = "iid"
static var SCENE_RESOURCE_PATH_CODE = "srp"
static var SCENE_TREE_PATH_CODE = "stp"
