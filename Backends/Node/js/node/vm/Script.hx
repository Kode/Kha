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
package js.node.vm;

/**
    A class for running JavaScript scripts.
    Returned by `Vm.createScript`.
**/
extern class Script {
    /**
        Similar to `Vm.runInThisContext` but a method of a precompiled `Script` object.
        `runInThisContext` runs the code of script and returns the result.
        Running code does not have access to local scope, but does have access to the global object (v8: in actual context).
    **/
    function runInThisContext():Dynamic;

    /**
        Similar to `Vm.runInNewContext` a method of a precompiled `Script` object.
        `runInNewContext` runs the code of script with `sandbox` as the global object and returns the result.
        Running code does not have access to local scope.
        `sandbox` is optional.

        Note that running untrusted code is a tricky business requiring great care.
        To prevent accidental global variable leakage, `runInNewContext` is quite useful,
        but safely running untrusted code requires a separate process.
    **/
    function runInNewContext(?sandbox:{}):Dynamic;
}
