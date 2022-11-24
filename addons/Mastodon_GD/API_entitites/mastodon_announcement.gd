extends Resource

class_name MastodonAnnouncement

var id: String
var content: String
var starts_at
var ends_at
var published: bool
var all_day: bool
var published_at: String
var updated_at
var read: bool  = false # OPTIONAL
var mentions: Array[Dictionary] = []
var statuses: Array[Dictionary] = []
var tags: Array[Dictionary] = []
var emojis: Array[MastodonCustomEmoji] = []
var reactions: Array[MastodonReaction] = []

func from_json(json: Dictionary) -> MastodonAnnouncement:
	self.id = json.get('id')
	self.content = json.get('content')
	self.starts_at = json.get('starts_at')
	self.ends_at = json.get('ends_at')
	self.published = json.get('published')
	self.all_day = json.get('all_day')
	self.published_at = json.get('published_at')
	self.updated_at = json.get('updated_at')
	
	if json.get('read') != null:
		self.read = json.get('read')

	if json.get('mentions') != null:
		for mention in json.get('mentions'):
			self.mentions.append({
				'id' = mention.get('id'),
				'username' = mention.get('username'),
				'url' = mention.get('url'),
				'acct' = mention.get('acct')
			})

	if json.get('statuses') != null:
		for status in json.get('statuses'):
			self.statuses.append({
				'id': status.get('id'),
				'url': status.get('url')
			})

	if json.get('tags') != null:
		for tag in json.get('tags'):
			self.tags.append({
				'name': tag.get('name'),
				'url': tag.get('url')
			})
	
	if json.get('emojis') != null:
		for emoji in json.get('emojis'):
			emojis.append(MastodonCustomEmoji.new().from_json(emoji))
	if json.get('reactions') != null:
		for reaction in json.get('reactions'):
			reactions.append(MastodonReaction.new().from_json(reaction))

	return self
