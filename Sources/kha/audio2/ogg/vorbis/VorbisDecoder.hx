package kha.audio2.ogg.vorbis;
import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.Input;
import haxe.io.Output;
import kha.audio2.ogg.tools.MathTools;
import kha.audio2.ogg.tools.Mdct;
import kha.audio2.ogg.vorbis.data.Codebook;
import kha.audio2.ogg.vorbis.data.Floor.Floor1;
import kha.audio2.ogg.vorbis.data.Header;
import kha.audio2.ogg.vorbis.data.Mode;
import kha.audio2.ogg.vorbis.data.ProbedPage;
import kha.audio2.ogg.vorbis.data.ReaderError;
import kha.audio2.ogg.vorbis.VorbisDecodeState;

/**
 * ...
 * @author shohei909
 */
class VorbisDecoder
{
    var previousWindow:Vector<Vector<Float>>; //var *[STB_VORBIS_MAX_CHANNELS];
    var previousLength:Int;
    var finalY:Vector<Array<Int>>; // [STB_VORBIS_MAX_CHANNELS];

    // twiddle factors
    var a:Vector<Vector<Float>>; // var *  [2]
    var b:Vector<Vector<Float>>; // var *  [2]
    var c:Vector<Vector<Float>>; // var *  [2]
    var window:Vector<Vector<Float>>; //var * [2];
    var bitReverseData:Vector<Vector<Int>>; //uint16 * [2]

    // decode buffer
    var channelBuffers:Vector<Vector<Float>>; //var *[STB_VORBIS_MAX_CHANNELS];
    var channelBufferStart:Int;
    var channelBufferEnd:Int;

    public var header(default, null):Header;
    public var currentSample(default, null):Int;
    public var totalSample(default, null):Null<Int>;
    var decodeState:VorbisDecodeState;

    function new(header:Header, decodeState:VorbisDecodeState) {
        this.header = header;
        this.decodeState = decodeState;
        totalSample = null;
        currentSample = 0;

        //Channel
        previousLength = 0;

        channelBuffers = new Vector(header.channel);
        previousWindow = new Vector(header.channel);
        finalY = new Vector(header.channel);

        for (i in 0...header.channel) {
            channelBuffers[i] = VorbisTools.emptyFloatVector(header.blocksize1);
            previousWindow[i] = VorbisTools.emptyFloatVector(Std.int(header.blocksize1 / 2));
            finalY[i] = new Array();
        }

        a = new Vector(2);
        b = new Vector(2);
        c = new Vector(2);
        window = new Vector(2);
        bitReverseData = new Vector(2);
        initBlocksize(0, header.blocksize0);
        initBlocksize(1, header.blocksize1);
    }

    public static function start(input:Input) {
        var decodeState = new VorbisDecodeState(input);
        var header = Header.read(decodeState);
        var decoder = new VorbisDecoder(header, decodeState);
        decodeState.startFirstDecode();
        decoder.pumpFirstFrame();

        return decoder;
    }

    public function read(output:Vector<Float>, samples:Int, channels:Int, sampleRate:Int, useFloat:Bool) {
        if (sampleRate % header.sampleRate != 0) {
            throw 'Unsupported sampleRate : can\'t convert ${header.sampleRate} to $sampleRate';
        }
        if (channels % header.channel != 0) {
            throw 'Unsupported channels : can\'t convert ${header.channel} to $channels';
        }

        var sampleRepeat = Std.int(sampleRate / header.sampleRate);
        var channelRepeat = Std.int(channels / header.channel);

        var n = 0;
        var len = Math.floor(samples / sampleRepeat);
        if (totalSample != null && len > totalSample - currentSample) {
            len = totalSample - currentSample;
        }

		var index = 0;
        while (n < len) {
            var k = channelBufferEnd - channelBufferStart;
            if (k >= len - n) k = len - n;
            for (j in channelBufferStart...(channelBufferStart + k)) {
                for (sr in 0...sampleRepeat) {
                    for (i in 0...header.channel) {
                        for (cr in 0...channelRepeat) {
                            var value = channelBuffers[i][j];
                            if (value > 1) {
                                value = 1;
                            } else if (value < -1) {
                                value = -1;
                            }

                            if (useFloat) {
                                //output.writeFloat(value);
								output[index] = value;
								++index;
                            } else {
                                //output.writeInt16(Math.floor(value * 0x7FFF));
                            }
                        }
                    }
                }
            }
            n += k;
            channelBufferStart += k;
            if (n == len || getFrameFloat() == 0) {
                break;
            }
        }

        for (j in n...len) {
            for (sr in 0...sampleRepeat) {
                for (i in 0...header.channel) {
                    for (cr in 0...channelRepeat) {
                        if (useFloat) {
                            //output.writeFloat(0);
							output[index] = 0;
							++index;
                        } else {
                            //output.writeInt16(0);
                        }
                    }
                }
            }
        }

        currentSample += len;
        return len * sampleRepeat;
    }

    public function skipSamples(len:Int) {
        var n = 0;
        if (totalSample != null && len > totalSample - currentSample) {
            len = totalSample - currentSample;
        }
        while (n < len) {
            var k = channelBufferEnd - channelBufferStart;
            if (k >= len - n) k = len - n;
            n += k;
            channelBufferStart += k;
            if (n == len || getFrameFloat() == 0) {
                break;
            }
        }

        currentSample += len;
        return len;
    }

    public function setupSampleNumber(seekFunc:Int->Void, inputLength:Int) {
        if (totalSample == null) {
            totalSample = decodeState.getSampleNumber(seekFunc, inputLength);
        }
    }


    public function seek(seekFunc:Int->Void, inputLength:UInt, sampleNumber:Int) {
        if (currentSample == sampleNumber) {
            return;
        }

        // do we know the location of the last page?
        if (totalSample == null) {
            setupSampleNumber(seekFunc, inputLength);
            if (totalSample == 0) {
                throw new ReaderError(ReaderErrorType.CANT_FIND_LAST_PAGE);
            }
        }

        if (sampleNumber < 0) {
            sampleNumber = 0;
        }

        var p0 = decodeState.pFirst;
        var p1 = decodeState.pLast;

        if (sampleNumber >= p1.lastDecodedSample) {
            sampleNumber = p1.lastDecodedSample - 1;
        }

        if (sampleNumber < p0.lastDecodedSample) {
            seekFrameFromPage(seekFunc, p0.pageStart, 0, sampleNumber);
        } else {
            var attempts = 0;

            while (p0.pageEnd < p1.pageStart) {


                // copy these into local variables so we can tweak them
                // if any are unknown
                var startOffset:UInt = p0.pageEnd;
                var endOffset:UInt = p1.afterPreviousPageStart; // an address known to seek to page p1
                var startSample = p0.lastDecodedSample;
                var endSample = p1.lastDecodedSample;

                // currently there is no such tweaking logic needed/possible?
                if (startSample == null || endSample == null) {
                    throw new ReaderError(SEEK_FAILED);
                }

                // now we want to lerp between these for the target samples...

                // step 1: we need to bias towards the page start...
                if (startOffset + 4000 < endOffset) {
                    endOffset -= 4000;
                }

                // now compute an interpolated search loc
                var probe:UInt = startOffset + Math.floor((endOffset - startOffset) / (endSample - startSample) * (sampleNumber - startSample));

                // next we need to bias towards binary search...
                // code is a little wonky to allow for full 32-bit unsigned values
                if (attempts >= 4) {
                    var probe2:UInt = startOffset + ((endOffset - startOffset) >> 1);
                    probe = if (attempts >= 8) {
                        probe2;
                    } else if (probe < probe2) {
                        probe + ((probe2 - probe) >>> 1);
                    } else {
                        probe2 + ((probe - probe2) >>> 1);
                    }
                }
                ++attempts;
                decodeState.setInputOffset(seekFunc, probe);

                switch (decodeState.findPage(seekFunc, inputLength)) {
                    case NotFound:
                        throw new ReaderError(SEEK_FAILED);
                    case Found(_):
                }

                var q:ProbedPage = decodeState.analyzePage(seekFunc, header);
                if (q == null) {
                    throw new ReaderError(SEEK_FAILED);
                }
                q.afterPreviousPageStart = probe;

                // it's possible we've just found the last page again
                if (q.pageStart == p1.pageStart) {
                    p1 = q;
                    continue;
                }

                if (sampleNumber < q.lastDecodedSample) {
                    p1 = q;
                } else {
                    p0 = q;
                }
            }

            if (p0.lastDecodedSample <= sampleNumber && sampleNumber < p1.lastDecodedSample) {
                seekFrameFromPage(seekFunc, p1.pageStart, p0.lastDecodedSample, sampleNumber);
            } else {
                throw new ReaderError(SEEK_FAILED);
            }
        }
    }

    public function seekFrameFromPage(seekFunc:Int->Void, pageStart:Int, firstSample:Int, targetSample:Int) {
        var frame = 0;
        var frameStart:Int = firstSample;

        // firstSample is the sample # of the first sample that doesn't
        // overlap the previous page... note that this requires us to
        // Partially_ discard the first packet! bleh.
        decodeState.setInputOffset(seekFunc, pageStart);
        decodeState.forcePageResync();

        // frame start is where the previous packet's last decoded sample
        // was, which corresponds to leftEnd... EXCEPT if the previous
        // packet was long and this packet is short? Probably a bug here.

        // now, we can start decoding frames... we'll only FAKE decode them,
        // until we find the frame that contains our sample; then we'll rewind,
        // and try again
        var leftEnd = 0;
        var leftStart = 0;

        var prevState = null;
        var lastState = null;

        while (true) {
            prevState = lastState;
            lastState = decodeState.clone(seekFunc);

            var initialResult = decodeInitial();
            if (initialResult == null) {
                lastState = prevState;
                break;
            }

            leftStart = initialResult.left.start;
            leftEnd = initialResult.left.end;

            var start = if (frame == 0) {
                leftEnd;
            } else{
                leftStart;
            }

            // the window starts at leftStart; the last valid sample we generate
            // before the next frame's window start is rightStart-1
            if (targetSample < frameStart + initialResult.right.start - start) {
                break;
            }

            decodeState.flushPacket();
            frameStart += initialResult.right.start - start;
            ++frame;
        }

        decodeState = lastState;
        seekFunc(decodeState.inputPosition);

        previousLength = 0;
        pumpFirstFrame();

        currentSample = frameStart;
        skipSamples(targetSample - frameStart);
    }

    public function clone(seekFunc:Int->Void) {
        var decoder = Type.createEmptyInstance(VorbisDecoder);

        decoder.currentSample = currentSample;
        decoder.totalSample = totalSample;
        decoder.previousLength = previousLength;
        decoder.channelBufferStart = channelBufferStart;
        decoder.channelBufferEnd = channelBufferEnd;

        // sharrow copy
        decoder.a = a;
        decoder.b = b;
        decoder.c = c;
        decoder.window = window;
        decoder.bitReverseData = bitReverseData;
        decoder.header = header;

        // deep copy
        decoder.decodeState = decodeState.clone(seekFunc);
        decoder.channelBuffers = new Vector(header.channel);
        decoder.previousWindow = new Vector(header.channel);
        decoder.finalY = new Vector(header.channel);

        for (i in 0...header.channel) {
            decoder.channelBuffers[i] = VorbisTools.copyVector(channelBuffers[i]);
            decoder.previousWindow[i] = VorbisTools.copyVector(previousWindow[i]);
            decoder.finalY[i] = Lambda.array(finalY[i]);
        }

        return decoder;
    }

    public function ensurePosition(seekFunc:Int->Void) {
        seekFunc(decodeState.inputPosition);
    }

    function getFrameFloat() {
        var result = decodePacket();
        if (result == null) {
            channelBufferStart = channelBufferEnd = 0;
            return 0;
        }

        var len = finishFrame(result);

        channelBufferStart = result.left;
        channelBufferEnd = result.left + len;

        return len;
    }

    function pumpFirstFrame() {
        finishFrame(decodePacket());
    }

    function finishFrame(r:DecodePacketResult):Int {
        var len = r.len;
        var right = r.right;
        var left = r.left;

        // we use right&left (the start of the right- and left-window sin()-regions)
        // to determine how much to return, rather than inferring from the rules
        // (same result, clearer code); 'left' indicates where our sin() window
        // starts, therefore where the previous window's right edge starts, and
        // therefore where to start mixing from the previous buffer. 'right'
        // indicates where our sin() ending-window starts, therefore that's where
        // we start saving, and where our returned-data ends.

        // mixin from previous window
        if (previousLength != 0) {
            var n = previousLength;
            var w = getWindow(n);
            for (i in 0...header.channel) {
                var cb = channelBuffers[i];
                var pw = previousWindow[i];
                for (j in 0...n) {
                    cb[left+j] = cb[left+j] * w[j] + pw[j] * w[n-1-j];
                }
            }
        }

        var prev = previousLength;

        // last half of this data becomes previous window
        previousLength = len - right;

        // @OPTIMIZE: could avoid this copy by double-buffering the
        // output (flipping previousWindow with channelBuffers), but
        // then previousWindow would have to be 2x as large, and
        // channelBuffers couldn't be temp mem (although they're NOT
        // currently temp mem, they could be (unless we want to level
        // performance by spreading out the computation))
        for (i in 0...header.channel) {
            var pw = previousWindow[i];
            var cb = channelBuffers[i];
            for (j in 0...(len - right)) {
                pw[j] = cb[right + j];
            }
        }

        if (prev == 0) {
            // there was no previous packet, so this data isn't valid...
            // this isn't entirely true, only the would-have-overlapped data
            // isn't valid, but this seems to be what the spec requires
            return 0;
        }

        // truncate a short frame
        if (len < right) {
            right = len;
        }

        return right - left;
    }

    function getWindow(len:Int)
    {
        len <<= 1;
        return if (len == header.blocksize0) {
            window[0];
        } else if (len == header.blocksize1) {
            window[1];
        } else {
            VorbisTools.assert(false);
            null;
        }
    }

    function initBlocksize(bs:Int, n:Int)
    {
        var n2 = n >> 1, n4 = n >> 2, n8 = n >> 3;
        a[bs] = new Vector(n2);
        b[bs] = new Vector(n2);
        c[bs] = new Vector(n4);
        window[bs] = new Vector(n2);
        bitReverseData[bs] = new Vector(n8);

        VorbisTools.computeTwiddleFactors(n, a[bs], b[bs], c[bs]);
        VorbisTools.computeWindow(n, window[bs]);
        VorbisTools.computeBitReverse(n, bitReverseData[bs]);
    }

    function inverseMdct(buffer:Vector<Float>, n:Int, blocktype:Bool) {
        var bt = blocktype ? 1 : 0;
        Mdct.inverseTransform(buffer, n, a[bt], b[bt], c[bt], bitReverseData[bt]);
    }

    function decodePacket():DecodePacketResult
    {
        var result = decodeInitial();
        if (result == null) {
            return null;
        }
        var rest = decodePacketRest(result);
        return rest;
    }

    function decodeInitial():DecodeInitialResult
    {
        channelBufferStart = channelBufferEnd = 0;

        do {
            if (!decodeState.maybeStartPacket()) {
                return null;
            }

            // check packet type
            if (decodeState.readBits(1) != 0) {
                while (VorbisTools.EOP != decodeState.readPacket()) {};
                continue;
            }
            break;
        } while (true);

        var i = decodeState.readBits(MathTools.ilog(header.modes.length - 1));
        if (i == VorbisTools.EOP || i >= header.modes.length) {
            throw new ReaderError(ReaderErrorType.SEEK_FAILED);
        }

        var m = header.modes[i];
        var n, prev, next;

        if (m.blockflag) {
            n = header.blocksize1;
            prev = decodeState.readBits(1);
            next = decodeState.readBits(1);
        } else {
            prev = next = 0;
            n = header.blocksize0;
        }

        // WINDOWING
        var windowCenter = n >> 1;

        return {
            mode : i,
            left : if (m.blockflag && prev == 0) {
                start : (n - header.blocksize0) >> 2,
                end : (n + header.blocksize0) >> 2,
            } else {
                start : 0,
                end : windowCenter,
            },
            right : if (m.blockflag && next == 0) {
                start : (n * 3 - header.blocksize0) >> 2,
                end : (n * 3 + header.blocksize0) >> 2,
            } else {
                start : windowCenter,
                end : n,
            },
        }
    }


    function decodePacketRest(r:DecodeInitialResult):DecodePacketResult
    {
        var len = 0;
        var m = header.modes[r.mode];

        var zeroChannel = new Vector<Bool>(256);
        var reallyZeroChannel = new Vector<Bool>(256);

        // WINDOWING

        var n = m.blockflag ? header.blocksize1 : header.blocksize0;
        var map = header.mapping[m.mapping];

        // FLOORS
        var n2 = n >> 1;
        VorbisTools.stbProf(1);
        var rangeList = [256, 128, 86, 64];
        var codebooks = header.codebooks;

        for (i in 0...header.channel) {
            var s = map.chan[i].mux;
            zeroChannel[i] = false;
            var floor = header.floorConfig[map.submapFloor[s]];
            if (floor.type == 0) {
                throw new ReaderError(INVALID_STREAM);
            } else {
                var g:Floor1 = floor.floor1;
                if (decodeState.readBits(1) != 0) {
                    var fy = new Array<Int>();
                    var step2Flag = new Vector<Bool>(256);
                    var range = rangeList[g.floor1Multiplier-1];
                    var offset = 2;
                    fy = finalY[i];
                    fy[0] = decodeState.readBits(MathTools.ilog(range)-1);
                    fy[1] = decodeState.readBits(MathTools.ilog(range)-1);
                    for (j in 0...g.partitions) {
                        var pclass = g.partitionClassList[j];
                        var cdim = g.classDimensions[pclass];
                        var cbits = g.classSubclasses[pclass];
                        var csub = (1 << cbits) - 1;
                        var cval = 0;
                        if (cbits != 0) {
                            var c = codebooks[g.classMasterbooks[pclass]];
                            cval = decodeState.decode(c);
                        }

                        var books = g.subclassBooks[pclass];
                        for (k in 0...cdim) {
                            var book = books[cval & csub];
                            cval >>= cbits;
                            fy[offset++] = if (book >= 0) {
                                decodeState.decode(codebooks[book]);
                            } else {
                                0;
                            }
                        }
                    }

                    if (decodeState.validBits == VorbisDecodeState.INVALID_BITS) {
                        zeroChannel[i] = true;
                        continue;
                    }

                    step2Flag[0] = step2Flag[1] = true;
                    var naighbors = g.neighbors;
                    var xlist = g.xlist;
                    for (j in 2...g.values) {
                        var low = naighbors[j][0];
                        var high = naighbors[j][1];
                        var lowroom = VorbisTools.predictPoint(xlist[j], xlist[low], xlist[high], fy[low], fy[high]);
                        var val = fy[j];
                        var highroom = range - lowroom;
                        var room = if (highroom < lowroom){
                            highroom * 2;
                        }else{
                            lowroom * 2;
                        }
                        if (val != 0) {
                            step2Flag[low] = step2Flag[high] = true;
                            step2Flag[j] = true;
                            if (val >= room){
                                if (highroom > lowroom){
                                    fy[j] = val - lowroom + lowroom;
                                }else{
                                    fy[j] = lowroom - val + highroom - 1;
                                }
                            } else {
                                if (val & 1 != 0){
                                    fy[j] = lowroom - ((val+1)>>1);
                                } else{
                                    fy[j] = lowroom + (val>>1);
                                }
                            }
                        } else {
                            step2Flag[j] = false;
                            fy[j] = lowroom;
                        }
                    }

                    // defer final floor computation until _after_ residue
                    for (j in 0...g.values) {
                        if (!step2Flag[j]){
                            fy[j] = -1;
                        }
                    }

                } else {
                    zeroChannel[i] = true;
                }
                // So we just defer everything else to later
                // at this point we've decoded the floor into buffer
            }
        }
        VorbisTools.stbProf(0);
        // at this point we've decoded all floors

        //if (alloc.allocBuffer) {
        //    assert(alloc.allocBufferLengthInBytes == tempOffset);
        //}

        // re-enable coupled channels if necessary
        for (i in 0...header.channel) {
            reallyZeroChannel[i] = zeroChannel[i];
        }
        for (i in 0...map.couplingSteps) {
            if (!zeroChannel[map.chan[i].magnitude] || !zeroChannel[map.chan[i].angle]) {
                zeroChannel[map.chan[i].magnitude] = zeroChannel[map.chan[i].angle] = false;
            }
        }
        // RESIDUE DECODE
        for (i in 0...map.submaps) {
            var residueBuffers = new Vector<Vector<Float>>(header.channel);
            var doNotDecode = new Vector<Bool>(256);
            var ch = 0;
            for (j in 0...header.channel) {

                if (map.chan[j].mux == i) {
                    if (zeroChannel[j]) {
                        doNotDecode[ch] = true;
                        residueBuffers[ch] = null;
                    } else {
                        doNotDecode[ch] = false;
                        residueBuffers[ch] = channelBuffers[j];
                    }
                    ++ch;
                }
            }

            var r = map.submapResidue[i];
            var residue = header.residueConfig[r];
            residue.decode(decodeState,header, residueBuffers, ch, n2, doNotDecode, channelBuffers);
        }

        // INVERSE COUPLING
        VorbisTools.stbProf(14);

        var i = map.couplingSteps;
        var n2 = n >> 1;
        while (--i >= 0) {
            var m = channelBuffers[map.chan[i].magnitude];
            var a = channelBuffers[map.chan[i].angle];
            for (j in 0...n2) {
                var a2, m2;
                if (m[j] > 0) {
                    if (a[j] > 0) {
                        m2 = m[j];
                        a2 = m[j] - a[j];
                    } else {
                        a2 = m[j];
                        m2 = m[j] + a[j];
                    }
                } else {
                    if (a[j] > 0) {
                        m2 = m[j];
                        a2 = m[j] + a[j];
                    } else {
                        a2 = m[j];
                        m2 = m[j] - a[j];
                    }
                }
                m[j] = m2;
                a[j] = a2;
            }
        }

        // finish decoding the floors
        VorbisTools.stbProf(15);
        for (i in 0...header.channel) {
            if (reallyZeroChannel[i]) {
                for(j in 0...n2) {
                    channelBuffers[i][j] = 0;
                }
            } else {
                map.doFloor(header.floorConfig, i, n, channelBuffers[i], finalY[i], null);
            }
        }

        // INVERSE MDCT
        VorbisTools.stbProf(16);
        for (i in 0...header.channel) {
            inverseMdct(channelBuffers[i], n, m.blockflag);
        }
        VorbisTools.stbProf(0);

        // this shouldn't be necessary, unless we exited on an error
        // and want to flush to get to the next packet
        decodeState.flushPacket();

        return decodeState.finishDecodePacket(previousLength, n, r);
    }
}

typedef DecodePacketResult = {
    var len : Int;
    var left : Int;
    var right : Int;
}

typedef DecodeInitialResult = {
    var mode : Int;
    var left : Range;
    var right : Range;
}

private typedef Range = {
    var start : Int;
    var end : Int;
}
