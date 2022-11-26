extends Resource

class_name MastodonRelationship

var id: String
var following: bool
var showing_reblogs: bool
var notifying: bool
var languages: Array[String] = []
var followed_by: bool
var blocking: bool
var blocked_by: bool
var muting: bool
var muting_notifications: bool
var requested: bool
var domain_blocking: bool
var endorsed: bool
var note: String

func from_json(json: Dictionary) -> MastodonRelationship:
	if json == null:
		return

	self.id = json.get('id')
	self.following = json.get('following')
	self.showing_reblogs = json.get('showing_reblogs')
	self.notifying = json.get('notifying')
	self.languages = json.get('languages')
	self.followed_by = json.get('followed_by')
	self.blocking = json.get('blocking')
	self.blocked_by = json.get('blocked_by')
	self.muting = json.get('muting')
	self.muting_notifications = json.get('muting_notifications')
	self.requested = json.get('requested')
	self.domain_blocking = json.get('domain_blocking')
	self.endorsed = json.get('endorsed')
	self.note = json.get('note')
	
	return self
