# https://docs.joinmastodon.org/entities/Application/
extends Resource

class_name MastodonAppState

@export var name: String
@export var id: String
@export var redirect_uri: String
var website
@export var client_id: String
@export var client_secret: String

func from_json(json: Dictionary, is_external: bool = false) -> MastodonAppState:
	if json == null:
		return

	self.name = json.get('name')
	self.website = json.get('website')

	if not is_external:
		self.id = json.get('id')
		self.redirect_uri = json.get('redirect_uri')
		self.client_id = json.get('client_id')
		self.client_secret = json.get('client_secret')
	
	return self
	
func to_json():
	return {
		'name' : self.name,
		'id' : self.id,
		'redirect_uri' : self.redirect_uri,
		'website' : self.website,
		'client_id' : self.client_id,
		'client_secret' : self.client_secret
	}
