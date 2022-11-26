# https://docs.joinmastodon.org/entities/FilterKeyword/
extends Resource

class_name MastodonFilterKeyword

var id: String
var keyword: String
var whole_word: bool

func from_json(json: Dictionary) -> MastodonFilterKeyword:
	if json == null:
		return

	self.id = json.get('id')
	self.keyword = json.get('keyword')
	self.whole_word = json.get('whole_word')

	return self
