extends CharacterBody2D

@export var team : Color
var multiplayerauthority : int = -1
var player_is_server: bool = false


func _ready():
	if get_multiplayer_authority() == multiplayerauthority:
		player_is_server = multiplayer.is_server()
		%Authority.visible = true
	pass


func _physics_process(_delta):
	if get_multiplayer_authority() != multiplayerauthority: return
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * 500
	move_and_slide()


#func _spawn_custom() -> void:
#	pass


func _on_tree_entered():
	$ReferenceRect/TeamColor.color = team
	set_multiplayer_authority(str(name).to_int())
	multiplayerauthority = str(name).to_int()

