extends PanelContainer

@onready var playernode: Node = $"../../Network/Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		if %LobbyConnectedPlayers.visible:
			#Control/Lobby/MarginContainer/HBoxContainer/VBoxContainer2/ScrollContainer/LobbyConnectedPlayers
			display_players_connected(%LobbyConnectedPlayers)


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


func _on_menu_button_pressed():
	# ToDo: Signal senden
	quit_game()


func _on_spawn_team_red_button_pressed():
	add_player.rpc_id(1, multiplayer.get_unique_id(), "red")
	$Control/Lobby.hide()

func _on_spawn_team_blue_button_pressed():
	add_player.rpc_id(1, multiplayer.get_unique_id(), "blue")
	$Control/Lobby.hide()
