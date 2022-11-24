# https://docs.joinmastodon.org/entities/ScheduledStatus/
extends Resource

class_name MastodonScheduledStatus

var id: String
var scheduled_at: String
var params: Dictionary
var media_attachments: Array[MastodonMediaAttachment] = []

func from_json(json: Dictionary) -> MastodonScheduledStatus:
	self.id = json.get('id')
	self.scheduled_at = json.get('scheduled_at')
	self.params = json.get('params')
	
	if json.get('media_attachments') != null:
		for attachment in json.get('media_attachments'):
			self.media_attachments.append(MastodonMediaAttachment.new().from_json(attachment))
	
	return self
