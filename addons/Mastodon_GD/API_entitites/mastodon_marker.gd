# https://docs.joinmastodon.org/entities/Marker/
extends Resource

class_name MastodonMarker

var last_read_id: String
var version: int
var updated_at: String

func from_json(json: Dictionary) -> MastodonMarker:
	if json == null:
		return

	self.last_read_id = json.get('last_read_id')
	self.version = json.get('version')
	self.updated_at = json.get('updated_at')
	return self
