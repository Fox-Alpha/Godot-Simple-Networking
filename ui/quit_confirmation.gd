extends PanelContainer


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_yes_button_pressed():
	get_tree().quit()

func _on_no_button_pressed():
	hide()