extends Resource

class_name MastodonDomainBlock

var domain: String
var digest: String
var severity: String
var comment: String = ''

func from_json(json: Dictionary) -> MastodonDomainBlock:
	self.domain = json.get('domain')
	self.digest = json.get('digest')
	self.severity = json.get('severity')
	
	if json.get('comment') != null:
		self.comment = json.get('comment')

	return self
