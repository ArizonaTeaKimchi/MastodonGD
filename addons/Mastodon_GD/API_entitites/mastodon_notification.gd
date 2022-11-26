extends Resource

class_name MastodonNotification

var id: String
var type: String
var created_at: String
var account: MastodonAccount

func from_json(json: Dictionary) -> MastodonNotification:
	if json == null:
		return

	self.id = json.get('id')
	self.type = json.get('type')
	self.created_at = json.get('created_at')
	self.account = MastodonAccount.new().from_json(json.get('account'))

	return self
