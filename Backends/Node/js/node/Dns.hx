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
	Enumeration of possible `family` values for `Dns.lookup`.
**/
@:enum abstract DnsAddressFamily(Int) from Int to Int {
	var IPv4 = 4;
	var IPv6 = 6;
}

/**
	Enumeration of possible `rrtype` value for `Dns.resolve`.
**/
@:enum abstract DnsRrtype(String) from String to String {
	/**
		IPV4 addresses, default
	**/
	var A = "A";

	/**
		IPV6 addresses
	**/
	var AAAA = "AAAA";

	/**
		mail exchange records
	**/
	var MX = "MX";

	/**
		text records
	**/
	var TXT = "TXT";

	/**
		SRV records
	**/
	var SRV = "SRV";

	/**
		used for reverse IP lookups
	**/
	var PTR = "PTR";

	/**
		name server records
	**/
	var NS = "NS";

	/**
		canonical name records
	**/
	var CNAME = "CNAME";
}

/**
	Types of address data returned by `resolve` functions.
**/
typedef DnsResolvedAddressMX = {priority:Int, exchange:String};
typedef DnsResolvedAddressSRV = {priority:Int, weight:Int, port:Int, name:String};
typedef DnsResolvedAddress = haxe.extern.EitherType<String,haxe.extern.EitherType<DnsResolvedAddressMX,DnsResolvedAddressSRV>>;

/**
	Error objects returned by dns lookups are of this type
**/
extern class DnsError extends Error {
	/**
		Values for error codes are listed in `Dns` class.
	**/
	var code(default,null):String;
}

/**
	All methods in the dns module use C-Ares except for `lookup` which uses getaddrinfo(3) in a thread pool.
	C-Ares is much faster than getaddrinfo but the system resolver is more consistent with how other programs operate.
	When a user does `Net.connect(80, 'google.com')` or `Http.get({ host: 'google.com' })` the `lookup` method is used.
	Users who need to do a large number of lookups quickly should use the methods that go through C-Ares.
**/
@:jsRequire("dns")
extern class Dns {

	/**
		Resolves a `domain` (e.g. 'google.com') into the first found A (IPv4) or AAAA (IPv6) record.
		The `family` can be the integer 4 or 6. Defaults to null that indicates both Ip v4 and v6 address family.

		The `callback` has arguments (err, address, family).
		The `address` argument is a string representation of a IP v4 or v6 address.
		The `family` argument is either the integer 4 or 6 and denotes the family
		of address (not necessarily the value initially passed to lookup).

		Keep in mind that `err.code` will be set to 'ENOENT' not only when the domain does not exist but
		also when the lookup fails in other ways such as no available file descriptors.
	**/
	@:overload(function(domain:String, callback:DnsError->String->DnsAddressFamily->Void):Void {})
	static function lookup(domain:String, family:Null<DnsAddressFamily>, callback:DnsError->String->DnsAddressFamily->Void):Void;

	/**
		Resolves a `domain` (e.g. 'google.com') into an array of the record types specified by `rrtype`.

		The `callback` has arguments (err, addresses).
		The type of each item in `addresses` is determined by the record type,
		and described in the documentation for the corresponding lookup methods below.
	**/
	@:overload(function(domain:String, callback:DnsError->Array<DnsResolvedAddress>->Void):Void {})
	static function resolve(domain:String, rrtype:DnsRrtype, callback:DnsError->Array<DnsResolvedAddress>->Void):Void;

	/**
		The same as `resolve`, but only for IPv4 queries (A records).
		`addresses` is an array of IPv4 addresses (e.g. ['74.125.79.104', '74.125.79.105', '74.125.79.106']).
	**/
	static function resolve4(domain:String, callback:DnsError->Array<String>->Void):Void;

	/**
		The same as `resolve4` except for IPv6 queries (an AAAA query).
	**/
	static function resolve6(domain:String, callback:DnsError->Array<String>->Void):Void;

	/**
		The same as `resolve`, but only for mail exchange queries (MX records).
		`addresses` is an array of MX records, each with a priority
		and an exchange attribute (e.g. [{'priority': 10, 'exchange': 'mx.example.com'},...]).
	**/
	static function resolveMx(domain:String, callback:DnsError->Array<DnsResolvedAddressMX>->Void):Void;

	/**
		The same as `resolve`, but only for text queries (TXT records).
		`addresses` is an array of the text records available for `domain` (e.g., ['v=spf1 ip4:0.0.0.0 ~all']).
	**/
	static function resolveTxt(domain:String, callback:DnsError->Array<String>->Void):Void;

	/**
		The same as `resolve`, but only for service records (SRV records).
		`addresses` is an array of the SRV records available for `domain`.
		Properties of SRV records are priority, weight, port, and name
		(e.g., [{'priority': 10, 'weight': 5, 'port': 21223, 'name': 'service.example.com'}, ...]).
	**/
	static function resolveSrv(domain:String, callback:DnsError->Array<DnsResolvedAddressSRV>->Void):Void;

	/**
		The same as `resolve`, but only for name server records (NS records).
		`addresses` is an array of the name server records available for domain (e.g., ['ns1.example.com', 'ns2.example.com']).
	**/
	static function resolveNs(domain:String, callback:DnsError->Array<String>->Void):Void;

	/**
		The same as `resolve`, but only for canonical name records (CNAME records).
		`addresses` is an array of the canonical name records available for domain (e.g., ['bar.example.com']).
	**/
	static function resolveCname(domain:String, callback:DnsError->Array<String>->Void):Void;

	/**
		Reverse resolves an `ip` address to an array of domain names.
		The `callback` has arguments (err, domains).
	**/
	static function reverse(ip:String, callback:DnsError->Array<String>->Void):Void;


	// Each DNS query can return one of the following error codes
	// TODO: think of some kind of @:enum abstract pointing to these values so we can use that instead of strings

	/**
		DNS server returned answer with no data.
	**/
	static var NODATA(default,null):String;

	/**
		DNS server claims query was misformatted.
	**/
	static var FORMERR(default,null):String;

	/**
		DNS server returned general failure.
	**/
	static var SERVFAIL(default,null):String;

	/**
		Domain name not found.
	**/
	static var NOTFOUND(default,null):String;

	/**
		DNS server does not implement requested operation.
	**/
	static var NOTIMP(default,null):String;

	/**
		DNS server refused query.
	**/
	static var REFUSED(default,null):String;

	/**
		Misformatted DNS query.
	**/
	static var BADQUERY(default,null):String;

	/**
		Misformatted domain name.
	**/
	static var BADNAME(default,null):String;

	/**
		Unsupported address family.
	**/
	static var BADFAMILY(default,null):String;

	/**
		Misformatted DNS reply.
	**/
	static var BADRESP(default,null):String;

	/**
		Could not contact DNS servers.
	**/
	static var CONNREFUSED(default,null):String;

	/**
		Timeout while contacting DNS servers.
	**/
	static var TIMEOUT(default,null):String;

	/**
		End of file.
	**/
	static var EOF(default,null):String;

	/**
		Error reading file.
	**/
	static var FILE(default,null):String;

	/**
		Out of memory.
	**/
	static var NOMEM(default,null):String;

	/**
		Channel is being destroyed.
	**/
	static var DESTRUCTION(default,null):String;

	/**
		Misformatted string.
	**/
	static var BADSTR(default,null):String;

	/**
		Illegal flags specified.
	**/
	static var BADFLAGS(default,null):String;

	/**
		Given hostname is not numeric.
	**/
	static var NONAME(default,null):String;

	/**
		Illegal hints flags specified.
	**/
	static var BADHINTS(default,null):String;

	/**
		c-ares library initialization not yet performed.
	**/
	static var NOTINITIALIZED(default,null):String;

	/**
		Error loading iphlpapi.dll.
	**/
	static var LOADIPHLPAPI(default,null):String;

	/**
		Could not find GetNetworkParams function.
	**/
	static var ADDRGETNETWORKPARAMS(default,null):String;

	/**
		DNS query cancelled.
	**/
	static var CANCELLED(default,null):String;
}
