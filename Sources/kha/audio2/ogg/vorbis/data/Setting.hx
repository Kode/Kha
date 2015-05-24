package kha.audio2.ogg.vorbis.data;

/**
 * ...
 * @author shohei909
 */
class Setting
{
    static public inline var MAX_CHANNELS = 16;
    static public inline var PUSHDATA_CRC_COUNT = 4;
    static public inline var FAST_HUFFMAN_LENGTH = 10;
    static public inline var FAST_HUFFMAN_TABLE_SIZE = (1 << FAST_HUFFMAN_LENGTH);
    static public inline var FAST_HUFFMAN_TABLE_MASK = FAST_HUFFMAN_TABLE_SIZE - 1;

}
