# https://docs.joinmastodon.org/entities/Preferences/
extends Resource

class_name MastodonPreferences

# posting:default:
var visibility: String
var sensitive: bool
var language: Array[String] = []

# reading:expand:
var media: String
var spoilers: bool

func from_json(json: Dictionary) -> MastodonPreferences:
	if json == null:
		return

	self.visibility = json.get('visibility')
	self.sensitive = json.get('sensitive')
	if json.get('language') != null:
		self.language = json.get('language')
	
	self.media = json.get('media')
	self.spoilers = json.get('spoilers')

	return self
