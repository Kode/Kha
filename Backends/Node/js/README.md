![hxnodejs](http://take.ms/dlXH9)

[![Build Status](https://travis-ci.org/HaxeFoundation/hxnodejs.svg?branch=master)](https://travis-ci.org/HaxeFoundation/hxnodejs)

# Haxe Node.JS

## Overview

Extern type definitions for Node.JS version **0.12.0** and Haxe **3.2+**.

Haxe-generated API documentation is available at http://haxefoundation.github.io/hxnodejs/js/Node.html.

Original node.js documentation can be found at http://nodejs.org/api/index.html.

## Features

 - Full node.js API with documentation.
 - Strict typing for everything, fully leveraging Haxe type system.
 - Optionally typed event listeners.
 - Automatic insert of "require" statements for used modules.
 - Clean output.

## Example
```haxe
class Main {
    static function main() {
        var server = js.node.Net.createServer(function(socket) {
            socket.write("Echo server\n\n");
            socket.pipe(socket);
        });
        server.listen(1337, "127.0.0.1");
    }
}
```
Generated JavaScript:
```js
(function () { "use strict";
var Main = function() { };
Main.main = function() {
	var server = js_node_Net.createServer(function(socket) {
		socket.write("Echo server\n\n");
		socket.pipe(socket);
	});
	server.listen(1337,"127.0.0.1");
};
var js_node_Net = require("net");
Main.main();
})();
```

## Status

This library is currently at **beta** stage, testing and contributions are welcome. See [current issues](https://github.com/HaxeFoundation/hxnodejs/issues) and [extern guidelines](https://github.com/HaxeFoundation/hxnodejs/blob/master/HOWTO.md). After it's finished, it will either be included in Haxe standard library or released as a separate haxelib.

Requires Haxe 3.2RC1 or later (builds available at http://builds.haxe.org/)

| module            | status | comment                  |
|-------------------|--------|--------------------------|
| assert            | done   |                          |
| Buffer            | done   |                          |
| child_processes   | done   |                          |
| cluster           | done   |                          |
| console           | done   |                          |
| crypto            | done   |                          |
| dns               | done   |                          |
| domain            | done   |                          |
| events            | done   |                          |
| fs                | done   |                          |
| Globals           | done   |                          |
| http              | done   |                          |
| https             | done   |                          |
| net               | done   |                          |
| os                | done   |                          |
| path              | done   |                          |
| process           | done   |                          |
| punycode          | done   |                          |
| querystring       | done   |                          |
| readline          | done   |                          |
| repl              | done   |                          |
| smalloc           | done   |                          |
| stream            | done   |                          |
| string_decoder    | done   |                          |
| tls               | wip    |                          |
| tty               | done   |                          |
| dgram             | done   |                          |
| url               | done   |                          |
| util              | done   |                          |
| vm                | done   |                          |
| zlib              | done   |                          |
