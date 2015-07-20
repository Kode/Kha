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
package js.node.readline;

import haxe.extern.EitherType;
import js.node.events.EventEmitter;

/**
	Enumeration of events emitted by the `Interface` objects.
**/
@:enum abstract InterfaceEvent(String) to String {
	/**
		Emitted whenever the input stream receives a \n, usually received when the user hits enter, or return.
		This is a good hook to listen for user input.
	**/
	var Line = "line";

	/**
		Emitted whenever the input stream is paused.
		Also emitted whenever the input stream is not paused and receives the SIGCONT event. (See events SIGTSTP and SIGCONT)
	**/
	var Pause = "pause";

	/**
		Emitted whenever the input stream is resumed.
	**/
	var Resume = "resume";

	/**
		Emitted when close() is called.

		Also emitted when the input stream receives its "end" event.
		The `Interface` instance should be considered "finished" once this is emitted.
		For example, when the input stream receives ^D, respectively known as EOT.

		This event is also called if there is no SIGINT event listener present when the input stream receives a ^C,
		respectively known as SIGINT.
	**/
	var Close = "close";

	/**
		Emitted whenever the input stream receives a ^C, respectively known as SIGINT.
		If there is no SIGINT event listener present when the input stream receives a SIGINT, pause will be triggered.
	**/
	var SIGINT = "SIGINT";

	/**
		This does not work on Windows.

		Emitted whenever the input stream receives a ^Z, respectively known as SIGTSTP.
		If there is no SIGTSTP event listener present when the input stream receives a SIGTSTP,
		the program will be sent to the background.

		When the program is resumed with fg, the pause and SIGCONT events will be emitted.
		You can use either to resume the stream.

		The pause and SIGCONT events will not be triggered if the stream was paused
		before the program was sent to the background.
	**/
	var SIGTSTP = "SIGTSTP";

	/**
		This does not work on Windows.

		Emitted whenever the input stream is sent to the background with ^Z, respectively known as SIGTSTP,
		and then continued with fg(1). This event only emits if the stream was not paused before sending
		the program to the background.
	**/
	var SIGCONT = "SIGCONT";
}

/**
	The class that represents a readline interface with an input and output stream.
**/
extern class Interface extends EventEmitter<Interface> {
	/**
		Sets the prompt, for example when you run node on the command line, you see > , which is node's prompt.
	**/
	function setPrompt(prompt:String, length:Int):Void;

	/**
		Readies readline for input from the user, putting the current `setPrompt` options on a new line,
		giving the user a new spot to write.

		Set `preserveCursor` to true to prevent the cursor placement being reset to 0.

		This will also resume the input stream used with `createInterface` if it has been paused.
	**/
	function prompt(?preserveCursor:Bool):Void;

	/**
		Prepends the prompt with `query` and invokes `callback` with the user's response.
		Displays the query to the user, and then invokes `callback` with the user's response after it has been typed.

		This will also resume the input stream used with `createInterface` if it has been paused.
	**/
	function question(query:String, callback:String->Void):Void;

	/**
		Pauses the readline input stream, allowing it to be resumed later if needed.
	**/
	function pause():Void;

	/**
		Resumes the readline input stream.
	**/
	function resume():Void;

	/**
		Closes the `Interface` instance, relinquishing control on the input and output streams.
		The "close" event will also be emitted.
	**/
	function close():Void;

	/**
		Writes `data` to output stream.
		`key` is an object literal to represent a key sequence; available if the terminal is a TTY.

		This will also resume the input stream if it has been paused.
	**/
	function write(data:EitherType<Buffer,String>, ?key:{}):Void;
}
