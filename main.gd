extends Node

var enter_key_pressed = false


func _on_tree_exiting():
	if multiplayer.has_multiplayer_peer():
		var peers = multiplayer.get_peers()
		if not multiplayer.is_server():
			for p in peers:
				multiplayer.disconnect_peer(p)
				# .close_connection ( 100 )
		else:
			multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	pass # Replace with function body.


func _ready():
	AL_Globals.playernode = get_node_or_null("Network/Player")
	AL_Globals.mapnode = get_node_or_null("MapInstance")
	AL_Globals.spawnrootnode = %SpawnPosition #.get_node_or_null("SpawnPosition")
	AL_Globals.rootnode = get_tree().get_root()



#func _process(_delta):
#	pass


func _input(_event):
	if %Menu.visible: return # If the starting menu is not visible it means we are in the game
	return
	@warning_ignore("unreachable_code")
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


# ToDo: Per Signal aufrufen
func quit_game():
	# Close Connection(s)
	%Lobby.hide()
	%Menu.show()
	%ChatBox.hide()
	%SendMessage.hide()
	%TypedMessage.text = ""
	# Only on local player after disconnect, not on Server
	%MapInstance.get_child(0).queue_free()







