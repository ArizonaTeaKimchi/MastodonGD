extends Resource

class_name MastodonConversation

var id: String
var unread: bool
var accounts: Array[MastodonAccount] = []
var last_status: MastodonStatus

func from_json(json: Dictionary) -> MastodonConversation:
	self.id = json.get('id')
	self.unread = json.get('unread')
	
	if json.get('accounts') != null:
		for account in json.get('accounts'):
			self.accounts.append(MastodonAccount.new().from_json(account))
	
	if json.get('last_status') != null:
		self.last_status = MastodonStatus.new().from(json.get('last_status'))
		

	return self
