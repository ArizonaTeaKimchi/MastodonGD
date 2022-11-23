extends Resource

class_name MastodonStatus

# type annotations are missing because variables are non-nulalble in GDSCript
var id: String
var created_at: String
var in_reply_to_id
var in_reply_to_account_id
var sensitive: bool
var spoiler_text
var visibility: String
var language
var uri: String
var url
var replies_count: float
var reblogs_count: float
var favourites_count: float
var favourited
var reblogged
var muted
var bookmarked
var content: String
var reblog: MastodonStatus
var application
var account: MastodonAccount
var media_attachments: Array[MastodonMediaAttachment]
var mentions: Array
var tags: Array
var emojis: Array
var card
var poll

func from_json(json: Dictionary):
	self.id = json.get('id')
	self.created_at = json.get('created_at')
	self.in_reply_to_id = json.get('in_reply_to_id')
	self.in_reply_to_account_id = json.get('in_reply_to_account_id')
	self.sensitive = json.get('sensitive')
	self.spoiler_text = json.get('spoiler_text')
	self.visibility = json.get('visibility')
	self.language = json.get('language')
	self.uri = json.get('uri')
	self.url = json.get('url')
	self.replies_count = json.get('replies_count')
	self.reblogs_count = json.get('reblogs_count')
	self.favourites_count = json.get('favourites_count')
	self.favourited = json.get('favourited')
	self.reblogged = json.get('reblogged')
	self.muted = json.get('muted')
	self.bookmarked = json.get('bookmarked')
	self.content = json.get('content')
	
	self.application = json.get('application')

	self.mentions = json.get('mentions')
	self.tags = json.get('tags')
	self.emojis = json.get('emojis')
	self.card = json.get('card')
	self.poll = json.get('poll')

	self.account = MastodonAccount.new()
	self.account.from_json(json.get('account'))
	
	if self.favourited == null:
		self.favourited = false
	if self.reblogged == null:
		self.reblogged = false
	if self.bookmarked == null:
		self.bookmarked = false
	
	if json['reblog'] != null:
		self.reblog = MastodonStatus.new()
		self.reblog.from_json(json.get('reblog'))
	else:
		self.reblog = null
	
	var attachments = json.get('media_attachments')
	
	self.media_attachments = []
	for attachment in attachments:
		self.media_attachments.append(MastodonMediaAttachment.new().from_json(attachment))

	return self
