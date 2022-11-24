# https://docs.joinmastodon.org/methods/featured_tags/
extends Resource

class_name MastodonFeaturedTag

var id: String
var name: String
var url: String
var status_count: int
var last_status_at: String = ''

func from_json(json: Dictionary) -> MastodonFeaturedTag:
	self.id = json.get('id')
	self.name = json.get('name')
	self.url = json.get('url')
	self.status_count = json.get('status_count')
	
	if json.get('last_status_at') != null:
		self.last_status_at = json.get('last_status_at')

	return self
