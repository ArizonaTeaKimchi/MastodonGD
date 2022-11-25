# https://docs.joinmastodon.org/entities/Search/
extends Resource

class_name MastodonSearch

var accounts: Array[MastodonAccount] = []
var statuses: Array[MastodonStatus] = []
var hashtags: Array[MastodonTag] = []

func from_json(json: Dictionary) -> MastodonSearch:
	if json.get('accounts') != null:
		for account in json.get('accounts'):
			self.accounts.append(MastodonAccount.new().from_json(account))
	if json.get('statuses') != null:
		for status in json.get('statuses'):
			self.statuses.append(MastodonStatus.new().from_json(status))
	if json.get('hashtags') != null:
		for tag in json.get('hashtags'):
			self.hashtags.append(MastodonTag.new().from_json(tag))

	return self
