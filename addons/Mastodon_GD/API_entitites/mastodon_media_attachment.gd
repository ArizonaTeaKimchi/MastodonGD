# https://docs.joinmastodon.org/entities/MediaAttachment/
extends Resource

class_name MastodonMediaAttachment

var id: String
var type: String
var url: String
var preview_url: String = ''
var remote_url
var meta: Dictionary = {}
var description: String = ''
var blurhash: String = ''

func from_json(json: Dictionary) -> MastodonMediaAttachment:
	if json == null:
		return

	self.id = json.get('id')
	self.type = json.get('type')
	self.url = json.get('url')
	
	if json.get('preview_url') != null:
		self.preview_url = json.get('preview_url')
	self.remote_url = json.get('remote_url')
	
	if json.get('meta') != null:
		self.meta = json.get('meta')
	
	if json.get('description') != null:
		self.description = json.get('description')

	if json.get('blurhash') != null:
		self.blurhash = json.get('blurhash')
	
	return self
