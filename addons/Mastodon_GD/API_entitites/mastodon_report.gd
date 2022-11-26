# https://docs.joinmastodon.org/entities/Report/
extends Resource

class_name MastodonReport

var id: String
var action_taken: bool
var action_taken_at
var category: String
var comment: String
var forwarded: bool
var created_at: String
var status_ids: Array[String] = []
var rule_ids: Array[String] = []
var target_account: MastodonAccount

func from_json(json: Dictionary) -> MastodonReport:
	if json == null:
		return

	self.id = json.get('id')
	self.action_taken = json.get('action_taken')
	self.action_taken_at = json.get('action_taken_at')
	self.category = json.get('category')
	self.comment = json.get('comment')
	self.forwarded = json.get('forwarded')
	self.created_at = json.get('created_at')
	
	if json.get('status_ids') != null:
		self.status_ids = json.get('status_ids')
	
	if json.get('rule_ids') != null:
		self.rule_ids = json.get('rule_ids')

	self.target_account = MastodonAccount.new().from_json(json.get('target_account'))

	return self
