# https://docs.joinmastodon.org/entities/CustomEmoji/
extends Resource

class_name MastodonCustomEmoji

var shortcode: String
var url: String
var static_url: String
var visible_in_picker: bool
var category

func from_json(json: Dictionary) -> MastodonCustomEmoji:
	if json == null:
		return

	self.shortcode = json.get('shortcode') 
	self.url = json.get('url') 
	self.static_url = json.get('static_url') 
	self.visible_in_picker = json.get('visible_in_picker')
	self.category = json.get('category') 

	return self
