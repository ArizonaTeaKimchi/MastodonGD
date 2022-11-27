# https://docs.joinmastodon.org/entities/Suggestion/
extends Resource

class_name MastodonSuggestion

var source: String
var account: MastodonAccount

func from_json(json: Dictionary) -> MastodonSuggestion:
	if json == null:
		return

	self.source = json.get('source')
	self.account = MastodonAccount.new().from_json(json.get('account'))
	return self
