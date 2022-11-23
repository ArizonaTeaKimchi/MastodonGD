extends Resource

class_name MastodonTimeline

var timeline: Array[MastodonStatus] = []

func from_json(json_array: Array):
	for product in json_array:
		var status = MastodonStatus.new()
		status.from_json(product)
		self.timeline.append(status)
	
	return self
