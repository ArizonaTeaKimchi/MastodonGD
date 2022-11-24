# https://docs.joinmastodon.org/entities/Filter/
extends Resource

class_name MastodonFilter

var id: String
var title: String
var context: Array[String] = []
var expires_at: String = ''
var filter_action: String
var keywords: Array[MastodonFilterKeyword] = []
var statuses: Array[MastodonFilterStatus] = []

func from_json(json: Dictionary) -> MastodonFilter:
	self.id = json.get('id')
	self.title = json.get('title')
	self.context = json.get('context')
	
	if json.get('expires_at') != null:
		self.expires_at = json.get('expires_at')

	self.filter_action = json.get('filter_action')
	
	if json.get('keywords') != null:
		for keyword in json.get('keywords'):
			self.keywords.append(MastodonFilterKeyword.new().from_json(keyword))
	
	if json.get('statuses') != null:
		for status in json.get('statuses'):
			self.statuses.append(MastodonFilterKeyword.new().from_json(status))
	
	return self
