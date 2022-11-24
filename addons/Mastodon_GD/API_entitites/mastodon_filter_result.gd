# https://docs.joinmastodon.org/entities/FilterStatus/
extends Resource

class_name MastodonFilterResult

var filter: MastodonFilter
var keyword_matches: Array[String] = []
var status_matches: String = ''

func from_json(json: Dictionary) -> MastodonFilterResult:
	if json.get('filter') != null:
		self.filter = MastodonFilter.new().from_json(json.get('filter'))
	if json.get('keyword_matches') != null:
		self.keyword_matches = json.get('keyword_matches')
	if json.get('status_matches') != null:
		self.status_matches = json.get('status_matches')
	
	return self
