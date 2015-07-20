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

/**
	In each module, the `module` free variable is a reference to the object representing the current module.
	For convenience, `module.exports` is also accessible via the `exports` module-global.
	Module isn't actually a global but rather local to each module.
**/
extern class Module {

	/**
		The `exports` object is created by the Module system.
		Sometimes this is not acceptable; many want their module to be an instance of some class.
		To do this assign the desired export object to module.exports.
		Note that assigning the desired object to `exports` will simply rebind the local exports variable, which is probably not what you want to do.
	**/
	var exports:Dynamic<Dynamic>;

	/**
		Return `exports` from the resolved module.
		The `require` method provides a way to load a module as if `require` was called from the original module.
		Note that in order to do this, you must get a reference to the `module` object. Since `require` returns the `module.exports`,
		and the `module` is typically only available within a specific module's code, it must be explicitly exported in order to be used.
	**/
	function require(id:String):Dynamic<Dynamic>;

	/**
		The identifier for the module.
		Typically this is the fully resolved filename.
	**/
	var id(default,null):String;

	/**
		The fully resolved filename to the module.
	**/
	var filename(default,null):String;

	/**
		Whether or not the module is done loading, or is in the process of loading.
	**/
	var loaded(default,null):Bool;

	/**
		The module that required this one.
	**/
	var parent(default,null):Module;

	/**
		The module objects required by this one.
	**/
	var children(default,null):Array<Module>;
}
