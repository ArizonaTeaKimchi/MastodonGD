extends Resource

class_name MastodonError

var error: String
var error_description: String

func from_json(json: Dictionary) -> MastodonError:
	if json == null:
		return

	self.error = json.get('error')
	self.error_description = json.get('error_description')

	return self
