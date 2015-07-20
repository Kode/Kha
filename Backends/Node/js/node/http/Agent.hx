/*
 * Copyright (C)2014-2015 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
package js.node.http;

import haxe.DynamicAccess;

import js.node.net.Socket;

/**
	In node 0.5.3+ there is a new implementation of the HTTP Agent
	which is used for pooling sockets used in HTTP client requests.

	Previously, a single agent instance helped pool for a single host+port.
	The current implementation now holds sockets for any number of hosts.

	The current HTTP Agent also defaults client requests to using Connection:keep-alive.
	If no pending HTTP requests are waiting on a socket to become free the socket is closed.
	This means that node's pool has the benefit of keep-alive when under load but still
	does not require developers to manually close the HTTP clients using keep-alive.

	Sockets are removed from the agent's pool when the socket emits either a "close" event
	or a special "agentRemove" event.
**/
@:jsRequire("http", "Agent")
extern class Agent {
	/**
		Determines how many concurrent sockets the agent can have open per origin.
		Default: Infinity
	**/
	var maxSockets:Float;

	/**
		For Agents supporting HTTP KeepAlive, this sets the maximum number of sockets
		that will be left open in the free state.
		Default: 256
	**/
	var maxFreeSockets:Float;

	/**
		An object which contains arrays of sockets currently in use by the Agent.
		Do not modify.
	**/
	var sockets(default,null):DynamicAccess<Array<Socket>>;

	/**
		An object which contains queues of requests that have not yet been assigned to sockets.
		Do not modify.
	**/
	var requests(default,null):DynamicAccess<Array<ClientRequest>>;

	function new(?options:AgentOptions);

	/**
		Destroy any sockets that are currently in use by the agent.

		It is usually not necessary to do this. However, if you are using an agent with KeepAlive enabled,
		then it is best to explicitly shut down the agent when you know that it will no longer be used.
		Otherwise, sockets may hang open for quite a long time before the server terminates them.
	**/
	function destroy():Void;

	/**
		Get a unique name for a set of request options, to determine whether a connection can be reused.
		In the http agent, this returns host:port:localAddress. In the https agent, the name includes the CA,
		cert, ciphers, and other HTTPS/TLS-specific options that determine socket reusability.

		TODO: proper typing for this?
	**/
	function getName(options:{}):String;
}


/**
	Options for `Agent` constructor.
**/
typedef AgentOptions = {
	/**
		Keep sockets around in a pool to be used by other requests in the future.
		Default: false
	**/
	@:optional var keepAlive:Bool;

	/**
		When using HTTP KeepAlive, how often to send TCP KeepAlive packets over sockets being kept alive.
		Default: 1000.
		Only relevant if `keepAlive` is set to `true`.
	**/
	@:optional var keepAliveMsecs:Int;

	/**
		Maximum number of sockets to allow per host.
		Default: Infinity.
	**/
	@:optional var maxSockets:Float;

	/**
		Maximum number of sockets to leave open in a free state.
		Only relevant if `keepAlive` is set to `true`.
		Default: 256.
	**/
	@:optional var maxFreeSockets:Float;
}
