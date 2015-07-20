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

import haxe.DynamicAccess;

/**
	This module has utilities for URL resolution and parsing.
**/
@:jsRequire("url")
extern class Url {
	/**
		Take a URL string, and return an object.
		Pass true as `parseQueryString` to also parse the query string using the querystring module. Defaults to false.
		Pass true as `slashesDenoteHost` to treat //foo/bar as { host: 'foo', pathname: '/bar' } rather than { pathname: '//foo/bar' }. Defaults to false.
	**/
	static function parse(urlStr:String, ?parseQueryString:Bool, ?slashesDenoteHost:Bool):UrlData;

	/**
		Take a parsed URL object, and return a formatted URL string.
		* `href will be ignored.
		* `protocol` is treated the same with or without the trailing : (colon).
			* The protocols http, https, ftp, gopher, file will be postfixed with :// (colon-slash-slash).
			* All other protocols mailto, xmpp, aim, sftp, foo, etc will be postfixed with : (colon)
		* `slashes` set to true if the protocol requires :// (colon-slash-slash)
			* Only needs to be set for protocols not previously listed as requiring slashes, such as mongodb://localhost:8000/
		* `auth` will be used if present.
		* `hostname` will only be used if `host` is absent.
		* `port` will only be used if `host` is absent.
		* `host` will be used in place of `hostname` and `port`
		* `pathname` is treated the same with or without the leading / (slash)
		* `search` will be used in place of `query`
		* `query` (object) will only be used if `search` is absent.
		* `search` is treated the same with or without the leading ? (question mark)
		* `hash` is treated the same with or without the leading # (pound sign, anchor)
 	**/
	static function format(urlObj:UrlData):String;

	/**
		Take a base URL, and a href URL, and resolve them as a browser would for an anchor tag.
		Examples:
			resolve('/one/two/three', 'four')         // '/one/two/four'
			resolve('http://example.com/', '/one')    // 'http://example.com/one'
			resolve('http://example.com/one', '/two') // 'http://example.com/two'
	**/
	static function resolve(from:String, to:String):String;
}

/**
	Parsed URL objects have some or all of the following fields, depending on whether or not they exist in the URL string.
	Any parts that are not in the URL string will not be in the parsed object. TODO: actually when testing this, I found out that they are present but null
**/
typedef UrlData = {
	/**
		The full URL that was originally parsed. Both the protocol and host are lowercased.
		Example: 'http://user:pass@host.com:8080/p/a/t/h?query=string#hash'
	**/
	@:optional var href:String;

	/**
		The request protocol, lowercased.
		Example: 'http:'
	**/
	@:optional var protocol:String;

	/**
		The protocol requires slashes after the colon.
		Example: true or false
	**/
	@:optional var slashes:Bool;

	/**
		The full lowercased host portion of the URL, including port information.
		Example: 'host.com:8080'
	**/
	@:optional var host:String;

	/**
		The authentication information portion of a URL.
		Example: 'user:pass'
	**/
	@:optional var auth:String;

	/**
		Just the lowercased hostname portion of the host.
	**/
	@:optional var hostname:String;

	/**
		The port number portion of the host.
		Example: '8080'
	**/
	@:optional var port:String;

	/**
		The path section of the URL, that comes after the host and before the query,
		including the initial slash if present.
		Example: '/p/a/t/h'
	**/
	@:optional var pathname:String;

	/**
		The 'query string' portion of the URL, including the leading question mark.
		Example: '?query=string'
	**/
	@:optional var search:String;

	/**
		Concatenation of pathname and search.
		Example: '/p/a/t/h?query=string'
	**/
	@:optional var path:String;

	/**
		Either the 'params' portion of the query string, or a querystring - parsed object.
		Example: 'query=string' or {'query':'string'}

		The type of this field can be implicitly converted to String or DynamicAccess<String>,
		where either one is expected, so if you know the actual type, just assign it
		to properly typed variable (e.g. var s:String = url.query)
	**/
	@:optional var query:haxe.extern.EitherType<String,DynamicAccess<String>>;

	/**
		The 'fragment' portion of the URL including the pound - sign.
		Example: '#hash'
	**/
	@:optional var hash:String;
}
