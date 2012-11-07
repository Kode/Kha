package kha.flash;
import flash.events.AsyncErrorEvent;
import flash.events.NetStatusEvent;
import flash.media.VideoStatus;
import flash.net.NetConnection;
import flash.net.NetStream;


class Video extends kha.Video {
	var finished : Bool = false;
	var filename : String;
	public var stream : NetStream;
	
	public function new(filename : String) {
		super();
		
		this.filename = filename;
		/*
		var connection = new NetConnection();
		connection.connect(null);
		stream = new NetStream(connection);
		stream.client = { onMetaData:function(obj:Dynamic):Void { } };
		stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler); 
		stream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
		stream.play(filename);
		finished = true;
		*/
	}
	
	function asyncErrorHandler(event:AsyncErrorEvent):Void { } // ignore error 
	function statusHandler(event:NetStatusEvent) : Void {
		switch (event.info.code)
		{
			/*case "NetStream.Play.Start":
				trace(filename + ": Start [" + Std.int(stream.time * 1000) / 1000 + " seconds]");*/
			case "NetStream.Play.Stop": 
				trace(filename + ": Stop [" + Std.int(stream.time * 1000) / 1000 + " seconds]");
				finished = true;
		}
	}
	
	public override function play() : Void {
		if (stream == null) {
			finished = false;
			var connection = new NetConnection();
			connection.connect(null);
			stream = new NetStream(connection);
			stream.client = { onMetaData:function(obj:Dynamic):Void { } };
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler); 
			stream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			stream.play(filename);
		}
		else
			stream.resume();
	}
	
	public override function pause() : Void {
		stream.pause();
		finished = false;
	}

	public override function stop() : Void {
		//stream.pause();
		//stream.seek(0);
		if (stream != null) {
			stream.close();
			stream = null;
			finished = false;
		}
	}
	
	public override function getCurrentPos() : Int {
		return Std.int(stream.time * 1000); // Miliseconds
	}
	
	public override function isFinished() : Bool {
		return finished;
	}

}
