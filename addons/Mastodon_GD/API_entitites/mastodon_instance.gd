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

#
#  "contact_account": {
#    "id": "1",
#    "username": "Gargron",
#    "acct": "Gargron",
#    "display_name": "Eugen",
#    "locked": false,
#    "bot": false,
#    "created_at": "2016-03-16T14:34:26.392Z",
#    "note": "<p>Developer of Mastodon and administrator of mastodon.social. I post service announcements, development updates, and personal stuff.</p>",
#    "url": "https://mastodon.social/@Gargron",
#    "avatar": "https://files.mastodon.social/accounts/avatars/000/000/001/original/d96d39a0abb45b92.jpg",
#    "avatar_static": "https://files.mastodon.social/accounts/avatars/000/000/001/original/d96d39a0abb45b92.jpg",
#    "header": "https://files.mastodon.social/accounts/headers/000/000/001/original/c91b871f294ea63e.png",
#    "header_static": "https://files.mastodon.social/accounts/headers/000/000/001/original/c91b871f294ea63e.png",
#    "followers_count": 317112,
#    "following_count": 453,
#    "statuses_count": 60903,
#    "last_status_at": "2019-11-26T21:14:44.522Z",
#    "emojis": [],
#    "fields": [
#      {
#        "name": "Patreon",
#        "value": "<a href=\"https://www.patreon.com/mastodon\" rel=\"me nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">https://www.</span><span class=\"\">patreon.com/mastodon</span><span class=\"invisible\"></span></a>",
#        "verified_at": null
#      },
#      {
#        "name": "Homepage",
#        "value": "<a href=\"https://zeonfederated.com\" rel=\"me nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">https://</span><span class=\"\">zeonfederated.com</span><span class=\"invisible\"></span></a>",
#        "verified_at": "2019-07-15T18:29:57.191+00:00"
#      }
#    ]
#  }
#}
