extends Resource

class_name MastodonMediaAttachment

var id: String
var type: String
var url: String
var preview_url: String
var remote_url
var text_url
var meta: Dictionary
var description
var blurhash: String

func from_json(json: Dictionary):
	self.id = json.get('id')
	self.type = json.get('type')
	self.url = json.get('url')
	self.preview_url = json.get('preview_url')
	self.remote_url = json.get('remote_url')
	self.text_url = json.get('text_url')
	self.meta = json.get('meta')
	self.description = json.get('description')
	self.blurhash = json.get('blurhash')
