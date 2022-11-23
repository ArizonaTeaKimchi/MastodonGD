extends Resource

class_name MastodonAppState

@export var name: String
@export var id: String
@export var redirect_uri: String
var website
@export var client_id: String
@export var client_secret: String

func from_json(json: Dictionary):
	self.name = json.get('name')
	self.id = json.get('id')
	self.redirect_uri = json.get('redirect_uri')
	self.website = json.get('website')
	self.client_id = json.get('client_id')
	self.client_secret = json.get('client_secret')
	
func to_json():
	return {
		'name' : self.name,
		'id' : self.id,
		'redirect_uri' : self.redirect_uri,
		'website' : self.website,
		'client_id' : self.client_id,
		'client_secret' : self.client_secret
	}
