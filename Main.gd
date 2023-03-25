extends Node

var player = preload("res://player.tscn")
var map = preload("res://map.tscn")

var playerdata : Dictionary = { "Team_Blue": {}, "Team_Red": {} }

var peer = ENetMultiplayerPeer.new()

var enter_key_pressed = false

func _process(_delta):
	if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		if %LobbyConnectedPlayers.visible:
			display_players_connected(%LobbyConnectedPlayers)
		if multiplayer.has_multiplayer_peer() and multiplayer.is_server():
			#display_players_connected(%PlayersConnectedListTeamBlue)
			pass

func _ready():
	$Control/Menu.show()
	%SendMessage.position.y = get_viewport().size.y - (get_viewport().size.y / 6)
	%ChatBox.position.y = get_viewport().size.y - (get_viewport().size.y / 3) - 15
	%SendMessage.hide()
	%ChatBox.hide()
	%Scoreboard.hide()
	$Control/Lobby.hide()
	$Control/QuitConfirmation.hide()

# Hold the Tab key to display connected players and press Enter to send a message

func _input(_event):
	if %Menu.visible: return # If the starting menu is not visible it means we are in the game

	if not multiplayer.is_server():
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
					
					# %PlayersConnectedListTeamRed
		pass


# Function to display players connected, it refreshes each time it is called on Clients

func display_players_connected(node : Node):
	# Clear the previous list
	if multiplayer.is_server():
		return
		
	for c in node.get_children():
		c.queue_free()
		

	# Create the list of connected players
	# TODO: peerliste aus MultioplayerAPI verwenden
	for _peer in %SpawnPosition.get_children():
		var HBox := HBoxContainer.new()
		HBox.name = str(_peer.name)
		HBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		node.add_child(HBox)


		var lblplayer = Label.new()
		lblplayer.text = str(_peer.name)
		lblplayer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		HBox.add_child(lblplayer)

#		if multiplayer.is_server():
#			var button = Button.new()
#			button.text = "KICK"
#			button.name = str(_peer.name)
#			button.set_meta("p_id", int(_peer.name))
#			button.pressed.connect(_on_player_kick_pressed)
#			HBox.add_child(button)
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
	peer.create_server(9999)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.peer_connected.connect(player_joined)

	load_game()


func player_joined(_id):
	pass


# Client

func _on_join_button_pressed():
	peer.create_client("localhost", 9999)
	multiplayer.multiplayer_peer = peer

	if %Username.text == "":
		%Username.text = "Player"

	multiplayer.server_disconnected.connect(server_offline)
	multiplayer.connected_to_server.connect(server_connected)
	

	load_game()


func server_connected():
	pass


@rpc("any_peer")
func add_player(id, team):
	var player_instance = player.instantiate()
	player_instance.name = str(id)
	player_instance.team = team
	%SpawnPosition.add_child(player_instance)
	if multiplayer.has_multiplayer_peer() and multiplayer.get_peers().has(id):
		_on_server_display_players_connected(team)
		send_message.rpc(str(id), " has joined the game", false)

func load_game():
	%Menu.hide()
	var map_instance = map.instantiate()
	%MapInstance.add_child(map_instance)
	
	$Control/Lobby.visible = !multiplayer.is_server()
	
	if multiplayer.is_server():
#		display_players_connected(%PlayersConnectedListTeamBlue)
		%Scoreboard.show()

func remove_player(id):
	var _player = %SpawnPosition.get_node_or_null(str(id))
	_player.queue_free()
	
	var pnode = %PlayersConnectedListTeamBlue.get_node_or_null(str(id))
	if pnode != null:
		pnode.queue_free()
	else:
		pnode = %PlayersConnectedListTeamRed.get_node_or_null(str(id))
		if (pnode != null):
			pnode.queue_free()
		
		

	send_message.rpc(str(id), " left the game", false)

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
		if not multiplayer.is_server():
			peer.close()
			# .close_connection ( 100 )
		else:
			for p in multiplayer.get_peers():
				peer.disconnect_peer(p)
	pass # Replace with function body.


func _on_button_pin_box_toggled(button_pressed):
	if button_pressed:
		$ChatBoxDisapearsTimer.start()
	else:
		$ChatBoxDisapearsTimer.stop()
	
	if $ChatBoxDisapearsTimer.is_stopped():
		$Control/ChatBox/MarginContainer/VBoxContainer/HBoxContainer/ButtonPinBox.text = "Pinned"
	else:
		$Control/ChatBox/MarginContainer/VBoxContainer/HBoxContainer/ButtonPinBox.text = "unPinned"
		
	pass # Replace with function body.
