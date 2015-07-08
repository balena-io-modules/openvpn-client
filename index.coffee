Promise = require 'bluebird'
EventEmitter = require('events').EventEmitter
path = require 'path'
{ spawn } = require 'child_process'
tmp = Promise.promisifyAll(require('tmp'))
fs = Promise.promisifyAll(require('fs'))

class OpenVPNClient extends EventEmitter
	constructor: (@vpnOpts = []) ->
		@vpnAddress = null
		@proc = null
		@auth = null
		super()

	authenticate: (user, pass) ->
		@auth = { user, pass }
		return this

	_writeAuthFile: ->
		if not @auth
			return false
		Promise.try =>
			tmp.fileAsync()
			.spread (tmpPath, fd, cleanup) =>
				@vpnOpts = @vpnOpts.concat( [ '--auth-user-pass', tmpPath ] )
				fs.writeFileAsync(tmpPath, "#{@auth.user}\n#{@auth.pass}")
				.return(tmpPath)
				.disposer ->
					cleanup()

	connect: (cb) ->
		Promise.using @_writeAuthFile(), =>
			new Promise (resolve, reject) =>
				contents = fs.readFileSync(@vpnOpts[@vpnOpts.length - 1], 'utf-8')
				@proc = spawn('openvpn', @vpnOpts)

				# Prefix and log all OpenVPN output
				@proc.stdout.on 'data', (data) =>
					@emit('data', data)
					data = data.toString()
					m = data.match(///
						PUSH:\ Received\ control\ message:\ '
							PUSH_REPLY,
							route\ [0-9.]+\ [0-9.]+,
							topology\ \w+,
							ping\ \w+,
							ping-restart\ \w+,
							ifconfig\ ([0-9.]+)\ [0-9.]+
						'
					///)
					if m
						@vpnAddress = m[1]
					if data.match('Initialization Sequence Completed')
						@emit('connected')
						resolve()

				@proc.on 'close', (code) =>
					reject(code)
					@emit('close', code)
		.nodeify(cb)

	disconnect: (cb) ->
		new Promise (resolve, reject) =>
			@proc.kill()
			@proc.on 'exit', ->
				resolve()
		.nodeify(cb)

exports.defaultOpts = []

exports.create = (vpnOpts = []) ->
	vpnOpts = exports.defaultOpts.concat(vpnOpts)
	return new OpenVPNClient(vpnOpts)

exports.connect = (auth, vpnOpts = []) ->
	client = exports.create(vpnOpts)
	if auth?
		client.authenticate(auth.user, auth.pass)
	client.connect().disposer ->
		client.disconnect()
