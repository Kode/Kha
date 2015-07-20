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

import js.node.vm.Script;

/**
    Using this class JavaScript code can be compiled and
    run immediately or compiled, saved, and run later.
**/
@:jsRequire("vm")
extern class Vm {
    /**
        Compiles `code`, runs it and returns the result.
        Running code does not have access to local scope.

        `filename` is optional, it's used only in stack traces.

        In case of syntax error in `code` emits the syntax error to stderr and throws an exception.
    **/
    static function runInThisContext(code:String, ?filename:String):Dynamic;

    /**
        Compiles `code`, then runs it in sandbox and returns the result.
        Running code does not have access to local scope.

        The object `sandbox` will be used as the global object for code.
        `sandbox` and `filename` are optional, `filename` is only used in stack traces.

        In case of syntax error in `code` emits the syntax error to stderr and throws an exception.
    **/
    @:overload(function(code:String, sandbox:{}, ?filename:String):Dynamic {})
    static function runInNewContext(code:String, ?filename:String):Dynamic;

    /**
        Compiles `code`, then runs it in `context` and returns the result.

        A (V8) context comprises a global object, together with a set of built-in objects and functions.
        Running code does not have access to local scope and the global object held within context will be
        used as the global object for code.

        `filename` is optional, it's used only in stack traces.

        Note that running untrusted code is a tricky business requiring great care.
        To prevent accidental global variable leakage, `runInContext` is quite useful,
        but safely running untrusted code requires a separate process.

        In case of syntax error in `code` emits the syntax error to stderr and throws an exception.
    **/
    static function runInContext(code:String, context:VmContext, ?filename:String):Dynamic;

    /**
        Creates a new context which is suitable for use as the 2nd argument of a subsequent call to `runInContext`.
        A (V8) context comprises a global object together with a set of build-in objects and functions.

        The optional argument `initSandbox` will be shallow-copied to seed the initial contents of the global object used by the context.
    **/
    static function createContext(?initSandbox:{}):VmContext;

    /**
        Compiles `code` but does not run it. Instead, it returns a `Script` object representing this compiled code.
        This script can be run later many times using its methods.

        The returned script is not bound to any global object. It is bound before each run, just for that run.

        `filename` is optional, it's only used in stack traces.

        In case of syntax error in `code` prints the syntax error to stderr and throws an exception.
    **/
    static function createScript(code:String, ?filename:String):Script;
}

/**
    Type of context objects returned by `Vm.createContext`.
**/
extern class VmContext {}
