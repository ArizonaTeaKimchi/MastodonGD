# https://docs.joinmastodon.org/entities/Search/
extends Resource

class_name MastodonSearch

var accounts: Array[MastodonAccount] = []
var statuses: Array[MastodonStatus] = []
var hashtags: Array[MastodonTag] = []

func from_json(json: Dictionary) -> MastodonSearch:
	if json.get('accounts') != null:
		self.accounts = json.get('accounts')
	if json.get('statuses') != null:
		self.statuses = json.get('statuses')
	if json.get('hashtags') != null:
		self.hashtags = json.get('hashtags')

	return self
