package kha.audio2.ogg.tools;
import haxe.ds.Vector;

/**
 * ...
 * @author shohei909
 */
class Crc32
{
    static inline var POLY:UInt = 0x04c11db7;
    static var table:Vector<UInt>;

    public static function init() {
        if (table != null) {
            return;
        }
        
        table = new Vector(256);
        for (i in 0...256) {
            var s:UInt = ((i:UInt) << (24:UInt));
            for (j in 0...8) {
                s = (s << 1) ^ (s >= ((1:UInt) << 31) ? POLY : 0);
            }
            table[i] = s;
        }
    }

    public static inline function update(crc:UInt, byte:UInt):UInt
    {
        return (crc << 8) ^ table[byte ^ (crc >>> 24)];
    }
}
