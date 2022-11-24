# https://docs.joinmastodon.org/entities/FilterStatus/
extends Resource

class_name MastodonFilterStatus

var id: String
var status_id: String

func from_json(json: Dictionary) -> MastodonFilterStatus:
	self.id = json.get('id')
	self.status_id = json.get('status_id')
	
	return self
