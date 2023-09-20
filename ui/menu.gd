extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_username_text_submitted(_new_text):
	_on_join_button_pressed()


func _on_host_button_pressed():
	if peer.create_server(9999) != OK:
		print("Create Server failed !")
		return

	multiplayer.multiplayer_peer = peer

	multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.peer_connected.connect(player_joined)

	load_game()

	server_created.emit()


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
