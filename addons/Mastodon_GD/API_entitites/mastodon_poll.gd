# https://docs.joinmastodon.org/entities/Poll/
extends Resource

class_name MastodonPoll

var id: String
var expires_at: String = ''
var expired: bool
var multiple: bool
var votes_count: int
var voters_count: int
var options: Array[Dictionary] = []
var emojis: Array[MastodonCustomEmoji] = []
var voted: bool = false
var own_votes: Array[int] = []

func from_json(json: Dictionary) -> MastodonPoll:
	self.id = json.get('id')
	if json.get('expires_at') != null:
		self.expires_at = json.get('expires_at')
	self.expired = json.get('expired')
	self.multiple = json.get('multiple')
	self.votes_count = json.get('votes_count')
	
	if self.multiple:
		self.voters_count = json.get('voters_count')
	
	for option in json.get('options'):
		self.options.append({
			'title': option.get('title'),
			'votes_count': option.get('votes_count')
		})

	if json.get('emojis') != null:
		for emoji in json.get('emojis'):
			self.emojis.append(MastodonCustomEmoji.new().from_json(emoji))
	
	if json.get('voted') != null:
		self.voted = json.get('voted')
		
	if json.get('own_votes') != null:
		self.own_votes = json.get('own_votes')

	return self
