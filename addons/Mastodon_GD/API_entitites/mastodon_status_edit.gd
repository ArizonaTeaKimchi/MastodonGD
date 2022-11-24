# https://docs.joinmastodon.org/entities/StatusEdit/
extends Resource

class_name MastodonStatusEdit

var content: String
var spoiler_text: String
var sensitive: bool
var created_at: String
var account: MastodonAccount
var poll: Dictionary
var media_attachments: Array[MastodonMediaAttachment] = []
var emojis: Array[MastodonCustomEmoji] = []

func from_json(json: Dictionary) -> MastodonStatusEdit:
	self.content = json.get('content')
	self.spoiler_text = json.get('spoiler_text')
	self.sensitive = json.get('sensitive')
	self.created_at = json.get('created_at')
	self.account = MastodonAccount.new().from_json(json.get('account'))
	self.poll = json.get('poll')
	
	for attachment in json.get('media_attachments'):
		self.media_attachments.append(MastodonMediaAttachment.new().from_json(attachment))
	
	for emoji in json.get('emojis'):
		self.emojis.append(MastodonCustomEmoji.new().from_json(emoji))
	
	return self
