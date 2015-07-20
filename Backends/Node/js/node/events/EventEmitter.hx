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
package js.node.events;

import haxe.Constraints.Function;

/**
	Enumeration of events emitted by all `EventEmitter` instances.
**/
@:enum abstract EventEmitterEvent<T:Function>(Event<T>) to Event<T> {
	/**
		This event is emitted any time someone adds a new listener.

		Listener arguments:
			event - The event name
			listener - The event handler function

		It is unspecified if listener is in the list returned by emitter.listeners(event).
	**/
	var NewListener : EventEmitterEvent<String->Function->Void> = "newListener";

	/**
		This event is emitted any time someone removes a listener.

		Listener arguments:
			event - The event name
			listener - The event handler function

		It is unspecified if listener is in the list returned by emitter.listeners(event).
	**/
	var RemoveListener : EventEmitterEvent<String->Function->Void> = "removeListener";
}

/**
	Abstract type for events. Its type parameter is a signature
	of a listener for a concrete event.
**/
abstract Event<T:Function>(String) from String to String {}

/**
	All objects which emit events are instances of `EventEmitter`.

	Typically, event names are represented by a camel-cased string, however,
	there aren't any strict restrictions on that, as any string will be accepted.

	Functions can then be attached to objects, to be executed when an event is emitted.
	These functions are called listeners.

	When an `EventEmitter` instance experiences an error, the typical action is to emit an 'error' event.
	Error events are treated as a special case in node. If there is no listener for it, then the default action
	is to print a stack trace and exit the program.

	All `EventEmitter`s emit the event `newListener` when new listeners are added
	and `removeListener` when a listener is removed.
**/
@:jsRequire("events", "EventEmitter")
extern class EventEmitter<TSelf:EventEmitter<TSelf>> implements IEventEmitter {

	function new();

	/**
		Adds a `listener` to the end of the listeners array for the specified `event`.
	**/
	function addListener<T:Function>(event:Event<T>, listener:T):TSelf;
	function on<T:Function>(event:Event<T>, listener:T):TSelf;

	/**
		Adds a one time `listener` for the `event`.

		This listener is invoked only the next time the event is fired, after which it is removed.
	**/
	function once<T:Function>(event:Event<T>, listener:T):TSelf;

	/**
		Remove a `listener` from the listener array for the specified `event`.

		Caution: changes array indices in the listener array behind the listener.
	**/
	function removeListener<T:Function>(event:Event<T>, listener:T):TSelf;

	/**
		Removes all listeners, or those of the specified `event`.
	**/
	function removeAllListeners<T:Function>(?event:Event<T>):TSelf;

	/**
		By default `EventEmitter`s will print a warning if more than 10 listeners are added for a particular event.
		This is a useful default which helps finding memory leaks.

		Obviously not all Emitters should be limited to 10. This function allows that to be increased.
		Set to zero for unlimited.
	**/
	function setMaxListeners(n:Int):Void;

	/**
		Returns an array of listeners for the specified event.
	**/
	function listeners<T:Function>(event:Event<T>):Array<T>;

	/**
		Execute each of the listeners in order with the supplied arguments.
		Returns true if event had listeners, false otherwise.
	**/
	function emit<T:Function>(event:Event<T>, args:haxe.extern.Rest<Dynamic>):Bool;

	/**
		Return the number of listeners for a given event.
	**/
	static function listenerCount<T:Function>(emitter:IEventEmitter, event:Event<T>):Int;
}


/**
    `IEventEmitter` interface is used as "any EventEmitter".

    See `EventEmitter` for actual class documentation.
**/
@:remove
extern interface IEventEmitter {
    function addListener<T:Function>(event:Event<T>, listener:T):IEventEmitter;
    function on<T:Function>(event:Event<T>, listener:T):IEventEmitter;
    function once<T:Function>(event:Event<T>, listener:T):IEventEmitter;
    function removeListener<T:Function>(event:Event<T>, listener:T):IEventEmitter;
    function removeAllListeners<T:Function>(?event:Event<T>):IEventEmitter;
    function setMaxListeners(n:Int):Void;
    function listeners<T:Function>(event:Event<T>):Array<T>;
    function emit<T:Function>(event:Event<T>, args:haxe.extern.Rest<Dynamic>):Bool;
}
