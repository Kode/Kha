package kha.audio2.ogg.vorbis;

import haxe.ds.Vector;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.Eof;
import haxe.io.Input;
import haxe.io.Output;
import kha.audio2.ogg.tools.Crc32;
import kha.audio2.ogg.tools.MathTools;
import kha.audio2.ogg.vorbis.data.Codebook;
import kha.audio2.ogg.vorbis.data.Floor.Floor1;
import kha.audio2.ogg.vorbis.data.Header;
import kha.audio2.ogg.vorbis.data.Mode;
import kha.audio2.ogg.vorbis.data.Page;
import kha.audio2.ogg.vorbis.data.ProbedPage;
import kha.audio2.ogg.vorbis.data.ReaderError;
import kha.audio2.ogg.vorbis.data.Page;
import kha.audio2.ogg.vorbis.data.Residue;
import kha.audio2.ogg.vorbis.data.Setting;
import kha.audio2.ogg.vorbis.VorbisDecoder.DecodeInitialResult;

/**
 * ...
 * @author shohei909
 */
class VorbisDecodeState
{
    public static inline var INVALID_BITS = -1;

    public var page(default, null):Page;
    public var eof(default, null):Bool;
    public var pFirst(default, null):ProbedPage;
    public var pLast(default, null):ProbedPage;
    public var validBits(default, null):Int = 0;
    public var inputPosition(default, null):Int;
    public var input(default, null):Input;
    public var discardSamplesDeferred:Int;
    public var segments(default, null):Vector<Int>;
    public var bytesInSeg:Int = 0; // uint8

    // decode buffer
    public var channelBuffers:Vector<Vector<Float>>; //var *[STB_VORBIS_MAX_CHANNELS];
    public var channelBufferStart:Int;
    public var channelBufferEnd:Int;
    public var currentSample(default, null):Int;

    public var previousWindow:Vector<Vector<Float>>; //var *[STB_VORBIS_MAX_CHANNELS];
    public var previousLength:Int;
    public var finalY:Vector<Array<Int>>; // [STB_VORBIS_MAX_CHANNELS];


    var firstDecode:Bool = false;
    var nextSeg:Int = 0;

    var acc:UInt;
    var lastSeg:Bool;  // flag that we're on the last decodeState
    var lastSegWhich:Int; // what was the decodeState number of the l1ast seg?

    var endSegWithKnownLoc:Int;
    var knownLocForPacket:Int;

    var error:ReaderError;

    var currentLoc:Int; //uint32  sample location of next frame to decode
    var currentLocValid:Int;

    var firstAudioPageOffset:UInt;

    public function new(input:Input)
    {
        this.input = input;
        inputPosition = 0;
        page = new Page();
        Crc32.init();
    }

    public function setup(loc0:Int, loc1:Int) {
        var segmentCount = readByte();
        this.segments = read(segmentCount);

        // assume we Don't_ know any the sample position of any segments
        this.endSegWithKnownLoc = -2;
        if (loc0 != 0xFFFFFFFF || loc1 != 0xFFFFFFFF) {
            var i:Int = segmentCount - 1;
            while (i >= 0) {
                if (segments.get(i) < 255) {
                    break;
                }
                if (i >= 0) {
                    this.endSegWithKnownLoc = i;
                    this.knownLocForPacket = loc0;
                }
                i--;
            }
        }

        if (firstDecode) {
            var i:Int = 0;
            var len:Int = 0;
            var p = new ProbedPage();

            for (i in 0...segmentCount) {
                len += segments.get(i);
            }
            len += 27 + segmentCount;

            p.pageStart = firstAudioPageOffset;
            p.pageEnd = p.pageStart + len;
            p.firstDecodedSample = 0;
            p.lastDecodedSample = loc0;
            pFirst = p;
        }

        nextSeg = 0;
    }

    public function clone(seekFunc:Int->Void)
    {
        var state = Type.createEmptyInstance(VorbisDecodeState);

        seekFunc(inputPosition);
        state.input = input;

        // primitive
        state.eof = eof;
        state.validBits = validBits;
        state.discardSamplesDeferred = discardSamplesDeferred;
        state.firstDecode = firstDecode;
        state.nextSeg = nextSeg;
        state.bytesInSeg = bytesInSeg;
        state.acc = state.acc;
        state.lastSeg = lastSeg;
        state.lastSegWhich = lastSegWhich;
        state.currentLoc = currentLoc;
        state.currentLocValid = currentLocValid;
        state.inputPosition = inputPosition;
        state.firstAudioPageOffset = firstAudioPageOffset;

        // sharrow copy
        state.error = error;
        state.segments = segments;
        state.pFirst = pFirst;
        state.pLast = pLast;

        // deep copy
        state.page = page.clone();

        return state;
    }


    // nextSegment
    public function next():Int {
        if (lastSeg) {
            return 0;
        }

        if (nextSeg == -1) {
            lastSegWhich = segments.length - 1; // in case startPage fails

            try {
                page.start(this);
            } catch(e:ReaderError) {
                lastSeg = true;
                error = e;
                return 0;
            }

            if ((page.flag & PageFlag.CONTINUED_PACKET) == 0) {
                throw new ReaderError(ReaderErrorType.CONTINUED_PACKET_FLAG_INVALID);
            }
        }

        var len = segments.get(nextSeg++);
        if (len < 255) {
            lastSeg = true;
            lastSegWhich = nextSeg - 1;
        }
        if (nextSeg >= segments.length) {
            nextSeg = -1;
        }

        VorbisTools.assert(bytesInSeg == 0);
        bytesInSeg = len;
        return len;
    }

    public function startPacket() {
        while (nextSeg == -1) {
            page.start(this);
            if ((page.flag & PageFlag.CONTINUED_PACKET) != 0) {
                throw new ReaderError(ReaderErrorType.MISSING_CAPTURE_PATTERN);
            }
        }

        lastSeg = false;
        validBits = 0;
        bytesInSeg = 0;
    }

    public function maybeStartPacket():Bool
    {
        if (nextSeg == -1) {
            var eof = false;
            var x = try {
                readByte();
            } catch (e:Eof) {
                eof = true;
                0;
            }

            if (eof) {
                return false; // EOF at page boundary is not an error!
            }

            if (x != 0x4f || readByte() != 0x67 || readByte() != 0x67 || readByte() != 0x53) {
                throw new ReaderError(ReaderErrorType.MISSING_CAPTURE_PATTERN);
            }

            page.startWithoutCapturePattern(this);
        }

        startPacket();
        return true;
    }



    public inline function readBits(n:Int):Int
    {
        if (validBits < 0) {
            return 0;
        } else if (validBits < n) {
            if (n > 24) {
                // the accumulator technique below would not work correctly in this case
                return readBits(24) + ((readBits(n - 24) << 24));
            } else {
                if (validBits == 0) {
                    acc = 0;
                }

                do {
                    if (bytesInSeg == 0 && (lastSeg || next() == 0)) {
                        validBits = INVALID_BITS;
                        break;
                    } else {
                        bytesInSeg--;
                        acc += (readByte() << validBits);
                        validBits += 8;
                    }
                } while (validBits < n);

                if (validBits < 0) {
                    return 0;
                } else {
                    var z = acc & ((1 << n) - 1);
                    acc >>>= n;
                    validBits -= n;
                    return z;
                }
            }
        } else {
            var z = acc & ((1 << n) - 1);
            acc >>>= n;
            validBits -= n;
            return z;
        }
    }
    inline function readPacketRaw():Int {
        return if (bytesInSeg == 0 && (lastSeg || next() == 0)) {  // CLANG!
            VorbisTools.EOP;
        } else {
            //VorbisTools.assert(bytesInSeg > 0);
            bytesInSeg--;
            readByte();
        }
    }

    public inline function readPacket():Int
    {
        var x = readPacketRaw();
        validBits = 0;
        return x;
    }

    public inline function flushPacket():Void {
        while (bytesInSeg != 0 || (!lastSeg && next() != 0)) {
            bytesInSeg--;
            readByte();
        }
    }

    public inline function vorbisValidate() {
        var header = Bytes.alloc(6);
        for (i in 0...6) {
            header.set(i, readPacket());
        }
        if (header.toString() != "vorbis") {
            throw new ReaderError(ReaderErrorType.INVALID_SETUP, "vorbis header");
        }
    }

    public function firstPageValidate()
    {
        if (segments.length != 1) {
            throw new ReaderError(INVALID_FIRST_PAGE, "segmentCount");
        }
        if (segments.get(0) != 30) {
            throw new ReaderError(INVALID_FIRST_PAGE, "decodeState head");
        }
    }

    public function startFirstDecode()
    {
        firstAudioPageOffset = inputPosition;
        firstDecode = true;
    }

    public inline function capturePattern()
    {
        if (readByte() != 0x4f || readByte() != 0x67 || readByte() != 0x67 || readByte() != 0x53) {
            throw new ReaderError(ReaderErrorType.MISSING_CAPTURE_PATTERN);
        }
    }

    inline function skip(len:Int)
    {
        read(len);
    }

    function prepHuffman()
    {
        if (validBits <= 24) {
            if (validBits == 0) {
                acc = 0;
            }
            do {
                if (bytesInSeg == 0 && (lastSeg || next() == 0)) {  // CLANG!
                    return;
                } else {
                    bytesInSeg--;
                    acc += readByte() << validBits;
                    validBits += 8;
                }
            } while (validBits <= 24);
        }
    }

    public inline function decode(c:Codebook):Int {
        var val = decodeRaw(c);
        if (c.sparse) {
            val = c.sortedValues[val];
        }
        return val;
    }

    public inline function decodeRaw(c:Codebook)
    {
        if (validBits < Setting.FAST_HUFFMAN_LENGTH){
            prepHuffman();
        }

        // fast huffman table lookup
        var i = c.fastHuffman[acc & Setting.FAST_HUFFMAN_TABLE_MASK];

        return if (i >= 0) {
            var l = c.codewordLengths[i];
            acc >>>= l;
            validBits -= l;
            if (validBits < 0) {
                validBits = 0;
                -1;
            } else {
                i;
            }
        } else {
            decodeScalarRaw(c);
        }
    }

    public inline function isLastByte()
    {
        return bytesInSeg == 0 && lastSeg;
    }

    public function finishDecodePacket(previousLength:Int, n:Int, r:DecodeInitialResult)
    {
        var left = r.left.start;
        var currentLocValid = false;
        var n2 = n >> 1;

        if (firstDecode) {
            // assume we start so first non-discarded sample is sample 0
            // this isn't to spec, but spec would require us to read ahead
            // and decode the size of all current frames--could be done,
            // but presumably it's not a commonly used feature
            currentLoc = -n2; // start of first frame is positioned for discard
            // we might have to discard samples "from" the next frame too,
            // if we're lapping a large block then a small at the start?
            discardSamplesDeferred = n - r.right.end;
            currentLocValid = true;
            firstDecode = false;
        } else if (discardSamplesDeferred != 0) {
            r.left.start += discardSamplesDeferred;
            left = r.left.start;
            discardSamplesDeferred = 0;
        } else if (previousLength == 0 && currentLocValid) {
            // we're recovering from a seek... that means we're going to discard
            // the samples from this packet even though we know our position from
            // the last page header, so we need to update the position based on
            // the discarded samples here
            // but wait, the code below is going to add this in itself even
            // on a discard, so we don't need to do it here...
        }

        // check if we have ogg information about the sample # for this packet
        if (lastSegWhich == endSegWithKnownLoc) {
            // if we have a valid current loc, and this is final:
            if (currentLocValid && (page.flag & PageFlag.LAST_PAGE) != 0) {
                var currentEnd = knownLocForPacket - (n - r.right.end);
                // then let's infer the size of the (probably) short final frame
                if (currentEnd < currentLoc + r.right.end) {
                    var len = if (currentEnd < currentLoc) {
                        // negative truncation, that's impossible!
                        0;
                    } else {
                        currentEnd - currentLoc;
                    }
                    len += r.left.start;
                    currentLoc += len;

                    return {
                        len : len,
                        left : left,
                        right : r.right.start,
                    }
                }
            }
            // otherwise, just set our sample loc
            // guess that the ogg granule pos refers to the Middle_ of the
            // last frame?
            // set currentLoc to the position of leftStart
            currentLoc = knownLocForPacket - (n2-r.left.start);
            currentLocValid = true;
        }

        if (currentLocValid) {
            currentLoc += (r.right.start - r.left.start);
        }

        // if (alloc.allocBuffer)
        //assert(alloc.allocBufferLengthInBytes == tempOffset);

        return {
            len : r.right.end,
            left : left,
            right : r.right.start,
        }
    }

    public inline function readInt32():Int
    {
        inputPosition += 4;
        return input.readInt32();
    }

    public inline function readByte():Int
    {
        inputPosition += 1;
        return input.readByte();
    }

    public inline function read(n:Int):Vector<Int> {
        inputPosition += n;
        var vec = new Vector(n);
        for (i in 0...n) {
            vec[i] = input.readByte();
        }
        return vec;
    }

    public inline function readBytes(n:Int):Bytes {
        inputPosition += n;
        return input.read(n);
    }

    public inline function readString(n:Int):String
    {
        inputPosition += n;
        return input.readString(n);
    }

    public function getSampleNumber(seekFunc:Int->Void, inputLength:UInt):Int {

        // first, store the current decode position so we can restore it
        var restoreOffset = inputPosition;

        // now we want to seek back 64K from the end (the last page must
        // be at most a little less than 64K, but let's allow a little slop)
        var previousSafe = if (inputLength >= 65536 && inputLength - 65536 >= firstAudioPageOffset) {
            inputLength - 65536;
        } else {
            firstAudioPageOffset;
        }

        setInputOffset(seekFunc, previousSafe);

        // previousSafe is now our candidate 'earliest known place that seeking
        // to will lead to the final page'
        var end = 0;
        var last = false;
        switch (findPage(seekFunc, inputLength)) {
            case Found(e, l):
                end = e;
                last = l;
            case NotFound:
                throw new ReaderError(ReaderErrorType.CANT_FIND_LAST_PAGE);
        }

        // check if there are more pages
        var lastPageLoc = inputPosition;

        // stop when the lastPage flag is set, not when we reach eof;
        // this allows us to stop short of a 'fileSection' end without
        // explicitly checking the length of the section
        while (!last) {
            setInputOffset(seekFunc, end);
            switch (findPage(seekFunc, inputLength)) {
                case Found(e, l):
                    end = e;
                    last = l;
                case NotFound:
                    // the last page we found didn't have the 'last page' flag
                    // set. whoops!
                    break;
            }

            previousSafe = lastPageLoc + 1;
            lastPageLoc = inputPosition;
        }

        setInputOffset(seekFunc, lastPageLoc);

        // parse the header
        var vorbisHeader = read(6);

        // extract the absolute granule position
        var lo = readInt32();
        var hi = readInt32();
        if (lo == 0xffffffff && hi == 0xffffffff || hi > 0) {
            throw new ReaderError(ReaderErrorType.CANT_FIND_LAST_PAGE);
        }

        pLast = new ProbedPage();
        pLast.pageStart = lastPageLoc;
        pLast.pageEnd    = end;
        pLast.lastDecodedSample = lo;
        pLast.firstDecodedSample = null;
        pLast.afterPreviousPageStart = previousSafe;

        setInputOffset(seekFunc, restoreOffset);
        return lo;
    }

    public inline function forcePageResync()
    {
        nextSeg = -1;
    }

    public inline function setInputOffset(seekFunc:Int->Void, n:Int)
    {
        seekFunc(inputPosition = n);
    }

    public function findPage(seekFunc:Int->Void, inputLength:Int):FindPageResult {
        try {
            while (true) {
                var n = readByte();
                if (n == 0x4f) { // page header
                    var retryLoc = inputPosition;
                    // check if we're off the end of a fileSection stream
                    if (retryLoc - 25 > inputLength) {
                        return FindPageResult.NotFound;
                    }

                    if (readByte() != 0x67 || readByte() != 0x67 || readByte() != 0x53) {
                        continue;
                    }

                    var header = new Vector<UInt>(27);
                    header[0] = 0x4f;
                    header[1] = 0x67;
                    header[2] = 0x67;
                    header[3] = 0x53;
                    for (i in 4...27) {
                        header[i] = readByte();
                    }

                    if (header[4] != 0) {
                        setInputOffset(seekFunc, retryLoc);
                        continue;
                    }

                    var goal:UInt = header[22] + (header[23] << 8) + (header[24]<<16) + (header[25]<<24);
                    for (i in 22...26) {
                        header[i] = 0;
                    }

                    var crc:UInt = 0;
                    for (i in 0...27){
                        crc = Crc32.update(crc, header[i]);
                    }

                    var len = 0;
                    try {
                        for (i in 0...header[26]) {
                            var s = readByte();
                            crc = Crc32.update(crc, s);
                            len += s;
                        }
                        for (i in 0...len) {
                            crc = Crc32.update(crc, readByte());
                        }
                    } catch (e:Eof) {
                        return FindPageResult.NotFound;
                    }

                    // finished parsing probable page
                    if (crc == goal) {
                        // we could now check that it's either got the last
                        // page flag set, OR it's followed by the capture
                        // pattern, but I guess TECHNICALLY you could have
                        // a file with garbage between each ogg page and recover
                        // from it automatically? So even though that paranoia
                        // might decrease the chance of an invalid decode by
                        // another 2^32, not worth it since it would hose those
                        // invalid-but-useful files?
                        var end = inputPosition;
                        setInputOffset(seekFunc, retryLoc - 1);
                        return FindPageResult.Found(end, (header[5] & 0x04 != 0));
                    }
                }
            }
        } catch (e:Eof) {
            return FindPageResult.NotFound;
        }
    }

    public function analyzePage(seekFunc:Int->Void, h:Header)
    {
        var z:ProbedPage = new ProbedPage();
        var packetType = new Vector<Bool>(255);

        // record where the page starts
        z.pageStart = inputPosition;

        // parse the header
        var pageHeader = read(27);
        VorbisTools.assert(pageHeader.get(0) == 0x4f && pageHeader.get(1) == 0x67 && pageHeader.get(2) == 0x67 && pageHeader.get(3) == 0x53);
        var lacing = read(pageHeader.get(26));

        // determine the length of the payload
        var len = 0;
        for (i in 0...pageHeader.get(26)){
            len += lacing.get(i);
        }

        // this implies where the page ends
        z.pageEnd = z.pageStart + 27 + pageHeader.get(26) + len;

        // read the last-decoded sample out of the data
        z.lastDecodedSample = pageHeader.get(6) + (pageHeader.get(7) << 8) + (pageHeader.get(8) << 16) + (pageHeader.get(9) << 16);

        if ((pageHeader.get(5) & 4) != 0) {
            // if this is the last page, it's not possible to work
            // backwards to figure out the first sample! whoops! fuck.
            z.firstDecodedSample = null;
            setInputOffset(seekFunc, z.pageStart);
            return z;
        }

        // scan through the frames to determine the sample-count of each one...
        // our goal is the sample # of the first fully-decoded sample on the
        // page, which is the first decoded sample of the 2nd packet

        var numPacket = 0;
        var packetStart = ((pageHeader.get(5) & 1) == 0);

        var modeCount = h.modes.length;

        for (i in 0...pageHeader.get(26)) {
            if (packetStart) {
                if (lacing.get(i) == 0) {

                    setInputOffset(seekFunc, z.pageStart);
                    return null; // trying to read from zero-length packet
                }
                var n = readByte();

                // if bottom bit is non-zero, we've got corruption
                if (n & 1 != 0) {
                    setInputOffset(seekFunc, z.pageStart);
                    return null;
                }
                n >>= 1;
                var b = MathTools.ilog(modeCount - 1);
                n &= (1 << b) - 1;
                if (n >= modeCount) {
                    setInputOffset(seekFunc, z.pageStart);
                    return null;
                }
                packetType[numPacket++] = h.modes[n].blockflag;
                skip(lacing.get(i)-1);
            } else {
                skip(lacing.get(i));
            }
            packetStart = (lacing.get(i) < 255);
        }

        // now that we know the sizes of all the pages, we can start determining
        // how much sample data there is.
        var samples = 0;

        // for the last packet, we step by its whole length, because the definition
        // is that we encoded the end sample loc of the 'last packet completed',
        // where 'completed' refers to packets being split, and we are left to guess
        // what 'end sample loc' means. we assume it means ignoring the fact that
        // the last half of the data is useless without windowing against the next
        // packet... (so it's not REALLY complete in that sense)
        if (numPacket > 1) {
            samples += packetType[numPacket-1] ? h.blocksize1 : h.blocksize0;
        }

        var i = numPacket - 2;
        while (i >= 1) {
            i--;
            // now, for this packet, how many samples do we have that
            // do not overlap the following packet?
            if (packetType[i]) {
                if (packetType[i + 1]) {
                    samples += h.blocksize1 >> 1;
                } else {
                    samples += ((h.blocksize1 - h.blocksize0) >> 2) + (h.blocksize0 >> 1);
                }
            } else {
                samples += h.blocksize0 >> 1;
            }
            i--;
        }
        // now, at this point, we've rewound to the very beginning of the
        // Second_ packet. if we entirely discard the first packet after
        // a seek, this will be exactly the right sample number. HOWEVER!
        // we can't as easily compute this number for the LAST page. The
        // only way to get the sample offset of the LAST page is to use
        // the end loc from the previous page. But what that returns us
        // is _exactly_ the place where we get our first non-overlapped
        // sample. (I think. Stupid spec for being ambiguous.) So for
        // consistency it's better to do that here, too. However, that
        // will then require us to NOT discard all of the first frame we
        // decode, in some cases, which means an even weirder frame size
        // and extra code. what a fucking pain.

        // we're going to discard the first packet if we
        // start the seek here, so we don't care about it. (we could actually
        // do better; if the first packet is long, and the previous packet
        // is short, there's actually data in the first half of the first
        // packet that doesn't need discarding... but not worth paying the
        // effort of tracking that of that here and in the seeking logic)
        // except crap, if we infer it from the Previous_ packet's end
        // location, we DO need to use that definition... and we HAVE to
        // infer the start loc of the LAST packet from the previous packet's
        // end location. fuck you, ogg vorbis.

        z.firstDecodedSample = z.lastDecodedSample - samples;

        // restore file state to where we were
        setInputOffset(seekFunc, z.pageStart);
        return z;
    }


    function decodeScalarRaw(c:Codebook):Int
    {
        prepHuffman();

        VorbisTools.assert(c.sortedCodewords != null || c.codewords != null);
        // cases to use binary search: sortedCodewords && !codewords

        var codewordLengths = c.codewordLengths;
        var codewords = c.codewords;
        var sortedCodewords = c.sortedCodewords;

        if (c.entries > 8 ? (sortedCodewords != null) : codewords != null) {
            // binary search
            var code = VorbisTools.bitReverse(acc);
            var x = 0;
            var n = c.sortedEntries;

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

            // x is now the sorted index
            if (!c.sparse) {
                x = c.sortedValues[x];
            }

            // x is now sorted index if sparse, or symbol otherwise
            var len = codewordLengths[x];
            if (validBits >= len) {
                acc >>>= len;
                validBits -= len;
                return x;
            }

            validBits = 0;
            return -1;
        }

        // if small, linear search
        VorbisTools.assert(!c.sparse);
        for (i in 0...c.entries) {
            var cl = codewordLengths[i];
            if (cl == Codebook.NO_CODE) {
                continue;
            }
            if (codewords[i] == (acc & ((1 << cl)-1))) {
                if (validBits >= cl) {
                    acc >>>= cl;
                    validBits -= cl;
                    return i;
                }
                validBits = 0;
                return -1;
            }
        }

        error = new ReaderError(INVALID_STREAM);
        validBits = 0;
        return -1;
    }
}


private enum FindPageResult {
    Found(end:Int, last:Bool);
    NotFound;
}
