# https://docs.joinmastodon.org/entities/PreviewCard/
extends Resource

class_name MastodonPreviewCard

var url: String
var title: String
var description: String
var type: String
var author_name: String
var author_url: String
var provider_name: String
var provider_url: String
var html: String
var width: int
var height: int
var image
var embed_url: String
var blurhash

func from_json(json: Dictionary) -> MastodonPreviewCard:
	if json == null:
		return

	self.url = json.get("url")
	self.title = json.get("title")
	self.description = json.get("description")
	self.type = json.get("type")
	self.author_name = json.get("author_name")
	self.author_url = json.get("author_url")
	self.provider_name = json.get("provider_name")
	self.provider_url = json.get("provider_url")
	self.html = json.get("html")
	self.width = json.get("width")
	self.height = json.get("height")
	self.image = json.get("image")
	self.embed_url = json.get("embed_url")
	self.blurhash = json.get("blurhash")

	return self
