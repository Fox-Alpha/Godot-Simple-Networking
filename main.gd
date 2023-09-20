extends Node

signal server_created

var player = preload("res://player.tscn")
var map = preload("res://map.tscn")

var playerdata : Dictionary = { "Team_Blue": {}, "Team_Red": {} }

var peer = ENetMultiplayerPeer.new()

var enter_key_pressed = false

@onready var playernode: Node = $Network/Player


#func _process(_delta):
#	if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
#		if %LobbyConnectedPlayers.visible:
#			#Control/Lobby/MarginContainer/HBoxContainer/VBoxContainer2/ScrollContainer/LobbyConnectedPlayers
#			display_players_connected(%LobbyConnectedPlayers)


func _ready():
	$Control/Menu.show()
	%SendMessage.position.y = get_viewport().size.y - (get_viewport().size.y / 6)
	%ChatBox.position.y = get_viewport().size.y - (get_viewport().size.y / 3) - 15
	%SendMessage.hide()
	%ChatBox.hide()
	%Scoreboard.hide()
	$Control/Lobby.hide()
	$Control/QuitConfirmation.hide()
	server_created.connect(_on_server_created)


func _input(_event):
	if %Menu.visible: return # If the starting menu is not visible it means we are in the game

	if not multiplayer.is_server():
		# Hold the Tab key to display connected players and press Enter to send a message
		if Input.is_key_pressed(KEY_TAB):
			%Lobby.display_players_connected(%PlayersConnectedListTeamBlue)
			%Scoreboard.show()
		else:
			%Scoreboard.hide()

	if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_KP_ENTER):
		if not enter_key_pressed:
			enter_key_pressed = true
			%SendMessage.visible = !%SendMessage.visible

			if not %SendMessage.visible:
				if %TypedMessage.text != "":
					send_message.rpc(%Username.text, %TypedMessage.text, multiplayer.is_server())
					%TypedMessage.text = ""
				%ChatBoxDisapearsTimer.start()
			else:
				%ChatBox.show()
				%TypedMessage.grab_focus()
				%ChatBoxDisapearsTimer.stop()
	else:
		enter_key_pressed = false

	if Input.is_action_just_pressed("ui_cancel"):
		%SendMessage.hide()
		%TypedMessage.text = ""
		%ChatBoxDisapearsTimer.start()


func _on_server_created():
	add_player.rpc_id(1, multiplayer.multiplayer_peer.generate_unique_id(), "host")


# Function to send a message
# Client -> Server -> Alle Clients -> Client anzeige in UI
@rpc("call_local", "any_peer")
func send_message(player_name, message, is_server):
	var HBox = HBoxContainer.new()

	%DisplayedMessage.add_child(HBox)

	# Display the name of the player sending the message in red
	var label_player_name = Label.new()
	if is_server:
		player_name = "ADMIN"
	label_player_name.text = player_name
	label_player_name.modulate = Color.RED

	# Send the message
	var label_message = Label.new()
	label_message.text = ": " + message

	HBox.add_child(label_player_name)
	HBox.add_child(label_message)

	# Remove the oldest message received if there are more than 7 displayed
	if %DisplayedMessage.get_child_count() > 7:
		%DisplayedMessage.get_child(0). queue_free()

	%ChatBox.show()
	%ChatBoxDisapearsTimer.start()




## Function to display players connected,
## it refreshes each time it is called on Clients
#func display_players_connected(node : Node):
#	# Clear the previous list
#	if multiplayer.is_server():
#		return
#
#	for c in node.get_children():
#		c.queue_free()
#
#
#	# Create the list of connected players
#	# TODO	: peerliste aus MultioplayerAPI verwenden
#	#		: Seperate Team Red and Team Blue
#	var _plist : Array[Node] = playernode.get_children()
#	_plist.append_array(playernode.get_children())
#
#	for _peer in _plist:
#		var HBox := HBoxContainer.new()
#		HBox.name = str(_peer.name)
#		HBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
#		node.add_child(HBox)
#
#		var lblplayer = Label.new()
#		lblplayer.text = str(_peer.name)
#		lblplayer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
#		HBox.add_child(lblplayer)

# Networking system

# Server





func player_joined(id):
	print("main::player_joined() [202] -> Player_Joined() : " + str(id))
	pass


# Client


func server_connected():
	pass


@rpc("call_local", "any_peer")
func add_player(id, team):
	var player_instance = player.instantiate()
	player_instance.name = str(id)
	if multiplayer.is_server():
		player_instance.get_node("ReferenceRect/PlayerName").text += " - HOST"
#	player_instance.team = team

	var pname = player_instance.get_node("ReferenceRect/PlayerName").text

	match team:
		"blue":
			player_instance.team = Color.DODGER_BLUE
			player_instance.global_position = %SpawnPosition/Blue.global_position

			playernode.add_child(player_instance)
#			player_instance.get_node("ReferenceRect/TeamColor").color = Color.DODGER_BLUE
		"red":
			player_instance.team = Color.ORANGE_RED
			player_instance.global_position = %SpawnPosition/Red.global_position

			playernode.add_child(player_instance)
#			%SpawnPosition/Red.add_child(player_instance)
#			player_instance.get_node("ReferenceRect/TeamColor").color = Color.ORANGE_RED
		"host":

			player_instance.team = Color.SEA_GREEN
			player_instance.global_position = %SpawnPosition/Host.global_position

			playernode.add_child(player_instance)
#			%SpawnPosition/Host.add_child(player_instance)

	if multiplayer.has_multiplayer_peer() and multiplayer.get_peers().has(id):
		_on_server_display_players_connected(team)
		# "User {} is {}.".format([42, "Godot"], "{}")
		send_message.rpc(str(id), " ({} / {}) has joined the game".format([pname, team.capitalize()], "{}"), false)


@rpc("authority")
func load_game():
#	%Menu.hide()
#	%MapInstance.add_child(map_instance)

#	$Control/Lobby.visible = !multiplayer.is_server()

#	if multiplayer.is_server():
#		display_players_connected(%PlayersConnectedListTeamBlue)
#		%Scoreboard.show()
	var map_instance = map.instantiate()

func remove_player(id):

	var pnode = %PlayersConnectedListTeamBlue.get_node_or_null(str(id))
	if pnode != null:
		pnode.queue_free()
		var _player = playernode.get_node_or_null(str(id))
		var pname = _player.get_node("ReferenceRect/PlayerName").text
		_player.queue_free()
		send_message.rpc(str(id), " ({} / {}) has leave the game".format([pname, "Blue".capitalize()], "{}"), false)
	else:
		pnode = %PlayersConnectedListTeamRed.get_node_or_null(str(id))
		if (pnode != null):
			pnode.queue_free()
			var _player = playernode.get_node_or_null(str(id))
			var pname = _player.get_node("ReferenceRect/PlayerName").text
			send_message.rpc(str(id), " ({} / {}) has leave the game".format([pname, "Red".capitalize()], "{}"), false)
			_player.queue_free()



	# send_message.rpc(str(id), " left the game", false)

func server_offline():
	# Per Signal
	quit_game()


# ToDo: Wo ist der QuitButton ?
func _on_quit_button_button_down():
	$Control/QuitConfirmation.show()




# ToDo: Per Signal aufrufen
func quit_game():
	%Lobby.hide()
	%Menu.show()
	%ChatBox.hide()
	%SendMessage.hide()
	%TypedMessage.text = ""
	%MapInstance.get_child(0).queue_free()




func _on_tree_exiting():
	if multiplayer.has_multiplayer_peer():
		var peers = multiplayer.get_peers()
		if not multiplayer.is_server():
			for p in peers:
				peer.disconnect_peer(p)
				# .close_connection ( 100 )
		else:
			peer.close()
		peer = null
	pass # Replace with function body.




