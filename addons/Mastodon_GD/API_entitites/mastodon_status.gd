# https://docs.joinmastodon.org/entities/Status/
extends Resource

class_name MastodonStatus

# type annotations are missing because base types are non-nulalble in GDSCript
var id: String
var uri: String
var created_at: String
var account: MastodonAccount
var content: String
var visibility: String
var sensitive: bool
var spoiler_text
var media_attachments: Array[MastodonMediaAttachment] = []
var application: MastodonAppState
var mentions: Array
var tags: Array[MastodonTag] = []
var emojis: Array[MastodonCustomEmoji] = []
var replies_count: float
var reblogs_count: float
var favourites_count: float
var url
var in_reply_to_id
var in_reply_to_account_id
var reblog: MastodonStatus
var poll
var card: MastodonPreviewCard
var language
var text
var edited_at
var favourited
var reblogged
var muted
var bookmarked
var pinned
var filtered

func from_json(json: Dictionary) -> MastodonStatus:
	if json == null:
		return

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
	
	self.application = MastodonAppState.new().from_json(json.get('application'), true) if json.get('application') != null else null

	self.mentions = json.get('mentions')

	for tag in json.get('tags'):
		self.tags.append(MastodonTag.new().from_json(tag))

	for emoji in json.get('emojis'):
		self.emojis.append(MastodonCustomEmoji.new().from_json(emoji))

	self.card = MastodonPreviewCard.new().from_json(json.get('card')) if json.get('card') != null else null
	
	if json.get('poll') != null:
		self.poll = MastodonPoll.new().from_json(json.get('poll'))

	self.account = MastodonAccount.new()
	self.account.from_json(json.get('account'))
	
	if self.favourited == null:
		self.favourited = false
	if self.reblogged == null:
		self.reblogged = false
	if self.bookmarked == null:
		self.bookmarked = false
	if self.muted == null:
		self.muted = false
	if self.pinned == null:
		self.pinned = false
	if self.filtered == null:
		self.filtered = []

	if json['reblog'] != null:
		self.reblog = MastodonStatus.new().from_json(json.get('reblog'))
	else:
		self.reblog = null

	for attachment in json.get('media_attachments'):
		self.media_attachments.append(MastodonMediaAttachment.new().from_json(attachment))

	return self
