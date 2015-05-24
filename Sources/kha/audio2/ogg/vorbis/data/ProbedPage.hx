package kha.audio2.ogg.vorbis.data;

/**
 * ...
 * @author shohei909
 */

class ProbedPage
{
    public var pageStart:Int;
    public var pageEnd:Int;
    public var afterPreviousPageStart:Int;
    public var firstDecodedSample:Null<Int>;
    public var lastDecodedSample:Null<Int>;

    public function new() {
    }
}
