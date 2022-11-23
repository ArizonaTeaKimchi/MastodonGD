extends Node

class_name MastodonClient

var instance_name: String
var app_name: String
var app: MastodonAppState
var token: MastodonToken
var auth_client: MastodonAuthClient
var current_instance: MastodonInstance
var current_user: MastodonAccount
 
var app_save_path: String = "user://Mastodon/" 
var instances_path: String = self.app_save_path + 'instances/'
var api_version = "/api/v1"

var jpegs: Array[String] = ['jpg', 'jpeg', 'jfif', 'pjpeg', 'pjp']
var pngs: String = 'png'
var mp4: String = 'mp4'
var webm: String = 'webm'

func Init_Client(instance: String, app_name: String, password: String = '', login_prompt: Node = null):
	self.instance_name = instance
	self.app_name = app_name
	
	var save_credentials = not password.is_empty()

	self.auth_client = MastodonAuthClient.new()
	self.add_child(self.auth_client)
	
	self.app = await self.auth_client.get_application(instance, app_name, password, save_credentials)

	if self.app:
		if login_prompt == null:
			login_prompt = load("res://addons/Mastodon_GD/LoginPrompt/Login_Prompt.tscn").instantiate()
			self.add_child(login_prompt)

		self.token = await self.auth_client.authorize_user(instance, self.app, login_prompt.token_submitted, password, save_credentials)

	self.remove_child(login_prompt)
	self.current_instance = await self.get_instance()
	self.current_user = await self.get_user_account()

func get_instance() -> MastodonInstance:
	var instance_dict = await self._request('/api/v1/instance', HTTPClient.METHOD_GET)
	var instance_data = MastodonInstance.new()
	instance_data.from_json(instance_dict)
	return instance_data

func get_user_account():
	var path = '/api/v1/accounts/verify_credentials'
	var response = await self._request(path, HTTPClient.METHOD_GET, PackedStringArray(["Authorization: Bearer %s" % self.token.access_token]))
	
	var user_account = MastodonAccount.new()
	user_account.from_json(response)
	
	return user_account

func get_account(account_id: String) -> MastodonAccount:
	var account_path = "/api/v1/accounts/" + account_id

	var headers = []
#	if self.current_instance.approval_required or require_auth:
	headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])

	var result = await self._request(account_path, HTTPClient.METHOD_GET, headers)
	var acct = MastodonAccount.new()
	acct.from_json(result)
	return acct

func verify_account_credentials():
	var path = '/api/v1/accounts/verify_credentials'
	var response = await self.auth_client.request(path, PackedStringArray(["Authorization: Bearer %s" % self.token.access_token]), true, HTTPClient.METHOD_GET)
	
	var response_code = response[1]
	return response_code == 200

func get_bookmarks() -> MastodonTimeline:
	var path = '/api/v1/bookmarks'
	var headers = []
#	if self.current_instance.approval_required or require_auth:
	headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	var bookmarks_timeline: MastodonTimeline = await self._request(path, HTTPClient.METHOD_GET, headers)
	return bookmarks_timeline

#func get
func get_preferences():
	var path = '/api/v1/preferences'
	var headers = []
#	if self.current_instance.approval_required or require_auth:
	headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	return await self._request(path, HTTPClient.METHOD_GET, headers)
	
func get_home_timeline() -> MastodonTimeline:
	return await self._get_timeline('home')

func get_public_timeline() -> MastodonTimeline:
	return await self._get_timeline('public')

func get_local_timeline() -> MastodonTimeline:
	return await self._get_timeline('public?local=true')

func get_hashtag_timeline(hashtag: String) -> MastodonTimeline:
	# exclude '#' symbol from hashtag param
	return await self._get_timeline('tag/' + hashtag)

func get_list_timeline(list_id: String) -> MastodonTimeline:
	return await self._get_timeline("list/" + list_id)

func get_account_statuses(account_id: String) -> MastodonTimeline:
	var endpoint = "/statuses"
	
	var account_statuses_dict = await self._get_account(account_id, endpoint)
	
	var timeline = MastodonTimeline.new()
	timeline.from_json(account_statuses_dict)
	
	return timeline

func get_account_followers(account_id: String) -> Array[MastodonAccount]:
	var endpoint = '/followers'
	var response: Array[MastodonAccount] = [] as Array[MastodonAccount]

	var accounts_dict = await self._get_account(account_id, endpoint)

	for account in accounts_dict:
		var acc = MastodonAccount.new()
		acc.from_json(account)
		response.append(acc)
	
	return response

func get_account_following(account_id: String) -> Array[MastodonAccount]:
	var endpoint = '/following'
	var response: Array[MastodonAccount] = [] as Array[MastodonAccount]

	var accounts_dict = await self._get_account(account_id, endpoint)

	for account in accounts_dict:
		var acc = MastodonAccount.new()
		acc.from_json(account)
		response.append(acc)
	
	return response

func get_account_featured_tags(account_id: String):
	# TODO: WHAT ARE FEATURE TAGS
	var endpoint = '/featured_tags'
	return await self._get_account(account_id, endpoint)

func get_account_lists(account_id: String):
	var endpoint = '/lists'
	return await self._get_account(account_id, endpoint)

func get_account_identity_proofs(account_id: String):
	var endpoint = 'identity_proofs'
	return await self._get_account(account_id, endpoint)

func follow_account(account_id: String):
	self._post_account(account_id, '/follow')

func unfollow_account(account_id: String):
	self._post_account(account_id, '/unfollow')
	
func block_account(account_id: String):
	self._post_account(account_id, '/block')

func unblock_account(account_id: String):
	self._post_account(account_id, '/unblock')

func mute_account(account_id: String):
	self._post_account(account_id, '/mute')

func unmute_account(account_id: String):
	self._post_account(account_id, '/unmute')

func feature_on_profile(account_id: String):
	self._post_account(account_id, '/pin')

func unfeature_on_profile(account_id: String):
	self._post_account(account_id, '/unpin')

func set_user_note(account_id: String, comment: String):
	self._post_account(account_id, '/note', {'comment': comment})

func get_relationships(account_ids: Array[String]):
	return await self._get_account('', 'relationships', {'id[]': account_ids})

func search_for_account(query: String):
	return await self._get_account('', 'search', {'q': query})

func _get_account(account_id: String, end_point: String = '', data: Dictionary = {}):
	var path = '/api/v1/accounts/' + account_id + end_point
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	return await self._request(path, HTTPClient.METHOD_GET, headers, data)

func _post_account(account_id: String, end_point: String = '', data: Dictionary = {}):
	var path = '/api/v1/accounts/' + account_id + end_point
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	return await self._request(path, HTTPClient.METHOD_POST, headers, data)

	pass

func _get_timeline(timeline_version: String) -> MastodonTimeline:
	var timelines_base = '/api/v1/timelines/' + timeline_version
	
	var headers = []
#	if self.current_instance.approval_required:
	headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])

	var instance_dict = await self._request(timelines_base, HTTPClient.METHOD_GET, headers)
	var timeline = MastodonTimeline.new()
	timeline.from_json(instance_dict)
	return timeline

func post_status(status_text: String, media_path: String, media_description: String, visibility: String = 'public', sensitive: bool = false, sensitive_text: String=''):
	var status_path = '/api/v1/statuses'

	var media_id = null
	if not media_path.is_empty():
		media_id = await self.upload_media(media_path, media_description)

	var data = {
			'status': status_text,
			'visibility': visibility
		}

	if media_id != null and not media_path.is_empty():
		data['media_ids[]'] = [media_id]
	
	if sensitive:
		data['sensitive'] = sensitive
		data['spoiler_text'] = sensitive_text if not sensitive_text.is_empty() else 'The user has marked this content as sensitive'
	
	var response = await self._request(status_path, HTTPClient.METHOD_POST, PackedStringArray(["Authorization: Bearer %s" % self.token.access_token]), data)

func view_status(status_id: String) -> MastodonStatus:	
	var status_dict = await self._status('', status_id, HTTPClient.METHOD_GET)
	
	var status = MastodonStatus.new()
	status.from_json(status_dict)

	return status

func delete_status(status_id: String):
	self._status('', status_id, HTTPClient.METHOD_DELETE)

func get_parent_and_child_statuses(status_id: String):
	var endpoint = '/context'
	var context_dict = await self._status(endpoint, status_id, HTTPClient.METHOD_GET)
	
	
	var ancestors: Array[MastodonStatus] = []
	var descendants: Array[MastodonStatus] = []

	for status in context_dict['ancestors']:
		var new_status = MastodonStatus.new()
		new_status.from_json(status)
		ancestors.append(new_status)

	for status in context_dict['descendants']:
		var new_status = MastodonStatus.new()
		new_status.from_json(status)
		descendants.append(new_status)
	
	return {'ancestors': ancestors, 'descendants': descendants}

func get_status_boosted_by(status_id: String) ->  Array[MastodonAccount]:
	return await self._get_accounts_by_status_action('/reblogged_by', status_id)

func get_status_favourited_by(status_id: String) ->  Array[MastodonAccount]:
	return await self._get_accounts_by_status_action('/favourited_by', status_id)

func favourite_status(status_id: String):
	self._status('/favourite', status_id, HTTPClient.METHOD_POST)

func undo_favourite_status(status_id: String):
	self._status('/unfavourite', status_id, HTTPClient.METHOD_POST)

func boost_status(status_id: String):
	self._status('/reblog', status_id, HTTPClient.METHOD_POST)

func undo_boost_status(status_id: String):
	self._status('/unreblog', status_id, HTTPClient.METHOD_POST)

func bookmark_status(status_id: String):
	self._status('/bookmark', status_id, HTTPClient.METHOD_POST)

func undo_bookmark_status(status_id: String):
	self._status('/unbookmark', status_id, HTTPClient.METHOD_POST)

func mute_conversation(status_id: String):
	self._status('/mute', status_id, HTTPClient.METHOD_POST)

func undo_mute_conversation(status_id: String):
	self._status('/unmute', status_id, HTTPClient.METHOD_POST)

func pin_to_profile(status_id: String):
	self._status('/pin', status_id, HTTPClient.METHOD_POST)

func undo_pin_to_profile(status_id: String):
	self._status('/unpin', status_id, HTTPClient.METHOD_POST)

func _get_accounts_by_status_action(endpoint: String, status_id: String):
	var users: Array[MastodonAccount] = []

	var users_dict = await self._status(endpoint, status_id)

	for user in users_dict:
		var acc = MastodonAccount.new()
		acc.from_json(user)
		users.append(acc)

	return users

func _status(endpoint: String, status_id: String, method: HTTPClient.Method = HTTPClient.METHOD_GET):
	var status_path = '/api/v1/statuses/'
	var url = status_path + status_id + endpoint
	var headers = PackedStringArray([
		"Authorization: Bearer %s" % self.token.access_token])
	return await self._request(url, method, headers)
	

func upload_media(file_path: String, description: String = ''):
	var file_name = file_path.split("/")[-1]
	var file_extension = file_name.split('.')[-1]
	var mime_type = ''
	if file_extension in self.jpegs:
		mime_type = 'image/jpeg'
	elif file_extension == 'png':
		mime_type = 'image/png'
	elif file_extension == 'webm':
		mime_type = 'video/webm'
	elif file_extension == 'mp4':
		mime_type = 'video/mp4'
	else:
		push_error(("Failed to upload file of type %s" % file_extension) + " accepted formats include jpg, png, webm, and mp4")
		return false

	var file = FileAccess.open(file_path, FileAccess.READ)
	var file_buffer = file.get_buffer(file.get_length())
	
	var media_path = '/api/v2/media'

	var headers = PackedStringArray([
		"Authorization: Bearer %s" % self.token.access_token,
		"Content-Type: multipart/form-data; boundary=???"
		])
	var body = PackedByteArray()
	body.append_array("\r\n--???\r\n".to_utf8_buffer())
	body.append_array(("Content-Disposition: form-data; name=\"file\"; filename=\"" + file_name + "\"\r\n").to_utf8_buffer())
	body.append_array(("Content-Type:" + mime_type + "\r\n\r\n").to_utf8_buffer())
	body.append_array(file_buffer)

	
	if not description.is_empty():
		body.append_array("\r\n--???\r\n".to_utf8_buffer())
		body.append_array(("Content-Disposition: form-data; name=\"description\"\r\n").to_utf8_buffer())
		body.append_array(("Content-Type: text/plain" + "\r\n\r\n").to_utf8_buffer())
		body.append_array(description.to_utf8_buffer())
	
	body.append_array("\r\n--???--\r\n".to_utf8_buffer())

	var output = await self._request_raw(media_path, HTTPClient.METHOD_POST, headers, body)
	
	if output != null:
		return output.get('id')
	
	return null

func post_new_status(status: String, media_ids: Array = [], poll_options: Array = [], poll_expires_in: float = 1.0):
	pass

func _request_raw(path: String, method: HTTPClient.Method, headers = [], data: PackedByteArray = PackedByteArray([])):
	var base_url = "https://" + self.instance_name + path
	
#	var query_string = ""
#	if data.keys().size() > 0:
#		query_string = HTTPClient.new().query_string_from_dict(data)

	var error = self.auth_client.request_raw(base_url, headers, true, method, data)
	if error == OK:
		var response = await self.auth_client.request_completed
		return callv("_on_media_upload", response)
	else:
		return null

func _request(path: String, method: HTTPClient.Method, headers = [], data: Dictionary = {}):
	var base_url = "https://" + self.instance_name + path
	
	var query_string = ""
	if data.keys().size() > 0:
		query_string = HTTPClient.new().query_string_from_dict(data)


	var error = self.auth_client.request(base_url, headers, true, method, query_string)
	
	if error == OK:
		var response = await self.auth_client.request_completed
		return callv("_on_response", response)
	elif error == ERR_BUSY:
		self.auth_client.cancel_request()
#		await self.auth_client.request_completed
		return await self._request(path, method, headers, data)

func _on_response(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		var body_string = body.get_string_from_utf8()
		var error = json.parse(body_string)
		if error == OK:
			
			return json.data
	
	push_error("HTTP {0} ERROR (MASTODON): {1}".format([response_code, body.get_string_from_utf8()]))

func _on_media_upload(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		var body_string = body.get_string_from_utf8()
#		print(body_string)
		var error = json.parse(body_string)
		if error == OK:
			return json.data
	
	push_error("HTTP {0} ERROR (MASTODON): {1}".format([response_code, body.get_string_from_utf8()]))
	return null
