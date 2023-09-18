extends CharacterBody2D

@export var team : Color

func _ready():
	pass

func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * 500
	move_and_slide()

func _spawn_custom() -> void:
	pass

func _on_tree_entered():
	$ReferenceRect/TeamColor.color = team
#	set_multiplayer_authority(str(name).to_int())

	print("str_name: %s / mp_uid: %d" % [str(name), multiplayer.get_unique_id()])
#	if str(name).to_int() == multiplayer.get_unique_id():
#		var mp_uid = multiplayer.get_unique_id()

	set_multiplayer_authority(str(name).to_int())

	%Authority.visible = is_multiplayer_authority()

	if not is_multiplayer_authority(): return
#	if team == "red":
#	else:
#		$ReferenceRect/TeamColor.color = team

#	%PlayerName.text = get_tree().get_first_node_in_group("player_name").text
#	%PlayerName.modulate = Color(0, 1, 0)
