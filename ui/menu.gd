extends PanelContainer


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _on_username_text_submitted(_new_text):
	_on_join_button_pressed()


func _on_host_button_pressed():
#	load_game()
	AL_Signalbus._do_server_create.emit()


func _on_join_button_pressed():
	pass
