package kha.audio2.ogg.vorbis.flash;

import flash.events.IEventDispatcher;
import flash.events.SampleDataEvent;
import flash.media.SoundTransform;
import flash.media.Sound;
import flash.media.SoundChannel;
import haxe.io.Bytes;
import kha.audio2.ogg.vorbis.Reader;

class VorbisSound {
    var rootReader:Reader;
    public var length(default, null):Float;

    public function new(bytes:Bytes) {
        rootReader = Reader.openFromBytes(bytes);
        length = rootReader.totalMillisecond;
    }

    public function play(startMillisecond:Float, loops:Int = 0, ?sndTransform:SoundTransform):VorbisSoundChannel {
        var sound = new Sound();
        var reader = rootReader.clone();
        var startSample = reader.millisecondToSample(startMillisecond);
        var loopStart = startSample;
        var loopEnd = rootReader.totalSample;

        if (rootReader.loopStart != null) {
            loopStart = rootReader.loopStart;
            if (rootReader.loopLength != null) {
                loopEnd = rootReader.loopStart + rootReader.loopLength;
            }
        }

        return VorbisSoundChannel.play(sound, reader, startSample, loops, loopStart, loopEnd, sndTransform);
    }
}
