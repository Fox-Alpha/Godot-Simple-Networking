extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Menu.show()
	%ChatBox.position.y = get_viewport().size.y - (get_viewport().size.y / 3) - 15
	%ChatBox.hide()
	%SendMessage.position.y = get_viewport().size.y - (get_viewport().size.y / 6)
	%SendMessage.hide()
	%Scoreboard.hide()
	%Lobby.hide()
	%QuitConfirmation.hide()

	AL_Signalbus.host_server_created.connect(_on_host_server_created)
	AL_Signalbus.local_client_created.connect(_on_local_client_created)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_host_server_created() -> void:
	%Menu.hide()
#	%Scoreboard.show()
	pass


func _on_local_client_created() -> void:
	%Menu.hide()
	%Lobby.show()
	pass
