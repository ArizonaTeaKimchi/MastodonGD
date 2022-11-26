# https://docs.joinmastodon.org/entities/Role/
extends Resource

class_name MastodonRole


var id: int
var name: String
var color: String
var position: String
var permissions: int
var highlighted: bool
var created_at: String
var updated_at: String

func from_json(json: Dictionary) -> MastodonRole:
	if json == null:
		return

	self.id = json.get('id')
	self.name = json.get('name')
	self.color = json.get('color')
	self.position = json.get('position')
	self.permissions = json.get('permissions')
	self.highlighted = json.get('highlighted')
	self.created_at = json.get('created_at')
	self.updated_at = json.get('updated_at')

	return self
