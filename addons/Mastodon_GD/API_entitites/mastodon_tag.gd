# https://docs.joinmastodon.org/entities/Tag/
extends Resource

class_name MastodonTag

var name: String
var url: String
var history: Array[Dictionary] = []
var following: bool

func from_json(json: Dictionary):
	self.name = json.get('name')
	self.url = json.get('url')
	
	if json.get('history') != null:
		for entry in json.get('history'):
			self.history.append({
				'day': entry.get('day'),
				'uses': entry.get('uses'),
				'accounts': entry.get('accounts')
			})


	if json.get('following') == null:
		self.following = false
	else:
		self.following = json.get('following')
	
	return self
