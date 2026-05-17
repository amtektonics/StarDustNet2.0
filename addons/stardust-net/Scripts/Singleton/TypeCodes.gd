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


# SDFPSNetData
static var TYPE_SDFPS_DATA = "sdf"


# PlayerState
static var TYPE_PLAYER_STATE = 'pys'


#This is for values inside of those data structures to minimize retyping of
#data in dictionaries 

static var TICK_CODE = "tik"
static var NET_ID_CODE = "pid"

# add node type codes after this-----------------------

#Player Data
static var NAME_CODE = "nm"
static var VALUE_CODE = "vl"
static var TARGET_PLAYER_ID_CODE = "tid"


static var TYPE_PLAYER_PARAMETERS = "ppa"

static var TYPE_INVENTORY_UPDATE = "inv"

static var TYPE_PLAYER_EQUIPMENT_UPDATE = "peu"

static var TYPE_FLINT_KNAPPING_UPDATE = "fku"

static var TYPE_PLAYER_BLOCK_PLACER = "pbl"

static var TYPE_PLAYER_BLOCK_ROTATION = "pbr"

static var TYPE_ACTOR_ANIMATION = "aam"

static var TYPE_WORLD_CHUNK_UPDATE = "wcu"

static var TYPE_RESOURCE_DAMAGE_NODE = "rdn"

static var TYPE_RIGIDBODY_CONTROL = "rbd"

static var TYPE_TOOL_TIP= "ttp"

static var TYPE_CRAFTING_CONTROL = "ccp"

static var TYPE_CONSTRUCTION_DATA = "ccd"

static var TYPE_HARVEST = "hvt"

static var TYPE_FACILITY_MENU = "fme"

static var TYPE_PULVERIZER_BOWL = "pvb"

static var TYPE_BLOCK_ANIMATION = "bam"

static var TYPE_WORKBENCH_UPDATE = "wbu"

static var TYPE_MENU_UPDATE = "mnu"

#Instance TypeCodes---------------------------------------
static var INSTANCE_ID_CODE = "iid"
static var SCENE_RESOURCE_PATH_CODE = "srp"
static var SCENE_TREE_PATH_CODE = "stp"
static var SPAWN_INFO_CODE = "sf"
static var OWNER_ID_CODE = "oid"


# add new codes after this-------------------------------
static var POSITION_X_CODE = "pox"
static var POSITION_Y_CODE = "poy"
static var POSITION_Z_CODE = "poz"
static var HEAD_ROTATION_CODE = "r"
static var HEAD_TILT_CODE = "t"


# PlayerState
static var PREV_STATE_CODE = "pst"
static var NEW_STATE_CODE = "nst"
