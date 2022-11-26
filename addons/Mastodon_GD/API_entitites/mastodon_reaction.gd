# https://docs.joinmastodon.org/entities/Reaction/
extends Resource

class_name MastodonReaction

var name: String
var count: int
var me: bool = false
var url: String = ''
var static_url: String = ''

func from_json(json: Dictionary) -> MastodonReaction:
	if json == null:
		return

	self.name = json.get('name')
	self.count = json.get('count')
	if json.get('me') != null:
		self.me = json.get('me')
	
	if json.get('url') != null:
		self.url = json.get('url')
	
	if json.get('static_url') != null:
		self.static_url = json.get('static_url')
	
	return self
