extends CanvasLayer

signal restart


func _on_restart_btn_pressed():
	restart.emit()
