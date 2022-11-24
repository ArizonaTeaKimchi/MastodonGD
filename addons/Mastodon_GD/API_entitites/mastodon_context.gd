# https://docs.joinmastodon.org/entities/Context/
extends Resource

class_name MastodonContext

var ancestors: Array[MastodonStatus] = []
var descendants: Array[MastodonStatus] = []

func from_json(json: Dictionary) -> MastodonContext:
	if json.get('ancestors') != null:
		for status in json.get('ancestors'):
			self.ancestors.append(MastodonStatus.new().from_json(status))

	if json.get('descendants') != null:
		for status in json.get('descendants'):
			self.descendants.append(MastodonStatus.new().from_json(status))

	return self
