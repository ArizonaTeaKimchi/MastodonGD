# https://docs.joinmastodon.org/entities/Instance/
extends Resource

class_name MastodonInstance

var domain: String
var title: String
var version: String
var source_url: String
var description: String
var usage: Dictionary
var thumbnail: Dictionary
var languages: Array[String]
var configuration: Dictionary
var registrations: Dictionary
var contact: Dictionary
var rules: Array[MastodonRule] = []

func from_json(json: Dictionary):
	self.domain = json.get('domain')
	self.title = json.get('title')
	self.version = json.get('version')
	self.source_url = json.get('source_url')
	self.description = json.get('description')
	self.usage = json.get('usage')
	self.thumbnail = json.get('thumbnail')
	self.languages = json.get('languages')
	self.configuration = json.get('configuration')
	self.registrations = json.get('registrations')
	self.contact = {
		'email': json.get('contact').get('email'),
		'account': MastodonAccount.new().from_json(json.get('contact').get('account'))
		}
	
	for rule in json.get('rules'):
		self.rules.append(MastodonRule.new().from_json(rule))
	
	
	return self
