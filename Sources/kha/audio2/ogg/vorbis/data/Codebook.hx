package kha.audio2.ogg.vorbis.data;
import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.Input;
import kha.audio2.ogg.tools.MathTools;
import kha.audio2.ogg.vorbis.data.ReaderError.ReaderErrorType;
import kha.audio2.ogg.vorbis.VorbisDecodeState;

/**
 * ...
 * @author shohei909
 */
class Codebook
{
    static public inline var NO_CODE = 255;

    public var dimensions:Int;
    public var entries:Int;
    public var codewordLengths:Vector<Int>; //uint8*
    public var minimumValue:Float;
    public var deltaValue:Float;
    public var valueBits:Int; //uint8
    public var lookupType:Int; //uint8
    public var sequenceP:Bool; //uint8
    public var sparse:Bool; //uint8
    public var lookupValues:UInt; //uint32
    public var multiplicands:Vector<Float>; // codetype *
    public var codewords:Vector<UInt>; //uint32*
    public var fastHuffman:Vector<Int>; //[FAST_HUFFMAN_TABLE_SIZE];
    public var sortedCodewords:Array<UInt>; //uint32*
    public var sortedValues:Vector<Int>;
    public var sortedEntries:Int;

    public function new () {
    }

    static public function read(decodeState:VorbisDecodeState):Codebook {
        var c = new Codebook();
        if (decodeState.readBits(8) != 0x42 || decodeState.readBits(8) != 0x43 || decodeState.readBits(8) != 0x56) {
            throw new ReaderError(ReaderErrorType.INVALID_SETUP);
        }

        var x = decodeState.readBits(8);
        c.dimensions = (decodeState.readBits(8) << 8) + x;

        var x = decodeState.readBits(8);
        var y = decodeState.readBits(8);
        c.entries = (decodeState.readBits(8) << 16) + (y << 8) + x;
        var ordered = decodeState.readBits(1);
        c.sparse = (ordered != 0) ? false : (decodeState.readBits(1) != 0);

        var lengths = new Vector(c.entries);
        if (!c.sparse) {
            c.codewordLengths = lengths;
        }

        var total = 0;

        if (ordered != 0) {
            var currentEntry = 0;
            var currentLength = decodeState.readBits(5) + 1;

            while (currentEntry < c.entries) {
                var limit = c.entries - currentEntry;
                var n = decodeState.readBits(MathTools.ilog(limit));
                if (currentEntry + n > c.entries) {
                    throw new ReaderError(ReaderErrorType.INVALID_SETUP, "codebook entrys");
                }
                for (i in 0...n) {
                    lengths.set(currentEntry + i, currentLength);
                }
                currentEntry += n;
                currentLength++;
            }
        } else {
            for (j in 0...c.entries) {
                var present = (c.sparse) ? decodeState.readBits(1) : 1;
                if (present != 0) {
                    lengths.set(j, decodeState.readBits(5) + 1);
                    total++;
                } else {
                    lengths.set(j, NO_CODE);
                }
            }
        }

        if (c.sparse && total >= (c.entries >> 2)) {
            c.codewordLengths = lengths;
            c.sparse = false;
        }

        c.sortedEntries = if (c.sparse) {
            total;
        } else {
            var sortedCount = 0;
            for (j in 0...c.entries) {
                var l = lengths.get(j);
                if (l > Setting.FAST_HUFFMAN_LENGTH && l != NO_CODE) {
                    ++sortedCount;
                }
            }
            sortedCount;
        }

        var values:Vector<UInt> = null;

        if (!c.sparse) {
            c.codewords = new Vector<UInt>(c.entries);
        } else {
            if (c.sortedEntries != 0) {
                c.codewordLengths = new Vector(c.sortedEntries);
                c.codewords = new Vector<UInt>(c.entries);
                values = new Vector<UInt>(c.entries);
            }

            var size:Int = c.entries + (32 + 32) * c.sortedEntries;
        }

        if (!c.computeCodewords(lengths, c.entries, values)) {
            throw new ReaderError(ReaderErrorType.INVALID_SETUP, "compute codewords");
        }

        if (c.sortedEntries != 0) {
            // allocate an extra slot for sentinels
            c.sortedCodewords = [];

            // allocate an extra slot at the front so that sortedValues[-1] is defined
            // so that we can catch that case without an extra if
            c.sortedValues = new Vector<Int>(c.sortedEntries);
            c.computeSortedHuffman(lengths, values);
        }

        if (c.sparse) {
            values = null;
            c.codewords = null;
            lengths = null;
        }

        c.computeAcceleratedHuffman();

        c.lookupType = decodeState.readBits(4);
        if (c.lookupType > 2) {
            throw new ReaderError(ReaderErrorType.INVALID_SETUP, "codebook lookup type");
        }

        if (c.lookupType > 0) {
            c.minimumValue = VorbisTools.floatUnpack(decodeState.readBits(32));
            c.deltaValue = VorbisTools.floatUnpack(decodeState.readBits(32));
            c.valueBits = decodeState.readBits(4) + 1;
            c.sequenceP = (decodeState.readBits(1) != 0);

            if (c.lookupType == 1) {
                c.lookupValues = VorbisTools.lookup1Values(c.entries, c.dimensions);
            } else {
                c.lookupValues = c.entries * c.dimensions;
            }
            var mults = new Vector<Int>(c.lookupValues);
            for (j in 0...c.lookupValues) {
                var q = decodeState.readBits(c.valueBits);
                if (q == VorbisTools.EOP) {
                    throw new ReaderError(ReaderErrorType.INVALID_SETUP, "fail lookup");
                }
                mults[j] = q;
            }

            {
                c.multiplicands = new Vector(c.lookupValues);

                //STB_VORBIS_CODEBOOK_FLOATS = true
                for (j in 0...c.lookupValues) {
                    c.multiplicands[j] = mults[j] * c.deltaValue + c.minimumValue;
                }
            }

            //STB_VORBIS_CODEBOOK_FLOATS = true
            if (c.lookupType == 2 && c.sequenceP) {
                for (j in 1...c.lookupValues) {
                    c.multiplicands[j] = c.multiplicands[j - 1];
                }
                c.sequenceP = false;
            }
        }

        return c;
    }

    inline function addEntry(huffCode:UInt, symbol:Int, count:Int, len:Int, values:Vector<UInt>)
    {
        if (!sparse) {
            codewords[symbol] = huffCode;
        } else {
            codewords[count] = huffCode;
            codewordLengths.set(count, len);
            values[count] = symbol;
        }
    }

    inline function includeInSort(len:Int)
    {
        return if (sparse) {
            VorbisTools.assert(len != NO_CODE);
            true;
        } else if (len == NO_CODE) {
            false;
        } else if (len > Setting.FAST_HUFFMAN_LENGTH) {
            true;
        } else {
            false;
        }
    }


    function computeCodewords(len:Vector<Int>, n:Int, values:Vector<UInt>)
    {
        var available = new Vector<UInt>(32);
        for (x in 0...32) available[x] = 0;

        // find the first entry
        var k = 0;
        while (k < n) {
            if (len.get(k) < NO_CODE) {
                break;
            }
            k++;
        }

        if (k == n) {
            VorbisTools.assert(sortedEntries == 0);
            return true;
        }

        var m = 0;

        // add to the list
        addEntry(0, k, m++, len.get(k), values);

        // add all available leaves
        var i = 0;

        while (++i <= len.get(k)) {
            available[i] = (1:UInt) << ((32 - i):UInt);
        }

        // note that the above code treats the first case specially,
        // but it's really the same as the following code, so they
        // could probably be combined (except the initial code is 0,
        // and I use 0 in available[] to mean 'empty')
        i = k;
        while (++i < n) {
            var z = len.get(i);
            if (z == NO_CODE) continue;

            // find lowest available leaf (should always be earliest,
            // which is what the specification calls for)
            // note that this property, and the fact we can never have
            // more than one free leaf at a given level, isn't totally
            // trivial to prove, but it seems true and the assert never
            // fires, so!
            while (z > 0 && available[z] == 0) --z;
            if (z == 0) {
                return false;
            }

            var res:UInt = available[z];
            available[z] = 0;
            addEntry(VorbisTools.bitReverse(res), i, m++, len.get(i), values);

            // propogate availability up the tree
            if (z != len.get(i)) {
                var y = len.get(i);
                while (y > z) {
                    VorbisTools.assert(available[y] == 0);
                    available[y] = res + (1 << (32 - y));
                    y--;
                }
            }
        }

        return true;
    }


    function computeSortedHuffman(lengths:Vector<Int>, values:Vector<UInt>)
    {
        // build a list of all the entries
        // OPTIMIZATION: don't include the short ones, since they'll be caught by FAST_HUFFMAN.
        // this is kind of a frivolous optimization--I don't see any performance improvement,
        // but it's like 4 extra lines of code, so.
        if (!sparse) {
            var k = 0;
            for (i in 0...entries) {
                if (includeInSort(lengths.get(i))) {
                    sortedCodewords[k++] = VorbisTools.bitReverse(codewords[i]);
                }
            }
            VorbisTools.assert(k == sortedEntries);
        } else {
            for (i in 0...sortedEntries) {
                sortedCodewords[i] = VorbisTools.bitReverse(codewords[i]);
            }
        }

        sortedCodewords[sortedEntries] = 0xffffffff;
        sortedCodewords.sort(VorbisTools.uintAsc);

        var len = sparse ? sortedEntries : entries;
        // now we need to indicate how they correspond; we could either
        //    #1: sort a different data structure that says who they correspond to
        //    #2: for each sorted entry, search the original list to find who corresponds
        //    #3: for each original entry, find the sorted entry
        // #1 requires extra storage, #2 is slow, #3 can use binary search!
        for (i in 0...len) {
            var huffLen = sparse ? lengths.get(values[i]) : lengths.get(i);
            if (includeInSort(huffLen)) {
                var code = VorbisTools.bitReverse(codewords[i]);
                var x = 0;
                var n = sortedEntries;
                while (n > 1) {
                    // invariant: sc[x] <= code < sc[x+n]
                    var m = x + (n >> 1);
                    if (sortedCodewords[m] <= code) {
                        x = m;
                        n -= (n>>1);
                    } else {
                        n >>= 1;
                    }
                }

                //VorbisTools.assert(sortedCodewords[x] == code);
                if (sparse) {
                    sortedValues[x] = values[i];
                    codewordLengths.set(x, huffLen);
                } else {
                    sortedValues[x] = i;
                }
            }
        }
    }

    function computeAcceleratedHuffman()
    {
        fastHuffman = new Vector(Setting.FAST_HUFFMAN_TABLE_SIZE);
        fastHuffman[0] = -1;
        for (i in 0...(Setting.FAST_HUFFMAN_TABLE_SIZE)) {
            fastHuffman[i] =  -1;
        }

        var len = (sparse) ? sortedEntries : entries;

        //STB_VORBIS_FAST_HUFFMAN_SHORT
        //if (len > 32767) len = 32767; // largest possible value we can encode!

        for (i in 0...len) {
            if (codewordLengths[i] <= Setting.FAST_HUFFMAN_LENGTH) {
                var z:Int = (sparse) ? VorbisTools.bitReverse(sortedCodewords[i]) : codewords[i];
                // set table entries for all bit combinations in the higher bits
                while (z < Setting.FAST_HUFFMAN_TABLE_SIZE) {
                    fastHuffman[z] = i;
                    z += 1 << codewordLengths[i];
                }
            }
        }

    }

    function codebookDecode(decodeState:VorbisDecodeState, output:Vector<Float>, offset:Int, len:Int)
    {
        var z = decodeStart(decodeState);
        var lookupValues = this.lookupValues;
        var sequenceP = this.sequenceP;
        var multiplicands = this.multiplicands;
        var minimumValue = this.minimumValue;

        if (z < 0) {
            return false;
        }
        if (len > dimensions) {
            len = dimensions;
        }

        // STB_VORBIS_DIVIDES_IN_CODEBOOK = true
        if (lookupType == 1) {
            var div = 1;
            var last = 0.0;
            for (i in 0...len) {
                var off = Std.int(z / div) % lookupValues;
                var val = multiplicands[off] + last;
                output[offset + i] += val;
                if (sequenceP) {
                    last = val + minimumValue;
                }
                div *= lookupValues;
            }
            return true;
        }

        z *= dimensions;
        if (sequenceP) {
            var last = 0.0;
            for (i in 0...len) {
                var val = multiplicands[z + i] + last;
                output[offset + i] += val;
                last = val + minimumValue;
            }
        } else {
            var last = 0.0;
            for (i in 0...len) {
                output[offset + i] += multiplicands[z + i] + last;
            }
        }
        return true;
    }

    function codebookDecodeStep(decodeState:VorbisDecodeState, output:Vector<Float>, offset:Int, len:Int, step:Int)
    {
        var z = decodeStart(decodeState);
        var last = 0.0;
        if (z < 0) {
            return false;
        }
        if (len > dimensions) {
            len = dimensions;
        }

        var lookupValues = this.lookupValues;
        var sequenceP = this.sequenceP;
        var multiplicands = this.multiplicands;

        // STB_VORBIS_DIVIDES_IN_CODEBOOK = true

        if (lookupType == 1) {
            var div = 1;
            for (i in 0...len) {
                var off = Std.int(z / div) % lookupValues;
                var val = multiplicands[off] + last;
                output[offset + i * step] += val;
                if (sequenceP) {
                    last = val;
                }
                div *= lookupValues;
            }
            return true;
        }

        z *= dimensions;
        for (i in 0...len) {
            var val = multiplicands[z + i] + last;
            output[offset + i * step] += val;
            if (sequenceP) {
                last = val;
            }
        }

        return true;
    }

    inline function decodeStart(decodeState:VorbisDecodeState)
    {
        return decodeState.decode(this);

        //var z = -1;
        //// type 0 is only legal in a scalar context
        //if (lookupType == 0) {
        //    throw new ReaderError(INVALID_STREAM);
        //} else {
        //    z = decodeState.decode(this);
        //    //if (sparse) VorbisTools.assert(z < sortedEntries);
        //    if (z < 0) {  // check for VorbisTools.EOP
        //        if (decodeState.isLastByte()) {
        //            return z;
        //        } else {
        //            throw new ReaderError(INVALID_STREAM);
        //        }
        //    } else {
        //        return z;
        //    }
        //}
    }

    static var delay = 0;

    public function decodeDeinterleaveRepeat(decodeState:VorbisDecodeState, residueBuffers:Vector<Vector<Float>>, ch:Int, cInter:Int, pInter:Int, len:Int, totalDecode:Int)
    {
        var effective = dimensions;

        // type 0 is only legal in a scalar context
        if (lookupType == 0) {
            throw new ReaderError(INVALID_STREAM);
        }

        var multiplicands = this.multiplicands;
        var sequenceP = this.sequenceP;
        var lookupValues = this.lookupValues;

        while (totalDecode > 0) {
            var last = 0.0;
            var z = decodeState.decode(this);

            if (z < 0) {
                if (decodeState.isLastByte()) {
                    return null;
                }
                throw new ReaderError(INVALID_STREAM);
            }

            // if this will take us off the end of the buffers, stop short!
            // we check by computing the length of the virtual interleaved
            // buffer (len*ch), our current offset within it (pInter*ch)+(cInter),
            // and the length we'll be using (effective)
            if (cInter + pInter * ch + effective > len * ch) {
                effective = len * ch - (pInter * ch - cInter);
            }

            if (lookupType == 1) {
                var div = 1;
                if (sequenceP) {
                    for (i in 0...effective) {
                        var off = Std.int(z / div) % lookupValues;
                        var val = multiplicands[off] + last;
                        residueBuffers[cInter][pInter] += val;
                        if (++cInter == ch) {
                            cInter = 0;
                            ++pInter;
                        }
                        last = val;
                        div *= lookupValues;
                    }
                } else {
                    for (i in 0...effective) {
                        var off = Std.int(z / div) % lookupValues;
                        var val = multiplicands[off] + last;
                        residueBuffers[cInter][pInter] += val;
                        if (++cInter == ch) {
                            cInter = 0;
                            ++pInter;
                        }
                        div *= lookupValues;
                    }
                }
            } else {
                z *= dimensions;
                if (sequenceP) {
                    for (i in 0...effective) {
                        var val = multiplicands[z + i] + last;
                        residueBuffers[cInter][pInter] += val;
                        if (++cInter == ch) {
                            cInter = 0;
                            ++pInter;
                        }
                        last = val;
                    }
                } else {
                    for (i in 0...effective) {
                        var val = multiplicands[z + i] + last;
                        residueBuffers[cInter][pInter] += val;
                        if (++cInter == ch) {
                            cInter = 0;
                            ++pInter;
                        }
                    }
                }
            }

            totalDecode -= effective;
        }

        return {
            cInter : cInter,
            pInter : pInter
        }
    }

    public function residueDecode(decodeState:VorbisDecodeState, target:Vector<Float>, offset:Int, n:Int, rtype:Int)
    {
        if (rtype == 0) {
            var step = Std.int(n / dimensions);
            for (k in 0...step) {
                if (!codebookDecodeStep(decodeState, target, offset + k, n-offset-k, step)) {
                    return false;
                }
            }
        } else {
            var k = 0;
            while(k < n) {
                if (!codebookDecode(decodeState, target, offset, n-k)) {
                    return false;
                }
                k += dimensions;
                offset += dimensions;
            }
        }
        return true;
    }
}
