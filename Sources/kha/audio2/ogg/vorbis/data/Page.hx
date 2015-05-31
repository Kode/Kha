package kha.audio2.ogg.vorbis.data;
import haxe.io.Bytes;
import haxe.io.Input;
import kha.audio2.ogg.vorbis.data.ReaderError.ReaderErrorType;
import kha.audio2.ogg.vorbis.VorbisDecodeState;

/**
 * ...
 * @author shohei909
 */
class Page {
    public var flag(default, null):Int;

    public function new () {

    }

    public function clone() {
        var page = new Page();
        page.flag = flag;
        return page;
    }

    // startPage
    public function start(decodeState:VorbisDecodeState) {
        decodeState.capturePattern();
        startWithoutCapturePattern(decodeState);
    }

    // startPageNoCapturePattern
    public function startWithoutCapturePattern(decodeState:VorbisDecodeState) {
        var version = decodeState.readByte();
        if (version != 0) {
            throw new ReaderError(ReaderErrorType.INVALID_STREAM_STRUCTURE_VERSION, "" + version);
        }

        this.flag = decodeState.readByte();
        var loc0 = decodeState.readInt32();
        var loc1 = decodeState.readInt32();

        // input serial number -- vorbis doesn't interleave, so discard
        decodeState.readInt32();
        //if (this.serial != get32(f)) throw new ReaderError(ReaderErrorType.incorrectStreamSerialNumber);

        // page sequence number
        decodeState.readInt32();

        // CRC32
        decodeState.readInt32();

        // pageSegments
        decodeState.setup(loc0, loc1);
    }
}

class PageFlag {
    static public inline var CONTINUED_PACKET = 1;
    static public inline var FIRST_PAGE = 2;
    static public inline var LAST_PAGE = 4;
}
