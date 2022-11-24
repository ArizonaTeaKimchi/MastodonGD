# https://docs.joinmastodon.org/entities/Rule/
extends Resource

class_name MastodonRule

var id: String
var text: String

func from_json(json: Dictionary):
	self.id = json.get('id')
	self.text = json.get('text')
	
	return self
