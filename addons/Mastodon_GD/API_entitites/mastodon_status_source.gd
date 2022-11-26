# https://docs.joinmastodon.org/entities/StatusSource/
extends Resource

class_name MastodonStatusSource

var id: String
var text: String
var spoiler_text: String

func from_json(json: Dictionary):
	if json == null:
		return

	self.id = json.get('id')
	self.text = json.get('text')
	self.spoiler_text = json.get('spoiler_text')

	return self
