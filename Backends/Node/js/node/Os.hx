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
	Object containing the number of milliseconds the CPU/core spent in: user, nice, sys, idle, and irq
**/
typedef CPUTime = {
	var user:Int;
    var nice:Int;
    var sys:Int;
    var idle:Int;
    var irq:Int;
}

/**
	Object containing information about each CPU/core installed: model, speed (in MHz), and times
**/
typedef CPU = {
	/**
		CPU Model. E.g. 'Intel(R) Core(TM) i7 CPU         860  @ 2.80GHz'
	**/
	var model:String;

	/**
		MHz Speed
	**/
	var speed:Int;

	/**
		CPUTime data.
	**/
	var times:CPUTime;
}

/**
	Objects containing information about network interface addresses.
**/
typedef NetworkInterface = Array<NetworkInterfaceAddressInfo>;
typedef NetworkInterfaceAddressInfo = {
	/**
		IP address family (e.g. IPv4, IPv6).
	**/
	var family:String;

	/**
		IP address (format depends on family).
	**/
	var address:String;

	/**
		Whether this address is internal.
	**/
	var internal:Bool;
}

@:enum abstract Endianness(String) to String {
	var BigEndian = "BE";
	var LittleEndian = "LE";
}

/**
	Provides a few basic operating-system related utility functions.
**/
@:jsRequire("os")
extern class Os {

	/**
		A constant defining the appropriate End-of-line marker for the operating system.
	**/
	static var EOL(default,null):String;

	/**
		Returns the operating system's default directory for temp files.
	**/
	static function tmpdir():String;

	/**
		Returns the endianness of the CPU. Possible values are "BE" or "LE".
	**/
	static function endianness():Endianness;

	/**
		Returns the hostname of the operating system.
	**/
	static function hostname():String;

	/**
		Returns the operating system name.
	**/
	static function type():String;

	/**
		Returns the operating system platform.
	**/
	static function platform():String;

	/**
		Returns the operating system CPU architecture.
	**/
	static function arch():String;

	/**
		Returns the operating system release.
	**/
	static function release():String;

	/**
		Returns the system uptime in seconds.
	**/
	static function uptime():Int;

	/**
		Returns an array containing the 1, 5, and 15 minute load averages.

		The load average is a measure of system activity, calculated by the operating system and expressed as a fractional number.
		As a rule of thumb, the load average should ideally be less than the number of logical CPUs in the system.

		The load average is a very UNIX-y concept; there is no real equivalent on Windows platforms.
		That is why this function always returns [0, 0, 0] on Windows.
	**/
	static function loadavg():Array<Float>;

	/**
		Returns the total amount of system memory in bytes.
	**/
	static function totalmem():Float;

	/**
		Returns the amount of free system memory in bytes.
	**/
	static function freemem():Float;

	/**
		Returns an array of objects containing information about each CPU/core installed: model, speed (in MHz),
		and times (an object containing the number of milliseconds the CPU/core spent in: user, nice, sys, idle, and irq).
	**/
	static function cpus():Array<CPU>;

	/**
		Get a list of network interfaces:
	**/
	static function networkInterfaces():haxe.DynamicAccess<NetworkInterface>;
}
