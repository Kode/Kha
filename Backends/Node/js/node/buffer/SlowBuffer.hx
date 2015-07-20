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
package js.node.buffer;

/**
	Returns an un-pooled Buffer.

	In order to avoid the garbage collection overhead of creating many individually allocated Buffers,
	by default allocations under 4KB are sliced from a single larger allocated object.
	This approach improves both performance and memory usage since v8 does not need to track
	and cleanup as many Persistent objects.

	In the case where a developer may need to retain a small chunk of memory from a pool
	for an indeterminate amount of time it may be appropriate to create an un-pooled Buffer instance
	using `SlowBuffer` and copy out the relevant bits.

	Though this should used sparingly and only be a last resort after a developer has actively observed
	undue memory retention in their applications.
**/
@:jsRequire("buffer", "SlowBuffer")
extern class SlowBuffer extends Buffer {}
