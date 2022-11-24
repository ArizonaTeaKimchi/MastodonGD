# https://docs.joinmastodon.org/entities/Account/
extends Resource

class_name MastodonAccount

var id: String
var username:     String
var acct:         String
var display_name: String
var locked:       bool
var bot:          bool
var created_at:    String
var note:          String
var url:           String
var avatar:        String
var avatar_static: String
var header:        String
var header_static: String
var followers_count: int
var following_count: int
var statuses_count:  int
var last_status_at
var emojis: Array[MastodonCustomEmoji] = []
var fields: Array[Dictionary]

func from_json(json: Dictionary):
	self.id = json.get("id")

	self.username = json.get("username")
	self.acct = json.get("acct")
	self.display_name = json.get("display_name")
	self.locked = json.get("locked")
	self.bot = json.get("bot")
	self.created_at = json.get("created_at")
	self.note = json.get("note")
	self.url = json.get("url")
	self.avatar = json.get("avatar")
	self.avatar_static = json.get("avatar_static")
	self.header = json.get("header")
	self.header_static = json.get("header_static")
	self.followers_count = json.get("followers_count")
	self.following_count = json.get("following_count")
	self.statuses_count = json.get("statuses_count")
	self.last_status_at = json.get("last_status_at")

	for emoji in json.get('emojis'):
		self.emojis.append(MastodonCustomEmoji.new().from_json(emoji))

	self.fields = json.get("fields")
	
	return self
