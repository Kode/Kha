package kha.audio2.ogg.vorbis.data;
import haxe.ds.Vector;
import haxe.io.Input;
import kha.audio2.ogg.vorbis.data.ReaderError;
import kha.audio2.ogg.vorbis.VorbisDecodeState;

/**
 * ...
 * @author shohei909
 */
class Floor
{
    public var floor0:Floor0;
    public var floor1:Floor1;
    public var type:Int;

    function new()
    {

    }

    public static function read(decodeState:VorbisDecodeState, codebooks:Vector<Codebook>):Floor
    {
        var floor = new Floor();

        floor.type = decodeState.readBits(16);
        if (floor.type > 1) {
            throw new ReaderError(INVALID_SETUP);
        }
        if (floor.type == 0) {
            var g = floor.floor0 = new Floor0();
            g.order = decodeState.readBits(8);
            g.rate = decodeState.readBits(16);
            g.barkMapSize = decodeState.readBits(16);
            g.amplitudeBits = decodeState.readBits(6);
            g.amplitudeOffset = decodeState.readBits(8);
            g.numberOfBooks = decodeState.readBits(4) + 1;
            for (j in 0...g.numberOfBooks) {
                g.bookList[j] = decodeState.readBits(8);
            }
            throw new ReaderError(FEATURE_NOT_SUPPORTED);
        } else {
            var p = new Array<IntPoint>();
            var g = floor.floor1 = new Floor1();
            var maxClass = -1;
            g.partitions = decodeState.readBits(5);
            g.partitionClassList = new Vector(g.partitions);
            for (j in 0...g.partitions) {
                g.partitionClassList[j] = decodeState.readBits(4);
                if (g.partitionClassList[j] > maxClass) {
                    maxClass = g.partitionClassList[j];
                }
            }
            g.classDimensions = new Vector(maxClass + 1);
            g.classMasterbooks = new Vector(maxClass + 1);
            g.classSubclasses = new Vector(maxClass + 1);
            g.subclassBooks = new Vector(maxClass + 1);
            for (j in 0...(maxClass + 1)) {
                g.classDimensions[j] = decodeState.readBits(3) + 1;
                g.classSubclasses[j] = decodeState.readBits(2);
                if (g.classSubclasses[j] != 0) {
                    g.classMasterbooks[j] = decodeState.readBits(8);
                    if (g.classMasterbooks[j] >= codebooks.length) {
                        throw new ReaderError(INVALID_SETUP);
                    }
                }

                var kl = (1 << g.classSubclasses[j]);
                g.subclassBooks[j] = new Vector(kl);
                for (k in 0...kl) {
                    g.subclassBooks[j][k] = decodeState.readBits(8)-1;
                    if (g.subclassBooks[j][k] >= codebooks.length) {
                        throw new ReaderError(INVALID_SETUP);
                    }
                }
            }

            g.floor1Multiplier = decodeState.readBits(2) + 1;
            g.rangebits = decodeState.readBits(4);
            g.xlist = new Vector(31*8+2);
            g.xlist[0] = 0;
            g.xlist[1] = 1 << g.rangebits;
            g.values = 2;
            for (j in 0...g.partitions) {
                var c = g.partitionClassList[j];
                for (k in 0...g.classDimensions[c]) {
                    g.xlist[g.values] = decodeState.readBits(g.rangebits);
                    g.values++;
                }
            }

            // precompute the sorting
            for (j in 0...g.values) {
                p.push(new IntPoint());
                p[j].x = g.xlist[j];
                p[j].y = j;
            }

            p.sort(VorbisTools.pointCompare);

            g.sortedOrder = new Vector(g.values);
            for (j in 0...g.values) {
                g.sortedOrder[j] = p[j].y;
            }

            g.neighbors = new Vector(g.values);
            // precompute the neighbors
            for (j in 2...g.values) {
                var ne = VorbisTools.neighbors(g.xlist, j);
                g.neighbors[j] = new Vector(g.values);
                g.neighbors[j][0] = ne.low;
                g.neighbors[j][1] = ne.high;
            }
        }

        return floor;
    }
}

class Floor0
{
    public var order:Int; //uint8
    public var rate:Int; //uint16
    public var barkMapSize:Int; //uint16
    public var amplitudeBits:Int; //uint8
    public var amplitudeOffset:Int; //uint8
    public var numberOfBooks:Int; //uint8
    public var bookList:Vector<UInt>; //uint8 [16] varies

    public function new() {
    }
}

class Floor1
{
    public var partitions:Int; // uint8
    public var partitionClassList:Vector<Int>; // uint8 varies
    public var classDimensions:Vector<Int>; // uint8 [16] varies
    public var classSubclasses:Vector<Int>; // uint8 [16] varies
    public var classMasterbooks:Vector<Int>; // uint8 [16] varies
    public var subclassBooks:Vector<Vector<Int>>; //int 16 [16][8] varies
    public var xlist:Vector<Int>; //uint16 [31*8+2]  varies
    public var sortedOrder:Vector<Int>; //uint8 [31 * 8 + 2];
    public var neighbors:Vector<Vector<Int>>; //uint8[31 * 8 + 2][2];
    public var floor1Multiplier:Int;
    public var rangebits:Int;
    public var values:Int;

    public function new() {
    }
}
