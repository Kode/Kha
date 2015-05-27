package kha.audio2.ogg.vorbis.data;
import haxe.io.Input;
import kha.audio2.ogg.vorbis.VorbisDecodeState;

class Mode
{
    public var blockflag:Bool; // uint8 
    public var mapping:Int;   // uint8 
    public var windowtype:Int;    // uint16 
    public var transformtype:Int; // uint16 
    
    public function new() {
    }
    
    public static function read(decodeState:VorbisDecodeState) {
        var m = new Mode();
        m.blockflag = (decodeState.readBits(1) != 0);
        m.windowtype = decodeState.readBits(16);
        m.transformtype = decodeState.readBits(16);
        m.mapping = decodeState.readBits(8);
        if (m.windowtype != 0) {
            throw new ReaderError(INVALID_SETUP);
        }
        if (m.transformtype != 0) {
            throw new ReaderError(INVALID_SETUP);
        }
        return m;
    }
}