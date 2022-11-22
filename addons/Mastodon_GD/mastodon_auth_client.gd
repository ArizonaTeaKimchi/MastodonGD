extends HTTPRequest

class_name MastodonAuthClient

var app_save_path: String = "user://Mastodon/" 
var instances_path: String = self.app_save_path + 'instances/'
var token_path: String = self.app_save_path + "tokens/"
var api_version = "/api/v1"
# Called when the node enters the scene tree for the first time.
func _ready():
	self.use_threads = true
	pass # Replace with function body.

##################################################
########### APPLICATION REGISTRATION #############

func get_application(instance: String, application_name: String) -> AppState:
	var mastodon_dir = DirAccess.open("user://")

	if not mastodon_dir.dir_exists(self.app_save_path):
		mastodon_dir.make_dir(self.app_save_path)
	
	var dir = DirAccess.open(app_save_path)
	if not dir.dir_exists(self.instances_path):
		dir.make_dir(self.instances_path)

	var app_info: AppState

	if _app_exists(instance):
		app_info = self._load_app(instance)
		print("Found existing app for instance: %s" % instance)
	else:
		app_info = await self._create_app(instance, application_name)

	return app_info

func _app_exists(instance: String) -> bool:
	var dir = DirAccess.open(app_save_path)
	if not dir.dir_exists(self.instances_path):
		dir.make_dir(self.instances_path)
		return false

	dir.change_dir(self.instances_path)

	return dir.file_exists("%s.tres" % instance)

func _load_app(instance: String) -> AppState:
	return ResourceLoader.load(self.instances_path + instance + ".tres") as AppState

func _create_app(
	instance: String, 
	app_name: String, 
	redirect_uri: String='urn:ietf:wg:oauth:2.0:oob', 
	scope: String='read:accounts'
	) -> AppState:

	var query_string = HTTPClient.new().query_string_from_dict({
		'client_name':  app_name,
		'redirect_uris': 'urn:ietf:wg:oauth:2.0:oob',
		'scopes': 'read write follow push',
	})

	var url = "https://{0}{1}/apps".format([instance, self.api_version])
	var results = self.request(url, [], true, HTTPClient.METHOD_POST, query_string)

	var response = await self.request_completed
	
	response.append(instance)

	return callv("_handle_registration_response", response)

func _handle_registration_response(result, response_code, headers, body, instance) -> AppState:
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		return self._save_app(json, instance)
	else:
		push_error('HTTP %s ERROR: Failed to register app with Mastodon instance "%s": %s' % [response_code, instance, body.get_string_from_utf8()])
		return null

func _save_app(result: Dictionary, instance: String) -> AppState:
	var app = AppState.new()
	app.name = result.get('name', null)
	app.id = result.get('id', null)
	app.redirect_uri = result.get('redirect_uri', null)
	app.client_id = result.get('client_id', null)
	app.client_secret = result.get('client_secret', null)

	ResourceSaver.save(app, self.instances_path + instance + ".tres")

	return app

##################################################
############# USER AUTHORIZATION #################

func authorize_user(instance: String, app_state: AppState, login_prompt: Signal):
	# Authorizes the user using OAuth
	# Params:
	# instance (String): Name of Mastodon Instance
	# app_state (AppState): AppState retrieved from get_application()
	# login_prompt (Signal): A user defined signal that is expected to emit the token string used to login. Emit null value to cancel login
	var loaded = false
	var token = null
	var access_token = null
	if _token_exists(instance):
		token = _load_token(instance)
		print('Loaded saved token for instance \"%s\"' % instance)

#		self._verify_token()
	var url = "https://{0}/oauth/authorize
	?client_id={1}
	&scope=read+write
	&redirect_uri={2}
	&response_type=code".format([instance, app_state.client_id, app_state.redirect_uri])
	
	
	var new_token = null

	if token == null:
		OS.shell_open(str(url))
		var access_code = await login_prompt
		new_token = await _get_token(access_code, instance, app_state)
	else:
		loaded = true
		new_token = token

	if new_token.access_token != null:
		var token_verified = await _verify_token(instance, new_token.access_token)
		if token_verified:
			if not loaded:
				self._save_token(instance, new_token)
			return new_token

func _token_exists(instance: String):
	var dir = DirAccess.open(self.app_save_path)
	if not dir.dir_exists(self.token_path):
		DirAccess.make_dir_absolute(self.token_path)
		return false
	
	dir.change_dir(self.token_path)
	
	return dir.file_exists("%s_token.tres" % instance)

func _load_token(instance: String) -> TokenEntity:
#	var dir = DirAccess.open(self.token_path)
	return ResourceLoader.load(token_path+"%s_token.tres" % instance) as TokenEntity

func _get_token(token: String, instance: String, app_state: AppState) -> TokenEntity:
	var oath_url = 'https://{0}/oauth/token'.format([instance])
	
	var query_string = HTTPClient.new().query_string_from_dict({
		'client_id' : app_state.client_id,
		'client_secret' : app_state.client_secret,
		'redirect_uri' : app_state.redirect_uri,
		'grant_type' : 'authorization_code',
		'code' : token,
		'scope' : 'read write'
	})
	
	self.request(oath_url, [], true, HTTPClient.METHOD_POST, query_string)
	
	var response = await self.request_completed
	
	return callv("_attempt_login", response)

func _attempt_login(result, response_code, headers, body) ->TokenEntity:
	print(response_code)
	
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		
		var new_token: TokenEntity = TokenEntity.new()
		new_token.access_token = json.get("access_token")
		new_token.token_type = json.get("token_type")
#		new_token.scope = json.get("scope")
		new_token.created_at = json.get("created_at")
		return new_token
	
	push_error('HTTP %s ERROR: Failed to verify login credentials with Mastodon instance: %s' % [response_code, body.get_string_from_utf8()])
	return null

func _verify_token(instance: String, token: String) -> bool:
	var url = "https://" + instance + "/api/v1/accounts/verify_credentials"
	self.request(url,PackedStringArray(["Authorization: Bearer %s" % token]), true, HTTPClient.METHOD_GET)
	
	var response = await self.request_completed
	return callv("_on_verification_attempted", response)

func _on_verification_attempted(result, response_code, headers, body) -> bool:
	return response_code == 200

func _save_token(instance: String, token: TokenEntity):
	ResourceSaver.save(token, self.token_path + instance + "_token.tres")
	print('Token saved for instance \"%s\"' % instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
