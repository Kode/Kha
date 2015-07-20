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

import js.node.stream.Readable.IReadable;
import js.node.stream.Writable.IWritable;
import js.node.repl.REPLServer;

/**
	A Read-Eval-Print-Loop (REPL) is available both as a standalone program and easily includable in other programs.
	The REPL provides a way to interactively run JavaScript and see the results.
	It can be used for debugging, testing, or just trying things out.

	By executing node without any arguments from the command-line you will be dropped into the REPL.
	It has simplistic emacs line-editing.
**/
@:jsRequire("repl")
extern class Repl {
	/**
		Returns and starts a REPLServer instance.
	**/
	static function start(options:ReplOptions):REPLServer;
}

/**
	Options for `Repl.start` method.
**/
typedef ReplOptions = {
	/**
		The prompt and stream for all I/O.
		Defaults to '>'.
	**/
	@:optional var prompt:String;

	/**
		the readable stream to listen to.
		Defaults to `Process.stdin`.
	**/
	@:optional var input:IReadable;

	/**
		the writable stream to write readline data to.
		Defaults to `Process.stdout`.
	**/
	@:optional var output:IWritable;

	/**
		pass `true` if the stream should be treated like a TTY, and have ANSI/VT100 escape codes written to it.
		Defaults to checking `isTTY` on the output stream upon instantiation.
	**/
	@:optional var terminal:Bool;

	/**
		function that will be used to eval each given line.
		Defaults to an async wrapper for `eval`.
		Arguments: cmd, context, filename, callback
	**/
	@:optional var eval:String->Dynamic<Dynamic>->String->(js.Error->Dynamic->Void)->Void;

	/**
		whether or not the writer function should output colors.
		If a different writer function is set then this does nothing.
		Defaults to the repl's terminal value.
	**/
	@:optional var useColors:Bool;

	/**
		if set to `true`, then the repl will use the `global` object,
		instead of running scripts in a separate context.
		Defaults to `false`.
	**/
	@:optional var useGlobal:Bool;

	/**
		if set to `true`, then the repl will not output the return value of command if it's `undefined`.
		Defaults to `false`.

		JavaScript `undefined` value is available in Haxe using `js.Lib.undefined`.
	**/
	@:optional var ignoreUndefined:Bool;

	/**
		the function to invoke for each command that gets evaluated which returns the formatting (including coloring) to display.
		Defaults to `Util.inspect`.
	**/
	@:optional var writer:Dynamic->Void;
}
