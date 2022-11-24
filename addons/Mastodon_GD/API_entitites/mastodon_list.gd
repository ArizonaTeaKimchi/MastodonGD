# https://docs.joinmastodon.org/entities/List/
extends Resource

class_name MastodonList

var id: String
var title: String
var replies_policy: String

func from_json(json: Dictionary) -> MastodonList:
	self.id = json.get('id')
	self.title = json.get('title')
	self.replies_policy = json.get('replies_policy')

	return self
