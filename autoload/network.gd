extends Node
#class_name Network

var peer = ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AL_Signalbus.host_server_created.connect(_on_host_server_created)
	AL_Signalbus._do_server_create.connect(_on_do_server_create)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

#####
# Server
#####
func player_joined(id):
	print("main::player_joined() [202] -> Player_Joined() : " + str(id))
	pass
#####
# Client
#####
#####

#####
# Game
#####
@rpc("authority")
#@rpc("call_local", "any_peer")
func add_player(id, team):
	var player_instance = AL_Globals.player.instantiate()
	player_instance.name = str(id)
	if multiplayer.is_server():
		player_instance.get_node("ReferenceRect/PlayerName").text += " - HOST"
#	player_instance.team = team

#	var pname = player_instance.get_node("ReferenceRect/PlayerName").text

	match team:
		"blue":
			player_instance.team = Color.DODGER_BLUE
			player_instance.global_position = %SpawnPosition/Blue.global_position

			AL_Globals.playernode.add_child(player_instance)
#			player_instance.get_node("ReferenceRect/TeamColor").color = Color.DODGER_BLUE
		"red":
			player_instance.team = Color.ORANGE_RED
			player_instance.global_position = %SpawnPosition/Red.global_position

			AL_Globals.playernode.add_child(player_instance)
#			%SpawnPosition/Red.add_child(player_instance)
#			player_instance.get_node("ReferenceRect/TeamColor").color = Color.ORANGE_RED
		"host":

			player_instance.team = Color.SEA_GREEN
			player_instance.global_position = %SpawnPosition/Host.global_position

			AL_Globals.playernode.add_child(player_instance)
#			%SpawnPosition/Host.add_child(player_instance)

#	if multiplayer.has_multiplayer_peer() and multiplayer.get_peers().has(id):
#		_on_server_display_players_connected(team)
		# "User {} is {}.".format([42, "Godot"], "{}")
#		send_message.rpc(str(id), " ({} / {}) has joined the game".format([pname, team.capitalize()], "{}"), false)


@rpc("authority")
func remove_player(id):

	var pnode = %PlayersConnectedListTeamBlue.get_node_or_null(str(id))
	if pnode != null:
		pnode.queue_free()
		var _player = AL_Signalbus.playernode.get_node_or_null(str(id))
#		var pname = _player.get_node("ReferenceRect/PlayerName").text
		_player.queue_free()
#		send_message.rpc(str(id), " ({} / {}) has leave the game".format([pname, "Blue".capitalize()], "{}"), false)
	else:
		pnode = %PlayersConnectedListTeamRed.get_node_or_null(str(id))
		if (pnode != null):
			pnode.queue_free()
			var _player = AL_Signalbus.playernode.get_node_or_null(str(id))
#			var pname = _player.get_node("ReferenceRect/PlayerName").text
#			send_message.rpc(str(id), " ({} / {}) has leave the game".format([pname, "Red".capitalize()], "{}"), false)
			_player.queue_free()
	# send_message.rpc(str(id), " left the game", false)


#@rpc("call_local")
@rpc("authority", "call_local")
func load_game():
#	%Menu.hide()

#	$Control/Lobby.visible = !multiplayer.is_server()
	print(str("load_game() -> Authority: %d" % [AL_Globals.mapnode.get_multiplayer_authority()]))
	if multiplayer.is_server():
		var map_instance = AL_Globals.map.instantiate()
		AL_Globals.mapnode.add_child(map_instance)

#		display_players_connected(%PlayersConnectedListTeamBlue)
#		%Scoreboard.show()



#####
# Signals
#####
func _on_host_server_created() -> void:
#	add_player.rpc_id(1, multiplayer.multiplayer_peer.generate_unique_id(), "host")
	var _err = rpc_id(1,"load_game")
	if _err:
		print(error_string(_err))


func _on_do_server_create():
	if peer.create_server(21277) != OK:
		print("Create Server failed !")
		return

	multiplayer.multiplayer_peer = peer

	multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.peer_connected.connect(player_joined)
	print("Create Server success !")

	AL_Signalbus.host_server_created.emit()
	pass


func _on_do_client_create():
	peer.create_client("localhost", 21277)
	multiplayer.multiplayer_peer = peer

	if %Username.text == "":
		%Username.text = "Player" + str(multiplayer.get_unique_id())

	if multiplayer.server_disconnected.is_connected(server_offline):
		multiplayer.server_disconnected.disconnect(server_offline)
		multiplayer.server_disconnected.connect(server_offline)

	if multiplayer.connected_to_server.is_connected(server_connected):
		multiplayer.connected_to_server.disconnect(server_connected)
		multiplayer.connected_to_server.connect(server_connected)

#	load_game()


func server_connected():
	print("Client::server_connected() -> Connection to Server success !")
	pass


func server_offline():
	# Per Signal
	print("Client::server_offline() -> Connection to Server lost !")
#	quit_game()
	pass
#####
