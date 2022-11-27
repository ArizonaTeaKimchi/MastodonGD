extends Resource

class_name MastodonFamiliarFollower

var id: String
var accounts: Array[MastodonAccount] = []

func from_json(json: Dictionary) -> MastodonFamiliarFollower:
	if json == null:
		return

	self.id = json.get('id')
	
	if json.get('accounts') != null:
		for account in json.get('accounts'):
			accounts.append(MastodonAccount.new().from_json(account))
	
	return self
