package kha.flash;

import flash.events.AsyncErrorEvent;
import flash.events.NetStatusEvent;
import flash.media.VideoStatus;
import flash.net.NetConnection;
import flash.net.NetStream;


class Video extends kha.Video {
	private var finished: Bool = false;
	private var filename: String;
	private var looping: Bool = false;
	public var stream: NetStream;
	
	public function new(filename: String) {
		super();
		this.filename = filename;
	}
	
	private function asyncErrorHandler(event: AsyncErrorEvent): Void {
		trace("Error loading " + filename);
	}
	
	private function statusHandler(event: NetStatusEvent): Void {
		switch (event.info.code) {
			case 'NetStream.Play.Stop': 
				if (looping) {
					stream.pause();
					stream.seek(0);
					stream.resume();
				}
				else {
					finished = true;
				}
			case 'NetStream.Play.StreamNotFound':
				trace(filename + ' not found');
		}
	}
	
	public override function play(loop: Bool = false) : Void {
		looping = loop;
		
		if (finished) stop();
		
		if (stream == null) {
			finished = false;
			var connection = new NetConnection();
			connection.connect(null);
			stream = new NetStream(connection);
			stream.client = { onMetaData: function(obj: Dynamic): Void { } };
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler); 
			stream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			stream.play(filename);
		}
		else {
			stream.resume();
		}
	}
	
	public override function pause(): Void {
		stream.pause();
		finished = false;
	}

	public override function stop(): Void {
		if (stream != null) {
			stream.close();
			stream = null;
			finished = false;
		}
	}
	
	public override function getCurrentPos(): Int {
		return Std.int(stream.time * 1000); // Miliseconds
	}
	
	public override function isFinished(): Bool {
		return finished;
	}
}
