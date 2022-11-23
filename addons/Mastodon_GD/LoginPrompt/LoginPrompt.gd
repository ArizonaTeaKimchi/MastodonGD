extends Control

signal token_submitted

func _attempt_login(token: String):
	self.token_submitted.emit(token.trim_suffix('\n'))
