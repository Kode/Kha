package kha.arrays;

import js.lib.DataView;

@:forward
abstract ByteArray(DataView) to DataView
{
    public var buffer(get, never):ByteBuffer;
    function get_buffer() : ByteBuffer
    {
        return cast this.buffer;
    }
    
    public function new(buffer:ByteBuffer, ?byteOffset:Int, ?byteLength:Int)
    {
        this = new DataView(buffer, byteOffset, byteLength);
    }

    static public function make(byteLength:Int) : ByteArray
    {
        return new ByteArray(new ByteBuffer(byteLength));
    }

    public function subarray(start:Int, ?end:Int) : ByteArray
    {
        return new ByteArray(buffer, start, end != null ? end - start : null);
    }
}
