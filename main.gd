extends Node

signal server_created

var player = preload("res://player.tscn")
var map = preload("res://map.tscn")

var playerdata : Dictionary = { "Team_Blue": {}, "Team_Red": {} }

var peer = ENetMultiplayerPeer.new()

var enter_key_pressed = false

@onready var playernode: Node = $Network/Player


func _process(_delta):
	if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		if %LobbyConnectedPlayers.visible:
			display_players_connected(%LobbyConnectedPlayers)


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
			display_players_connected(%PlayersConnectedListTeamBlue)
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


# Function to display players connected, it refreshes each time it is called on Server
func _on_server_display_players_connected(team : String) -> void:
	if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		if  multiplayer.is_server():
			if multiplayer.has_multiplayer_peer():
				var peerlist = multiplayer.get_peers()

				for p in peerlist:
					# peer bereits in liste
					if %PlayersConnectedListTeamBlue.get_node_or_null(str(p)) != null: #.find_child(str(p)):
						continue

					if %PlayersConnectedListTeamRed.get_node_or_null(str(p)) != null: #.find_child(str(p)):
						continue

					var HBox := HBoxContainer.new()
					HBox.name = str(p)
					HBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					# node.add_child(HBox)

					var lblplayer = Label.new()
					lblplayer.text = str(p)
					lblplayer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					HBox.add_child(lblplayer)

					var button = Button.new()
					button.text = "KICK"
					button.name = str(p)
					button.set_meta("p_id", p)
					button.pressed.connect(_on_player_kick_pressed.bind(button))
					HBox.add_child(button)

					match team:
					# BLUE Team
						"blue":
							%PlayersConnectedListTeamBlue.add_child(HBox)
					# RED Team
						"red":
							%PlayersConnectedListTeamRed.add_child(HBox)


# Function to display players connected,
# it refreshes each time it is called on Clients
func display_players_connected(node : Node):
	# Clear the previous list
	if multiplayer.is_server():
		return

	for c in node.get_children():
		c.queue_free()


	# Create the list of connected players
	# TODO	: peerliste aus MultioplayerAPI verwenden
	#		: Seperate Team Red and Team Blue
	var _plist : Array[Node] = playernode.get_children()
	_plist.append_array(playernode.get_children())

	for _peer in _plist:
		var HBox := HBoxContainer.new()
		HBox.name = str(_peer.name)
		HBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		node.add_child(HBox)

		var lblplayer = Label.new()
		lblplayer.text = str(_peer.name)
		lblplayer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		HBox.add_child(lblplayer)

# Networking system

# Server
func _on_player_kick_pressed(butt):
#	var metavar : PackedStringArray = butt.get_meta_list()

#	for m in metavar:
	var m : int = butt.get_meta("p_id")
#	print_debug("Player Kicked ", m)
	peer.disconnect_peer(m)
#	pass


func _on_host_button_pressed():
	if peer.create_server(9999) != OK:
		print("Create Server failed !")
		return

	multiplayer.multiplayer_peer = peer

	multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.peer_connected.connect(player_joined)

	load_game()

	server_created.emit()


func player_joined(id):
	print("main::player_joined() [202] -> Player_Joined() : " + str(id))
	pass


# Client

func _on_join_button_pressed():
	peer.create_client("localhost", 9999)
	multiplayer.multiplayer_peer = peer

	if %Username.text == "":
		%Username.text = "Player"

	if multiplayer.server_disconnected.is_connected(server_offline):
		multiplayer.server_disconnected.disconnect(server_offline)
		multiplayer.server_disconnected.connect(server_offline)
	if multiplayer.connected_to_server.is_connected(server_connected):
		multiplayer.connected_to_server.disconnect(server_connected)
		multiplayer.connected_to_server.connect(server_connected)

	load_game()


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

func load_game():
	%Menu.hide()
	var map_instance = map.instantiate()
	%MapInstance.add_child(map_instance)

	$Control/Lobby.visible = !multiplayer.is_server()

	if multiplayer.is_server():
#		display_players_connected(%PlayersConnectedListTeamBlue)
		%Scoreboard.show()

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
	quit_game()

func _on_username_text_submitted(_new_text):
	_on_join_button_pressed()

func _on_chat_box_disapears_timer_timeout():
	%ChatBox.hide()

func _on_quit_button_button_down():
	$Control/QuitConfirmation.show()

func _on_spawn_team_red_button_pressed():
	add_player.rpc_id(1, multiplayer.get_unique_id(), "red")
	$Control/Lobby.hide()

func _on_spawn_team_blue_button_pressed():
	add_player.rpc_id(1, multiplayer.get_unique_id(), "blue")
	$Control/Lobby.hide()

func _on_yes_button_pressed():
	get_tree().quit()

func _on_no_button_pressed():
	$Control/QuitConfirmation.hide()

func quit_game():
	%Lobby.hide()
	%Menu.show()
	%ChatBox.hide()
	%SendMessage.hide()
	%TypedMessage.text = ""
	%MapInstance.get_child(0).queue_free()

func _on_menu_button_pressed():
	quit_game()


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


func _on_button_pin_box_toggled(button_pressed):
	%ChatBoxDisapearsTimer.paused = button_pressed

	if $ChatBoxDisapearsTimer.paused:
		$Control/ChatBox/MarginContainer/VBoxContainer/HBoxContainer/ButtonPinBox.text = "Pinned"
	else:
		$Control/ChatBox/MarginContainer/VBoxContainer/HBoxContainer/ButtonPinBox.text = "unPinned"


func _on_multiplayer_spawner_blue_despawned(node: Node) -> void:
	print("DeSpawn Blue %s" % node.name)
	pass # Replace with function body.


func _on_multiplayer_spawner_blue_spawned(node: Node) -> void:
	print("Spawn Blue %s" % node.name)
	pass # Replace with function body.
