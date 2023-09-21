extends Node
#class_name Network

var peer = ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AL_Signalbus.host_server_created.connect(_on_host_server_created)
	AL_Signalbus.local_client_created.connect(_on_local_client_created)
	AL_Signalbus._do_server_create.connect(_on_do_server_create)
	AL_Signalbus._do_server_remove_client.connect(_on_do_server_remove_client)
	AL_Signalbus._do_client_create.connect(_on_do_client_create)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

#####
# Server
#####
## Show Message when client connected
# ToDo: Rename Func, _on_XX_server_XXXX
func player_joined(id):
	print("main::player_joined() [202] -> Player_Joined() : " + str(id))
	pass
#####
# Client
#####
## Called from Client to server. To Create client network instance (Character)
@rpc("call_local", "any_peer")
# ToDo: Rename Func, _on_do_client_XXXX
func add_client_player(id, team : String):
	print("Server: {0} / Id: {1}".format([str(multiplayer.is_server()), str(id)]))
	if multiplayer.is_server():
		# ToDo: Call per Siganl at Host ?
		add_player.rpc_id(1, id, team)
	pass
#####

#####
# Game
#####
## Callöed locally on Server to create client Network Node
## Synced to Client with MultiplayerSpawner Node
@rpc("authority", "call_local")
# ToDo: Rename Func, _on_do_server_XXXX
func add_player(id, team : String):
	var player_instance = AL_Globals.player.instantiate()
	var sp_rt_node : Node = AL_Globals.spawnrootnode.find_child(team.capitalize())
	# ToDo: Errorhandling, when spawnnode not found
	player_instance.name = str(id)
	if multiplayer.is_server():
		player_instance.get_node("ReferenceRect/PlayerName").text += " - HOST"
#	player_instance.team = team

#	var pname = player_instance.get_node("ReferenceRect/PlayerName").text

	match team:
		"blue":
			player_instance.team = Color.DODGER_BLUE
			player_instance.global_position =sp_rt_node.global_position

			AL_Globals.playernode.add_child(player_instance)
#			player_instance.get_node("ReferenceRect/TeamColor").color = Color.DODGER_BLUE
		"red":
			player_instance.team = Color.ORANGE_RED
			player_instance.global_position = sp_rt_node.global_position

			AL_Globals.playernode.add_child(player_instance)
#			%SpawnPosition/Red.add_child(player_instance)
#			player_instance.get_node("ReferenceRect/TeamColor").color = Color.ORANGE_RED
		"host":

			player_instance.team = Color.SEA_GREEN
			player_instance.global_position = sp_rt_node.global_position

			AL_Globals.playernode.add_child(player_instance)
#			%SpawnPosition/Host.add_child(player_instance)

#	if multiplayer.has_multiplayer_peer() and multiplayer.get_peers().has(id):
#		_on_server_display_players_connected(team)
		# "User {} is {}.".format([42, "Godot"], "{}")
#		send_message.rpc(str(id), " ({} / {}) has joined the game".format([pname, team.capitalize()], "{}"), false)


## Removes client network node. Close Connection and inform all Clients
#@rpc("authority", "call_local")
# ToDo: Seperate remove player on Host and Client
# ToDo: Rename Func, _on_do_server_remove_client
#		maybe not as RPC()
#		Add Signal for UI notification. To Remove entry from connected clientlist
func _on_do_server_remove_client(id):
	# Only allowed on Server
	if not  multiplayer.is_server(): return


#	if multiplayer.has_multiplayer_peer():
	var _peers =  multiplayer.get_peers()
	if id in _peers:
		multiplayer.multiplayer_peer.disconnect_peer(id, true)
#		var peers = multiplayer.get_peers()

	var _player = AL_Globals.playernode.get_node_or_null(str(id))
	if _player:
		_player.queue_free()

#	var pnode = %PlayersConnectedListTeamBlue.get_node_or_null(str(id))
#	if pnode != null:
#		pnode.queue_free()
#		var pname = _player.get_node("ReferenceRect/PlayerName").text
#		send_message.rpc(str(id), " ({} / {}) has leave the game".format([pname, "Blue".capitalize()], "{}"), false)
#	else:
#		pnode = %PlayersConnectedListTeamRed.get_node_or_null(str(id))
#		if (pnode != null):
#			pnode.queue_free()
#			var _player = AL_Signalbus.playernode.get_node_or_null(str(id))
#			var pname = _player.get_node("ReferenceRect/PlayerName").text
#			send_message.rpc(str(id), " ({} / {}) has leave the game".format([pname, "Red".capitalize()], "{}"), false)
#			_player.queue_free()
	# send_message.rpc(str(id), " left the game", false)


@rpc("call_local", "any_peer")
func remove_client_player() -> void:
	pass

## Load the Map on Server. Synced by MultiplayerSpawner Node
@rpc("authority", "call_local")
# ToDo: Rename Func, _on_do_server_XXXX
func load_game():
	print(str("load_game() -> Authority: %d" % [AL_Globals.mapnode.get_multiplayer_authority()]))
	if is_multiplayer_authority():
		var map_instance = AL_Globals.map.instantiate()
		AL_Globals.mapnode.add_child(map_instance)


#####
# Signals
#####
# ToDo:	Add Signal for Network Errorhandling, Displaying
#		Client, Server; UI
#####
func _on_server_peer_disconnected(id : int) -> void:
	# ToDo: Call remove connection on Server
	#		call: _on_do_server_remove_client
	AL_Signalbus._do_server_remove_client.emit(id)
	# ToDo: Call remove client from UI, Server and Client
	pass


## Called when local Server creation is done
func _on_host_server_created() -> void:
	# ToDo 	:	Show Lobby and Wait for Clients bevor starting
	# 		:	Errorhandling
#	add_player.rpc_id(1, multiplayer.multiplayer_peer.generate_unique_id(), "host")
	var _err = rpc_id(1,"load_game")
	if _err:
		print(error_string(_err))
		return
	else:
		add_player(1, "host")


## Called when hosting a Server starts
func _on_do_server_create():
	if peer.create_server(21277) != OK:
		print("Create Server failed !")
		return

	multiplayer.multiplayer_peer = peer

	multiplayer.peer_disconnected.connect(_on_server_peer_disconnected)
	multiplayer.peer_connected.connect(player_joined)	#_on_server_peer_connected
	print("Create Server success !")

	AL_Signalbus.host_server_created.emit()
	pass



## Called when local Clöient creation is done
func _on_local_client_created() -> void:
	pass


## Called when connecting to a Server starts
func _on_do_client_create(username : String):
	peer.create_client("localhost", 21277)
	multiplayer.multiplayer_peer = peer

	if multiplayer.server_disconnected.is_connected(server_offline):
		multiplayer.server_disconnected.disconnect(server_offline)

	multiplayer.server_disconnected.connect(server_offline)

	if multiplayer.connected_to_server.is_connected(server_connected):
		multiplayer.connected_to_server.disconnect(server_connected)

	multiplayer.connected_to_server.connect(server_connected)

	print("Create Client success ! %s" % username)
	AL_Signalbus.local_client_created.emit()


## Called when connection to Server is successfull
func server_connected():
	print("Client::server_connected() -> Connection to Server success !")
	pass


## Called when connection to Server is lost
func server_offline():
	# Per Signal
	print("Client::server_offline() -> Connection to Server lost !")
#	quit_game()
	pass
#####
