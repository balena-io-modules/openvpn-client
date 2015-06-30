openvpn-client
--------------

[![npm version](https://badge.fury.io/js/openvpn-client.svg)](http://npmjs.org/package/openvpn-client)
[![dependencies](https://david-dm.org/resin-io/openvpn-client.png)](https://david-dm.org/resin-io/openvpn-client.png)

Create an OpenVPN client instance, using "openvpn" command.

Installation
------------

```sh
$ npm install openvpn-client
```

Documentation
-------------

* [Class: OpenVPNClient](#openvpnclient)
  * [Event: 'data'](#openvpnclient_data)
  * [Event: 'connect'](#openvpnclient_connect)
  * [Event: 'disconnect'](#openvpnclient_disconnect)
  * [Constructor([vpnOpts])](#openvpnclient_constructor)
  * [.connect([cb])](#openvpnclient_connect)
  * [.disconnect([cb])](#openvpnclient_disconnect)
* [vpnclient.defaultOpts](#module_defaultOpts)
* [vpnclient.create([vpnOpts])](#module_create)
* [vpnclient.connect([auth], [vpnOpts])](#module_connect)

<a name="openvpnclient"></a>
### OpenVPNClient class

OpenVPNClient represents an instance of openvpn running as client
It passes the array of options passed to the constructor as arguments to the openvpn command.
Apart from that, it supports writing to a temporary authentication file that is then passed
as --auth-user-pass argument.

The class is not exposed publicly, but instantiated through other exported functions.

<a name="openvpnclient_data"></a>
#### Event: 'data'
function (buffer)

When data are received from the server.

<a name="openvpnclient_connect"></a>
#### Event: 'connect'
function ()

When connection to server is initialized successfully.

<a name="openvpnclient_disconnect"></a>
#### Event: 'disconnect'
function (exitCode)

When connection to server is closed.

<a name="openvpnclient_constructor"></a>
#### Constructor

Argument: **vpnOpts** The arguments passed to openvpn command.

<a name="openvpnclient__authenticate"></a>
#### .authenticate(user, pass)
Pass a username and password to use as authentication.

If this function is used, then the --auth-user-pass argument is added automatically.

**parameters**:
* **user** username  
* **pass** password  

<a name="openvpnclient_connect"></a>
#### .connect([cb])
Start OpenVPN process.

It returns a Promise that is fulfilled when
"Inititialization Sequence Completed" message is received from the server.

Instead of promises you can use callbacks by passing a callback function.
 
**parameters**:
* **cb** An optional callback function.  

<a name="openvpnclient_disconnect"></a>
#### .disconnect()
        # Kill the OpenVPN process.
        disconnect: ->
                new Promise (resolve, reject) =>
                        @proc.kill()
                        @proc.on 'exit', ->
                                resolve()

<a name="module_defaultopts"></a>
### module.defaultOpts
Default array of options. Any options passed to subsequent functions are merged with this array.

<a name="module_create"></a>
### module.create([vpnOpts]) => OpenVPNClient
Create an openvpn client.

<a name="module_connect"></a>
### module.connect([auth], [vpnOpts]) => Disposer

Create an OpenVPNClient that connects immediately, and return a disposer that disconnects the client.

It will setup authentication based on the first parameter,
and it will return a disposer that when cleaned up disconnects the process.
Use this function when a connection is needed for a specific period of time.

Use it in combination with bluebird's resource management through Promise.using function.

Support
-------

If you're having any problem, please [raise an issue](https://github.com/resin-io/openvpn-client/issues/new) on GitHub and the Resin.io team will be happy to help.

Contribute
----------

- Issue Tracker: [github.com/resin-io/openvpn-client/issues](https://github.com/resin-io/openvpn-client/issues)
- Source Code: [github.com/resin-io/openvpn-client](https://github.com/resin-io/openvpn-client)

Before submitting a PR, please make sure that you include tests, and that [coffeelint](http://www.coffeelint.org/) runs without any warning.

License
-------

The project is licensed under the MIT license.
