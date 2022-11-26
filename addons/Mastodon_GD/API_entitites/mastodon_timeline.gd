extends Resource

class_name MastodonTimeline

var timeline: Array[MastodonStatus] = []

func from_json(json_array: Array) -> MastodonTimeline:
	if json_array == null:
		return

	for product in json_array:
		var status = MastodonStatus.new()
		status.from_json(product)
		self.timeline.append(status)
	
	return self
