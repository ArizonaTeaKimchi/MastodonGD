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

## INSTANCE ENDPOINTS
## https://docs.joinmastodon.org/methods/instance/

func get_instance() -> MastodonInstance:
	var result = await self._request('/api/v2/instance', HTTPClient.METHOD_GET)
	return MastodonInstance.new().from_json(result)

func get_instance_peers() -> Array[String]:
	var endpoint = '/api/v1/instance/peers'
	return await self._request(endpoint, HTTPClient.METHOD_GET, PackedStringArray(["Authorization: Bearer %s" % self.token.access_token]))

func get_instance_weekly_activity() -> Array[Dictionary]:
	var endpoint = '/api/v1/instance/activity'
	return await self._request(endpoint, HTTPClient.METHOD_GET, PackedStringArray(["Authorization: Bearer %s" % self.token.access_token]))

func get_instance_rules() -> Array[MastodonRule]:
	var endpoint ='/api/v1/instance/rules'
	var result =  await self._request(endpoint, HTTPClient.METHOD_GET, PackedStringArray(["Authorization: Bearer %s" % self.token.access_token]))
	
	var rules: Array[MastodonRule] = []
	for rule in result:
		rules.append(MastodonRule.new().from_json(rule))
	
	return rules

func get_instance_moderated_servers() -> Array[MastodonDomainBlock]:
	var results = await self._request('/api/v2/instance/domain_block', HTTPClient.METHOD_GET)
	
	var domainBlocks: Array[MastodonDomainBlock] = []
	for domain in results:
		domainBlocks.append(MastodonDomainBlock.new().from_json(domain))
	
	return domainBlocks

func get_instance_extended_description() -> MastodonExtendedDescription:
	var endpoint = '/api/v1/example'
	var result = await self._request(endpoint, HTTPClient.METHOD_GET)
	var extended_description = MastodonExtendedDescription.new().from_json(result)
	
	return extended_description

## TRENDING ENDPOINTS
## https://docs.joinmastodon.org/methods/trends/

func get_instance_trending_tags(limit: int = 10) -> Array[MastodonTag]:
	var result = await self._get_trending('/api/v1/trends/tags', limit)
	var trending_tags: Array[MastodonTag] = []
	for tag in result:
		trending_tags.append(MastodonTag.new().from_json(tag))

	return trending_tags

func get_instance_trending_statuses(limit: int = 10) -> Array[MastodonStatus]:
	var result = await self._get_trending('/api/v1/trends/statuses', limit)
	var trending_statuses: Array[MastodonStatus] = []
	for status in result:
		trending_statuses.append(MastodonStatus.new().from_json(status))

	return trending_statuses

func get_instance_trending_links(limit: int = 10) -> Array[MastodonPreviewCard]:
	var result = await self._get_trending('/api/v1/trends/links', limit)
	var trending_statuses: Array[MastodonPreviewCard] = []
	for status in result:
		trending_statuses.append(MastodonPreviewCard.new().from_json(status))

	return trending_statuses

func _get_trending(endpoint: String, limit: int = 10):
	var data = {'limit': limit}
	
	return await self._request(endpoint, HTTPClient.METHOD_GET, [], data)

## PROFILE DIRECTORY ENDPOINT
## https://docs.joinmastodon.org/methods/directory/

func get_profile_directory(offset: int = 0, limit: int = 40, order: String = 'active', local: bool = false) ->  Array[MastodonAccount]:
	var endpoint = '/api/v1/directory'
	var data = {
		'offset': offset,
		'limit': limit,
		'order': order,
		'local': local
	}
	
	var response = await self._request(endpoint, HTTPClient.METHOD_GET, [], data)
	
	var accounts: Array[MastodonAccount] = []
	for account in response:
		accounts.append(MastodonAccount.new().from_json(account))
	
	return accounts

## CUSTOM EMOJI ENDPOINT
## https://docs.joinmastodon.org/methods/custom_emojis/

func get_custom_emojis() -> Array[MastodonCustomEmoji]:
	var endpoint = '/api/v1/custom_emojis'
	var result = await self._request(endpoint, HTTPClient.METHOD_GET)

	var emojis: Array[MastodonCustomEmoji] = []
	for emoji in result:
		emojis.append(MastodonCustomEmoji.new().from_json(emoji))

	return emojis

## ANNOUNCEMENTS ENDPOINTS
## https://docs.joinmastodon.org/methods/announcements/

func get_announcements(with_dismissed: bool = false) -> Array[MastodonAnnouncement]:
	var endpoint = '/api/v1/announcements'
	var result = await self._request(endpoint, HTTPClient.METHOD_GET, PackedStringArray(["Authorization: Bearer %s" % self.token.access_token]), {'with_dismissed': with_dismissed})
	
	var announcements: Array[MastodonAnnouncement] = []
	for announcement in result:
		announcements.append(MastodonAnnouncement.new().from_json(announcement))
	
	return announcements

func dismiss_announcement(announcement_id: String):
	var endpoint = '/api/v1/announcements/' + announcement_id + '/dismiss'
	self._request(endpoint, HTTPClient.METHOD_POST, PackedStringArray(["Authorization: Bearer %s" % self.token.access_token]))

func add_reaction_to_announcement(announcement_id: String, emoji: String):
	# (FROM DOCS: Unicode emoji, or the shortcode of a custom emoji)
	var endpoint = '/api/v1/announcements/' + announcement_id + '/reactions/' + emoji
	self._request(endpoint, HTTPClient.METHOD_PUT, PackedStringArray(["Authorization: Bearer %s" % self.token.access_token]))

func remove_reaction_to_announcement(announcement_id: String, emoji: String):
	# (FROM DOCS: Unicode emoji, or the shortcode of a custom emoji)
	var endpoint = '/api/v1/announcements/' + announcement_id + '/reactions/' + emoji
	self._request(endpoint, HTTPClient.METHOD_DELETE, PackedStringArray(["Authorization: Bearer %s" % self.token.access_token]))

func get_oembed_info(url: String, max_width: int = 400, max_height: int = -1) -> Dictionary:
	var endpoint = '/api/oembed'
	var data = {
		'url': url,
		'maxwidth': max_width,
		'maxheight': null if max_height < 0 else max_height
	}
	return await self._request(endpoint, HTTPClient.METHOD_GET, [], data)
	
## ACCOUNT ENDPOINTS
## https://docs.joinmastodon.org/methods/accounts/

func get_user_account():
	var path = '/api/v1/accounts/verify_credentials'
	var response = await self._request(path, HTTPClient.METHOD_GET, PackedStringArray(["Authorization: Bearer %s" % self.token.access_token]))
	
	return MastodonAccount.new().from_json(response)

func get_account(account_id: String) -> MastodonAccount:
	var account_path = "/api/v1/accounts/" + account_id
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])

	var result = await self._request(account_path, HTTPClient.METHOD_GET, headers)
	return MastodonAccount.new().from_json(result)

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

func get_conversations(max_id: String = '', since_id: String = '', min_id: String = '', limit: int = 20) -> Array[MastodonConversation]:
	var endpoint = '/api/v1/conversations'
	var data = {
		'limit': limit
	}

	if not max_id.is_empty():
		data['max_id'] = max_id
	if not min_id.is_empty():
		data['min_id'] = min_id
	if not since_id.is_empty():
		data['since_id'] = since_id

	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	var result = await self._request(endpoint, HTTPClient.METHOD_GET, headers, data)
	
	var conversations: Array[MastodonConversation] = []
	for conversation in result:
		conversations.append(MastodonConversation.new().from_json(conversation))

	return conversations

func remove_conversation(conversation_id: String):
	var endpoint = '/api/v1/conversations/' + conversation_id
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	self._request(endpoint, HTTPClient.METHOD_DELETE, headers)

func mark_conversation_as_read(conversation_id: String):
	var endpoint = '/api/v1/conversations/' + conversation_id + '/read'
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	self._request(endpoint, HTTPClient.METHOD_POST, headers)

func get_saved_timeline_position(timelines: Array[String]) -> Dictionary:
	var endpoint = '/api/v1/markers'
	var data = {
		'timeline[]' = timelines
	}

	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	var result = await self._request(endpoint, HTTPClient.METHOD_POST, headers, data)
	
	var positions = {}

	for key in result:
		positions[key] = MastodonMarker.new().from_json(result[key])
	
	return positions

func save_timeline_position(last_read_home_id: String = '', last_read_notification_id: String = ''):
	var endpoint = '/api/v1/markers'
	
	var data = {}
	if not last_read_home_id.is_empty():
		data['home[last_read_id]'] = last_read_home_id
	if not last_read_notification_id.is_empty():
		data['notifications[last_read_id]'] = last_read_notification_id
	
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	self._request(endpoint, HTTPClient.METHOD_POST, headers, data)

## ACCOUNT ENDPOINTS
## https://docs.joinmastodon.org/methods/accounts/
func get_account_statuses(account_id: String,
params: Dictionary = {
		'max_id': '',
		'since_id': '',
		'min_id': '',
		'tagged': ''
	}, exclude_reblogs: bool = false, limit: int = 20) -> MastodonTimeline:

	var endpoint = "/statuses"
	
	var data = {
		'limit': limit, 
		'exclude_reblogs': exclude_reblogs 
	}
	
	for key in params:
		if not params[key].is_empty():
			data[key] = params[key]

	var account_statuses_dict = await self._get_account(account_id, endpoint, data)
	
	return MastodonTimeline.new().from_json(account_statuses_dict)

func get_account_followers(account_id: String, max_id: String = '', since_id: String = '', min_id: String = '', limit: int = 20) -> Array[MastodonAccount]:
	var endpoint = '/followers'
	var data = {
		'limit' = limit
	}

	if not max_id.is_empty():
		data['max_id'] = max_id
	if not since_id.is_empty():
		data['since_id'] = since_id
	if not min_id.is_empty():
		data['min_id'] = min_id

	var response = await self._get_account(account_id, endpoint)
	
	var accounts: Array[MastodonAccount] = []
	for account in response:
		accounts.append(MastodonAccount.new().from_json(account))
	
	return accounts

func get_account_following(account_id: String, max_id: String = '', since_id: String = '', min_id: String = '', limit: int = 20) -> Array[MastodonAccount]:
	var endpoint = '/following'
	var data = {
		'limit' = limit
	}

	if not max_id.is_empty():
		data['max_id'] = max_id
	if not since_id.is_empty():
		data['since_id'] = since_id
	if not min_id.is_empty():
		data['min_id'] = min_id

	var response = await self._get_account(account_id, endpoint, data)

	var accounts: Array[MastodonAccount] = [] 
	for account in response:
		accounts.append(MastodonAccount.new().from_json(account))
	
	return accounts

func get_account_featured_tags(account_id: String) -> Array[MastodonFeaturedTag]:
	var endpoint = '/featured_tags'
	var result = await self._get_account(account_id, endpoint)
	
	var tags: Array[MastodonFeaturedTag] = []
	for tag in result:
		tags.append(MastodonFeaturedTag.new().from_json(tag))
	
	return tags

func get_account_lists(account_id: String) -> Array[MastodonList]:
	var endpoint = '/lists'
	var result = await self._get_account(account_id, endpoint)
	
	var lists: Array[MastodonList] = []
	for list in result:
		lists.append(MastodonList.new().from_json(list))
	
	return lists

func follow_account(account_id: String, reblogs: bool = true, notify: bool = false, languages: Array[String] = [] as Array[String]):
	var data = {
		'reblogs': reblogs,
		'notify': notify
	}
	
	if languages.size() > 0:
		data['languages'] = languages

	self._post_account(account_id, '/follow', data)

func unfollow_account(account_id: String):
	self._post_account(account_id, '/unfollow')

func remove_from_followers(account_id: String):
	self._post_account(account_id, '/remove_from_followers')

func block_account(account_id: String):
	self._post_account(account_id, '/block')

func unblock_account(account_id: String):
	self._post_account(account_id, '/unblock')

func mute_account(account_id: String, notifications: bool = true, duration: int = 0):
	var data = {
		'notifications': notifications,
		'duration': duration 
	}
	self._post_account(account_id, '/mute', data)

func unmute_account(account_id: String):
	self._post_account(account_id, '/unmute')

func feature_on_profile(account_id: String):
	self._post_account(account_id, '/pin')

func unfeature_on_profile(account_id: String):
	self._post_account(account_id, '/unpin')

func set_user_note(account_id: String, comment: String):
	self._post_account(account_id, '/note', {'comment': comment})

func get_relationships(account_ids: Array[String]) -> Array[MastodonRelationship]:
	var results = await self._get_account('', '/relationships', {'id[]': account_ids})

	var lists: Array[MastodonRelationship] = []
	for list in results:
		lists.append(MastodonRelationship.new().from_json(list))
	
	return lists

func get_lists(account_id: String) -> Array[MastodonList]:
	var results = await self._get_account(account_id, '/lists')

	var lists: Array[MastodonList] = []
	for list in results:
		lists.append(MastodonList.new().from_json(list))
	
	return lists

func get_familiar_followers(account_ids: Array[String]) -> Array[MastodonFamiliarFollower]:
	var results = await self._get_account('', 'familiar_followers', {'id[]': account_ids})
	
	var familiar_followers: Array[MastodonFamiliarFollower] = []
	for familiar in results:
		familiar_followers.append(MastodonFamiliarFollower.new().from_json(familiar))
	
	return familiar_followers

func search_for_account(query: String, limit: int = 40, resolve: bool = false, following: bool = false) -> Array[MastodonAccount]:
	var data = {
		'q': query,
		'limit': limit,
		'resolve': resolve,
		'following': following
	}
	var results = await self._get_account('', 'search', data)
	
	var accounts: Array[MastodonAccount] = []
	for account in results:
		accounts.append(MastodonAccount.new().from_json(account))
	
	return accounts

func lookup_account_from_webfinger_address(acct: String, skip_webfinger: bool = true) -> MastodonAccount:
	var result = await self._get_account('', 'lookup', {'acct': acct, 'skip_webfinger': skip_webfinger})
	return MastodonAccount.new().from_json(result)

func _get_account(account_id: String, end_point: String = '', data: Dictionary = {}):
	var path = '/api/v1/accounts/' + account_id + end_point
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	return await self._request(path, HTTPClient.METHOD_GET, headers, data)

func _post_account(account_id: String, end_point: String = '', data: Dictionary = {}):
	var path = '/api/v1/accounts/' + account_id + end_point
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	return await self._request(path, HTTPClient.METHOD_POST, headers, data)

	pass


## TIMELINE ENDPOINTS
## https://docs.joinmastodon.org/methods/timelines/

func _get_timeline(timeline_version: String, data: Dictionary = {}) -> MastodonTimeline:
	var timelines_base = '/api/v1/timelines/' + timeline_version
	
	var headers = []
	headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	
	var instance_dict = await self._request(timelines_base, HTTPClient.METHOD_GET, headers, data)
	var timeline = MastodonTimeline.new()
	return timeline.from_json(instance_dict)

func get_public_timeline(data: Dictionary = {
		'local': false,
		'remote': false,
		'only_media': false,
		'limit': 20
	},
	max_id: String = '', since_id: String = '', min_id: String = '') -> MastodonTimeline:

	if not max_id.is_empty():
		data['max_id'] = max_id
	if not min_id.is_empty():
		data['min_id'] = min_id
	if not since_id.is_empty():
		data['since_id'] = since_id

	return await self._get_timeline('public', data)

func get_local_timeline(data: Dictionary = {
		'local': false,
		'remote': false,
		'only_media': false,
		'limit': 20
	}, max_id: String = '', since_id: String = '', min_id: String = '') -> MastodonTimeline:
	
	data['local'] = true
	return await self.get_public_timeline(data, max_id, since_id, min_id)

func get_hashtag_timeline(hashtag: String, data: Dictionary = {
		'local': false,
		'only_media': false,
		'limit': 20
		}, max_id: String = '', since_id: String = '', min_id: String = '') -> MastodonTimeline:
	# exclude '#' symbol from hashtag param	
	if not max_id.is_empty():
		data['max_id'] = max_id
	if not min_id.is_empty():
		data['min_id'] = min_id
	if not since_id.is_empty():
		data['since_id'] = since_id

	return await self._get_timeline('tag/' + hashtag, data)

func get_home_timeline(max_id: String = '', since_id: String = '', min_id: String = '', limit: int = 20) -> MastodonTimeline:
	var data = {'limit': limit}
	
	if not max_id.is_empty():
		data['max_id'] = max_id
	if not min_id.is_empty():
		data['min_id'] = min_id
	if not since_id.is_empty():
		data['since_id'] = since_id

	return await self._get_timeline('home', data)

func get_list_timeline(list_id: String, max_id: String = '', since_id: String = '', min_id: String = '', limit: int = 20) -> MastodonTimeline:
	var data = {'limit': limit}
	
	if not max_id.is_empty():
		data['max_id'] = max_id
	if not min_id.is_empty():
		data['min_id'] = min_id
	if not since_id.is_empty():
		data['since_id'] = since_id

	return await self._get_timeline("list/" + list_id, data)

## NOTIFICATION ENDPOINTS

func get_notifications(data: Dictionary) -> Array[MastodonNotification]:
	# OPTIONAL
	# max_id : String
	# since_id : String
	# min_id: String
	# limit: int = 20
	# types[]: String
	# exclude_types[]: String
	# account_id : String
	var endpoint = '/api/v1/notifications'
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	
	var response = await self._request(endpoint, HTTPClient.METHOD_GET, headers, data)
	var notifcations: Array[MastodonNotification] = []
	
	for n in response:
		var notification = MastodonNotification.new().from_json(n)
		notifcations.append(notification)
	
	return notifcations

func get_notification(notification_id: String) -> MastodonNotification:
	var endpoint = '/api/v1/notifications/' + notification_id
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	var result = await self._request(endpoint, HTTPClient.METHOD_GET, headers)
	var notification = MastodonNotification.new().from_json(result)
	return notification

func dismiss_all_notifications():
	var endpoint = '/api/v1/notifications/clear'
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	self._request(endpoint, HTTPClient.METHOD_POST, headers)

## SEARCH ENDPOINT
## https://docs.joinmastodon.org/methods/search/

func search(query: String, type: String = '', 
	data: Dictionary = {
		'resolve': false,
		'following': false,
		'exclude_unreviewed': false,
		'limit': 20,
		'offset': 0
	},
	id_params: Dictionary = {
		'account_id': '', 
		'max_id': '', 
		'min_id': ''
	}) -> MastodonSearch:
	var endpoint = '/api/v2/search'
	
	data['q'] = query
	
	if not type.is_empty():
		data['type'] = type

	if not id_params.is_empty():
		if not id_params['max_id'].is_empty():
			data['max_id'] = id_params['max_id']
		if not id_params['min_id'].is_empty():
			data['min_id'] = id_params['min_id']
		if not id_params['account_id'].is_empty():
			data['account_id'] = id_params['account_id']

	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	
	var result = await self._request(endpoint, HTTPClient.METHOD_GET, headers, data)
	
	var search_result: MastodonSearch = MastodonSearch.new().from_json(result)
	return search_result

## STATUS ENDPOINTS
## https://docs.joinmastodon.org/methods/statuses/

## PARAMS DICT
# REQUIRED
# status: String (OPTIONAL if media provided)
#
# OPTIONAL
# in_reply_to_id: String
# visiblity: String (public/unlisted/private/direct)
# sensitive: bool
# spoiler_text: String
# scheduled_at: String (ISO 8601 Datetime) 
# language: String (ISO 639 language code)

## ARRAY OF MEDIA_PARAMS DICTS
# REQUIRED
# media_name: String (requires extension)
# media: PackedByteArray
#
# OPTIONAL
# media_thumbnail: PackedByteArray
# media_description: String (consider nudging user to writing media descriptions)
# focus: String (comma seperated 'x,y' uv coordinates, -1.0 through 1.0, defaults to '0.0,0.0')

## POLL_PARAMS DICT
# REQUIRED
# poll[options][]: Array[String]
# poll[expires_in]: String: int (in seconds)
#
# OPTIONAL
# poll[multiple]: bool = false
# poll[hide_totals]: bool = false

func post_status(status_params: Dictionary = {}, media_params: Array[Dictionary] = [] as Array[Dictionary], poll_params: Dictionary = {}):
	var status_path = '/api/v1/statuses'
	
	var media_ids = []
	if not media_params.is_empty():
		for attachment in media_params:
			var a = await self.upload_media_as_attachment(attachment)
			if a != null:
				if not a.id.is_empty():
					media_ids.append(a.id)

	var data = {}

	if not media_ids.is_empty():
		data['media_ids[]'] = media_ids
	
	for key in status_params:
		data[key] = status_params[key]

	if data.get('sensitive', false):
		data['spoiler_text'] = status_params.get('spoiler_text', 'The user has marked this content as sensitive')

	for key in poll_params:
		data[key] = poll_params[key]

	var response = await self._request(status_path, HTTPClient.METHOD_POST, PackedStringArray(["Authorization: Bearer %s" % self.token.access_token]), data)

func view_status(status_id: String) -> MastodonStatus:	
	var status_dict = await self._status('', status_id, HTTPClient.METHOD_GET)
	
	return MastodonStatus.new().from_json(status_dict)
	
func delete_status(status_id: String):
	self._status('', status_id, HTTPClient.METHOD_DELETE)

func get_parent_and_child_statuses(status_id: String) -> MastodonContext:
	var endpoint = '/context'
	var result = await self._status(endpoint, status_id, HTTPClient.METHOD_GET)
	
	var context: MastodonContext = MastodonContext.new().from_json(result)
	
	return context

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

func view_status_source(status_id: String) -> MastodonStatusSource:
	var result = await self._status('/source', status_id, HTTPClient.METHOD_GET)
	return MastodonStatusSource.new().from_json(result)

func view_status_edit_history(status_id: String) -> Array[MastodonStatusEdit]:
	var result = await self._status('/history', status_id, HTTPClient.METHOD_GET)
	
	var edits: Array[MastodonStatusEdit] = []
	for edit in result:
		edits.append(MastodonStatusEdit.new().from_json(edit))
	
	return edits

func _get_accounts_by_status_action(endpoint: String, status_id: String):
	var users: Array[MastodonAccount] = []

	var users_dict = await self._status(endpoint, status_id)

	for user in users_dict:
		users.append(MastodonAccount.new().from_json(user))

	return users

func _status(endpoint: String, status_id: String, method: HTTPClient.Method = HTTPClient.METHOD_GET):
	var status_path = '/api/v1/statuses/'
	var url = status_path + status_id + endpoint
	var headers = PackedStringArray([
		"Authorization: Bearer %s" % self.token.access_token])
	return await self._request(url, method, headers)
	
## MEDIA ENDPOINTS
## https://docs.joinmastodon.org/methods/media/

func upload_media_as_attachment(media_params: Dictionary) -> MastodonMediaAttachment:
	var file_name: String = media_params.get('media_name')
	var media: PackedByteArray = media_params.get('media')
	var thumbnail: PackedByteArray = media_params.get('thumbnail', PackedByteArray([]))
	var description: String = media_params.get('media_description', '')
	var focus: String = media_params.get('focus', '0.0,0.0')

	var mime_type = self._get_mime_type(file_name)
	if mime_type == '':
		return null

	var media_path = '/api/v2/media'

	var headers = PackedStringArray([
		"Authorization: Bearer %s" % self.token.access_token,
		"Content-Type: multipart/form-data; boundary=???"
		])

	var body = PackedByteArray()
	body.append_array("\r\n--???\r\n".to_utf8_buffer())
	body.append_array(("Content-Disposition: form-data; name=\"file\"; filename=\"" + file_name + "\"\r\n").to_utf8_buffer())
	body.append_array(("Content-Type:" + mime_type + "\r\n\r\n").to_utf8_buffer())
	body.append_array(media)

	if not thumbnail.is_empty():
		body.append_array("\r\n--???\r\n".to_utf8_buffer())
		body.append_array(("Content-Disposition: form-data; name=\"thumbnail\"\r\n").to_utf8_buffer())
		body.append_array(("Content-Type:" + mime_type + "\r\n\r\n").to_utf8_buffer())
		body.append_array(thumbnail)

	body.append_array("\r\n--???\r\n".to_utf8_buffer())
	body.append_array(("Content-Disposition: form-data; name=\"focus\"\r\n").to_utf8_buffer())
	body.append_array(("Content-Type: text/plain" + "\r\n\r\n").to_utf8_buffer())
	body.append_array(focus.to_utf8_buffer())
	
	if not description.is_empty():
		body.append_array("\r\n--???\r\n".to_utf8_buffer())
		body.append_array(("Content-Disposition: form-data; name=\"description\"\r\n").to_utf8_buffer())
		body.append_array(("Content-Type: text/plain" + "\r\n\r\n").to_utf8_buffer())
		body.append_array(description.to_utf8_buffer())
	
	body.append_array("\r\n--???--\r\n".to_utf8_buffer())

	var output = await self._request_raw(media_path, HTTPClient.METHOD_POST, headers, body)
	
	if output != null:
		var attachment = MastodonMediaAttachment.new().from_json(output)
		return attachment
	return null

func get_media_attachment(id: String) -> MastodonMediaAttachment:
	var endpoint = '/api/v1/media/' + id
	var response = await self._request(endpoint, HTTPClient.METHOD_GET, PackedStringArray(["Authorization: Bearer %s" % self.token.access_token]))

	var media = MastodonMediaAttachment.new().from_json(response)
	return media

func update_media_attachment(id: String, file_name: String, thumbnail: PackedByteArray, description: String = '', focus: String = '0.0,0.0') -> MastodonMediaAttachment:
	var endpoint = '/api/v1/media/' + id

	var mime_type = self._get_mime_type(file_name)
	if mime_type == '':
		return null
	var body: PackedByteArray = PackedByteArray()
	if not thumbnail.is_empty():
		body.append_array("\r\n--???\r\n".to_utf8_buffer())
		body.append_array(("Content-Disposition: form-data; name=\"thumbnail\"\r\n").to_utf8_buffer())
		body.append_array(("Content-Type:" + mime_type + "\r\n\r\n").to_utf8_buffer())
		body.append_array(thumbnail)

	body.append_array("\r\n--???\r\n".to_utf8_buffer())
	body.append_array(("Content-Disposition: form-data; name=\"focus\"\r\n").to_utf8_buffer())
	body.append_array(("Content-Type: text/plain" + "\r\n\r\n").to_utf8_buffer())
	body.append_array(focus.to_utf8_buffer())
	
	if not description.is_empty():
		body.append_array("\r\n--???\r\n".to_utf8_buffer())
		body.append_array(("Content-Disposition: form-data; name=\"description\"\r\n").to_utf8_buffer())
		body.append_array(("Content-Type: text/plain" + "\r\n\r\n").to_utf8_buffer())
		body.append_array(description.to_utf8_buffer())
	
	body.append_array("\r\n--???--\r\n".to_utf8_buffer())

	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])

	var response = await self._request_raw(endpoint, HTTPClient.METHOD_PUT, headers, body)
	
	var attachment = MastodonMediaAttachment.new().from_json(response)
	
	return attachment

func _get_mime_type(file_name: String) -> String:
	var file_extension = file_name.get_extension()
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
	
	return mime_type
	
## POLL ENDPOINTS
# https://docs.joinmastodon.org/methods/polls/

func get_poll(poll_id: String) -> MastodonPoll:
	var endpoint = '/api/v1/polls/' + poll_id
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	
	var result = await self._request(endpoint, HTTPClient.METHOD_GET, headers)
	
	var poll = MastodonPoll.new().from_json(result)
	return result

func vote_on_poll(poll_id: String, choices: Array[String]) -> MastodonPoll:
	var endpoint = '/api/v1/polls/' + poll_id + "/votes"
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	
	var result = await self._request(endpoint, HTTPClient.METHOD_POST, headers, {'choices[]': choices})
	
	var poll = MastodonPoll.new().from_json(result)
	return result

## SCHEDULED STATUS ENDPOINTS
func get_scheduled_statuses(max_id: String ='', since_id: String = '', min_id: String = '', limit: int = 20) -> Array[MastodonScheduledStatus]:
	var endpoint = 'api/v1/scheduled_statuses'
	var data ={ 'limit': limit }
	
	if not max_id.is_empty():
		data['max_id'] = max_id
	if not since_id.is_empty():
		data['since_id'] = since_id
	if not min_id.is_empty():
		data['min_id'] = min_id

	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])

	var result = await self._request(endpoint, HTTPClient.METHOD_GET, headers, data)
	
	var statuses: Array[MastodonScheduledStatus] = []
	
	for status in result:
		statuses.append(MastodonScheduledStatus.new().from_json(status))
	
	return statuses

func get_scheduled_status(status_id: String) -> MastodonScheduledStatus:
	var endpoint = '/api/v1/scheduled_statuses/' + status_id
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	var result = await self._request(endpoint, HTTPClient.METHOD_GET, headers)
	
	var status: MastodonScheduledStatus = MastodonScheduledStatus.new().from_json(result)
	
	return status

func update_scheduled_status(status_id: String, scheduled_at: String) -> MastodonScheduledStatus:
	var endpoint = '/api/v1/scheduled_statuses/' + status_id
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	var result = await self._request(endpoint, HTTPClient.METHOD_PUT, headers, {'scheduled_at': scheduled_at})
	
	var status: MastodonScheduledStatus = MastodonScheduledStatus.new().from_json(result)
	
	return status

func cancel_scheduled_status(status_id: String) -> MastodonScheduledStatus:
	var endpoint = '/api/v1/scheduled_statuses/' + status_id
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	var result = await self._request(endpoint, HTTPClient.METHOD_DELETE, headers)
	
	var status: MastodonScheduledStatus = MastodonScheduledStatus.new().from_json(result)
	
	return status

## FOLLOW SUGGESTION ENDPOINTS
## https://docs.joinmastodon.org/methods/suggestions/

func get_follow_suggestions(limit: int = 40) -> Array[MastodonSuggestion]:
	var endpoint = '/api/v2/suggestions?limit=' + str(limit)
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])
	
	var response = await self._request(endpoint, HTTPClient.METHOD_GET, headers)
	
	var suggestions: Array[MastodonSuggestion] = []
	for suggestion in response:
		suggestions.append(MastodonSuggestion.new().from_json(suggestion))
	
	return suggestions

func remove_follow_suggestion(account_id: String):
	var endpoint = '/api/v1/suggestions/' + account_id
	var headers = PackedStringArray(["Authorization: Bearer %s" % self.token.access_token])

	await self._request(endpoint, HTTPClient.METHOD_DELETE, headers)

func _request_raw(path: String, method: HTTPClient.Method, headers = [], data: PackedByteArray = PackedByteArray([])):
	var base_url = "https://" + self.instance_name + path

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
#		self.auth_client.cancel_request()
		await self.auth_client.request_completed
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
		var error = json.parse(body_string)
		if error == OK:
			return json.data
	
	push_error("HTTP {0} ERROR (MASTODON): {1}".format([response_code, body.get_string_from_utf8()]))
	return null
