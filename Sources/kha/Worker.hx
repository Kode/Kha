package kha;

import haxe.macro.Context;
import haxe.macro.Expr;

#if macro
import kha.internal.AssetsBuilder;
import sys.io.File;
#end

using haxe.macro.ExprTools;

class Worker {
	#if kha_in_worker
	
	public static function notify(func: Dynamic->Void): Void {
		#if !macro
		untyped __js__("self").addEventListener("message", function (e) {
			func(e.data);
		});
		#end
	}

	public static function post(message: Dynamic): Void {
		#if !macro
		untyped __js__("self").postMessage(message);
		#end
	}

	#else
	
	#if macro
	static var threads = new Array<String>();
	#else
	var worker: js.html.Worker;
	#end

	function new(file: String) {
		#if !macro
		worker = new js.html.Worker(file);
		#end
	}

	@:noCompletion
	public static function _create(file: String): Worker {
		return new Worker(file);
	}

	public function notify(func: Dynamic->Void): Void {
		#if !macro
		worker.addEventListener("message", function (e) {
			func(e.data);
		});
		#end
	}

	public function post(message: Dynamic): Void {
		#if !macro
		worker.postMessage(message);
		#end
	}
	
	public static macro function create(expr: Expr) {
		var name: String = expr.toString();
		if (threads.indexOf(name) < 0) {
			threads.push(name);
		}
		var threadstring = "";
		for (thread in threads) {
			threadstring += thread + "\n";
		}
		File.saveContent(AssetsBuilder.findResources() + "workers.txt", threadstring);
		return Context.parse("kha.Worker._create(\"" + name + ".js\")", Context.currentPos()); //Context.parse("new js.html.Worker(\"" + func.toString() + ".js\")", Context.currentPos());
	}

	#end
}

/*
class Worker {
	public static macro function run(clazz: Expr) {
		return Context.parse(clazz.toString() + ".main()", Context.currentPos());
	}
}
*/
