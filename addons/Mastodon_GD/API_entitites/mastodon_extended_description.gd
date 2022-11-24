extends Resource

class_name MastodonExtendedDescription

var updated_at: String
var content: String

func from_json(json: Dictionary) -> MastodonExtendedDescription:
	self.updated_at = json.get('updated_at')
	self.content = json.get('content')

	return self
