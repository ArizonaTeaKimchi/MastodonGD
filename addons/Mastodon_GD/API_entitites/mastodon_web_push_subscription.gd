# https://docs.joinmastodon.org/entities/WebPushSubscription/
extends Resource

class_name MastodonWebPushSubscription

var id: String
var endpoint: String
var serverkey: String
var alerts: Dictionary = {
	"follow": false,
	"favourite": false,
	"reblog": false,
	"mention": true,
	"poll": false
}

func from_json(json: Dictionary) -> MastodonWebPushSubscription:
	self.id = json.get('id')
	self.endpoint = json.get('endpoint')
	self.serverkey = json.get('serverkey')
	self.alerts = json.get('alerts')

	return self
