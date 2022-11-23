extends Resource

class_name MastodonInstance

var uri: String
var title: String
var short_description: String
var description: String
var email: String
var version: String
var urls: Dictionary
var stats: Dictionary
var thumbnail: String
var languages: Array[String]
var registrations: bool
var approval_required:  bool
var contact_account: MastodonAccount

func from_json(json: Dictionary):
	self.uri = json.get("uri")
	self.title = json.get("title")
	self.short_description = json.get("short_description")
	self.description = json.get("description")
	self.email = json.get("email")
	self.version = json.get("version")
	self.urls = json.get("urls")
	self.stats = json.get("stats")
	self.thumbnail = json.get("thumbnail")
	self.languages = json.get("languages")
	self.registrations = json.get("registrations")
	self.approval_required = json.get("approval_required")
	
	self.contact_account = MastodonAccount.new()
	self.contact_account.from_json(json.get("contact_account"))
	
	return self
