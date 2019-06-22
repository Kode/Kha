package kha;

import haxe.macro.Context;
import haxe.macro.Expr;

#if macro
import kha.internal.AssetsBuilder;
import sys.io.File;
#end

using haxe.macro.ExprTools;

#if kha_html5
class Worker {
	#if kha_in_worker

	public static function notifyWorker(func: Dynamic->Void): Void {
		#if !macro
		untyped __js__("self").addEventListener("message", function (e) {
			func(e.data);
		});
		#end
	}

	public static function postFromWorker(message: Dynamic): Void {
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
		return Context.parse("kha.Worker._create(\"" + name + ".js\")", Context.currentPos());
	}

	#end
}
#end

#if kha_kore

import sys.thread.Thread;
import kha.Scheduler;

class Worker {
	public static var _mainThread: Thread;
	var thread: Thread;

	function new(thread: Thread) {
		this.thread = thread;
	}

	public static function create(clazz: Class<Dynamic>): Worker {
		return new Worker(Thread.create(Reflect.field(clazz, "main")));
	}

	public function notify(func: Dynamic->Void): Void {
		Scheduler.addFrameTask(function () {
			var message = Thread.readMessage(false);
			if (message != null) {
				func(message);
			}
		}, 0);
	}

	public function post(message: Dynamic): Void {
		thread.sendMessage(message);
	}

	public static function notifyWorker(func: Dynamic->Void): Void {
		while (true) {
			var message = Thread.readMessage(true);
			if (message != null) {
				func(message);
			}
		}
	}

	public static function postFromWorker(message: Dynamic): Void {
		_mainThread.sendMessage(message);
	}
}
#end
