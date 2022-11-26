# https://docs.joinmastodon.org/entities/Token/
extends Resource

class_name MastodonToken

@export var access_token: String
@export var token_type: String
@export var scope: String
@export var created_at: int

func from_json(json: Dictionary) -> MastodonToken:
	if json == null:
		return

	self.access_token = json.get("access_token")
	self.token_type = json.get("token_type")
	self.scope = json.get('scope')
	self.created_at = json.get('created_at')
	
	return self

func to_json():
	return {
	'access_token': self.access_token,
	'token_type': self.token_type,
	'scope': self.scope,
	'created_at': self.created_at
	}
