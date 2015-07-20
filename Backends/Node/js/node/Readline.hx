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
package js.node;

import haxe.extern.EitherType;

import js.node.stream.Readable.IReadable;
import js.node.stream.Writable.IWritable;
import js.node.readline.*;

typedef ReadlineOptions = {
	/**
		the readable stream to listen to
	**/
	var input:IReadable;

	/**
		the writable stream to write readline data to
	**/
	var output:IWritable;

	/**
		an optional function that is used for Tab autocompletion.

		The `completer` function is given the current line entered by the user,
		and is supposed to return an Array with 2 entries:
			* An Array with matching entries for the completion.
			* The substring that was used for the matching.
		Which ends up looking something like: [[substr1, substr2, ...], originalsubstring].
	**/
	@:optional var completer:String->Array<EitherType<Array<String>,String>>;

	/**
		pass true if the input and output streams should be treated like a TTY,
		and have ANSI/VT100 escape codes written to it.

		Defaults to checking isTTY on the output stream upon instantiation.
	**/
	@:optional var terminal:Bool;
}

/**
	Enumeration of possible directions for `Readline.clearLine`
**/
@:enum abstract ClearLineDirection(Int) from Int to Int {
	/**
		to the left from cursor
	**/
	var Left = -1;

	/**
		to the right from cursor
	**/
	var Right = 1;

	/**
		the entire line
	**/
	var EntireLine = 0;
}

/**
	Readline allows reading of a stream (such as process.stdin) on a line-by-line basis.

	Note that once you've invoked this module, your node program will not terminate until you've closed the interface.
**/
@:jsRequire("readline")
extern class Readline {
	/**
		Creates a readline Interface instance.
		`createInterface` is commonly used with process.stdin and process.stdout in order to accept user input.
		Once you have a readline instance, you most commonly listen for the "line" event.

		If terminal is `true` for this instance then the output stream will get the best compatibility if it defines
		an `columns` property, and fires a "resize" event on the output if/when the columns ever change
		(process.stdout does this automatically when it is a TTY).
	**/
	static function createInterface(options:ReadlineOptions):Interface;

	/**
		Move cursor to the specified position in a given TTY stream.
	**/
	static function cursorTo(stream:IWritable, x:Int, y:Int):Void;

	/**
		Move cursor relative to it's current position in a given TTY stream.
	**/
	static function moveCursor(stream:IWritable, dx:Int, dy:Int):Void;

	/**
		Clears current line of given TTY stream in a specified direction.
	**/
	static function clearLine(stream:IWritable, dir:ClearLineDirection):Void;

	/**
		Clears the screen from the current position of the cursor down.
	**/
	static function clearScreenDown(stream:IWritable):Void;
}
