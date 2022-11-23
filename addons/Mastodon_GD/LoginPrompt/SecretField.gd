extends TextEdit

signal token_entered

# Called when the node enters the scene tree for the first time.
func _ready():
	self.focus_mode = FOCUS_ALL
	self.grab_focus()
	set_overtype_mode_enabled(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_text_newline"):
		self.token_entered.emit(self.text)
		self.clear()
