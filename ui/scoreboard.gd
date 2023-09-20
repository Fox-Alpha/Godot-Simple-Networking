extends PanelContainer


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_player_kick_pressed(butt):
#	var metavar : PackedStringArray = butt.get_meta_list()

#	for m in metavar:
	var m : int = butt.get_meta("p_id")
#	print_debug("Player Kicked ", m)
	multiplayer.multiplayer_peer.disconnect_peer(m)
#	pass


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
