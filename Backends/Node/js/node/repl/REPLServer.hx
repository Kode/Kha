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
package js.node.repl;

import js.node.events.EventEmitter;

/**
	Enumeration of events emitted by `REPLServer` objects.
**/
@:enum abstract REPLServerEvent<T:haxe.Constraints.Function>(Event<T>) to Event<T> {
	/**
		Emitted when the user exits the REPL in any of the defined ways.
		Namely, typing .exit at the repl, pressing Ctrl+C twice to signal SIGINT,
		or pressing Ctrl+D to signal "end" on the input stream.
	**/
	var Exit : REPLServerEvent<Void->Void> = "exit";
}

/**
	An object representing REPL instance created by `Repl.start`.
**/
@:jsRequire("repl", "REPLServer")
extern class REPLServer extends EventEmitter<REPLServer> {
	/**
		You can expose a variable to the REPL explicitly by assigning it
		to the `context` object associated with each REPLServer.
	**/
	var context(default,null):Dynamic<Dynamic>;
}
