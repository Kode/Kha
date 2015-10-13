package kha.audio2.ogg.vorbis.data;
import haxe.ds.Vector;
import haxe.io.Input;
import kha.audio2.ogg.vorbis.VorbisDecodeState;

/**
 * ...
 * @author shohei909
 */
class Residue
{
    public var begin(default, null):UInt; // uint32
    public var end(default, null):UInt; // uint32
    public var partSize(default, null):UInt; // uint32
    public var classifications(default, null):Int; // uint8
    public var classbook(default, null):Int; // uint8
    public var classdata(default, null):Vector<Vector<Int>>; //uint8 **
    public var residueBooks(default, null):Vector<Vector<Int>>; //int16 (*)[8]
    public var type(default, null):Int;

    public function new() {
    }

    public static function read(decodeState:VorbisDecodeState, codebooks:Vector<Codebook>):Residue
    {
        var r = new Residue();
        r.type = decodeState.readBits(16);
        if (r.type > 2) {
            throw new ReaderError(INVALID_SETUP);
        }

        var residueCascade = new Vector<Int>(64);
        r.begin = decodeState.readBits(24);
        r.end = decodeState.readBits(24);
        r.partSize = decodeState.readBits(24)+1;
        var classifications = r.classifications = decodeState.readBits(6)+1;
        r.classbook = decodeState.readBits(8);

        for (j in 0...r.classifications) {
            var highBits = 0;
            var lowBits = decodeState.readBits(3);
            if (decodeState.readBits(1) != 0){
                highBits = decodeState.readBits(5);
            }
            residueCascade[j] = highBits * 8 + lowBits;
        }

        r.residueBooks = new Vector(r.classifications);
        for (j in 0...r.classifications) {
            r.residueBooks[j] = new Vector(8);
            for (k in 0...8) {
                if (residueCascade[j] & (1 << k) != 0) {
                    r.residueBooks[j][k] = decodeState.readBits(8);
                    if (r.residueBooks[j][k] >= codebooks.length) {
                        throw new ReaderError(INVALID_SETUP);
                    }
                } else {
                    r.residueBooks[j][k] = -1;
                }
            }
        }

        // precompute the classifications[] array to avoid inner-loop mod/divide
        // call it 'classdata' since we already have classifications
        var el = codebooks[r.classbook].entries;
        var classwords = codebooks[r.classbook].dimensions;
        r.classdata = new Vector(el);

        for (j in 0...el) {
            var temp = j;
            var k = classwords;
            var cd = r.classdata[j] = new Vector(classwords);
            while (--k >= 0) {
                cd[k] = temp % classifications;
                temp = Std.int(temp / classifications);
            }
        }

        return r;
    }


    public function decode(decodeState:VorbisDecodeState, header:Header, residueBuffers:Vector<Vector<Float>>, ch:Int, n:Int,  doNotDecode:Vector<Bool>, channelBuffers:Vector<Vector<Float>>)
    {
        // STB_VORBIS_DIVIDES_IN_RESIDUE = true
        var codebooks = header.codebooks;
        var classwords = codebooks[classbook].dimensions;
        var nRead = end - begin;
        var partSize = this.partSize;
        var partRead = Std.int(nRead / partSize);
        var classifications = new Vector<Int>(header.channel * partRead + 1); // + 1 is a hack for a possible crash in line 268 with some ogg files

        VorbisTools.stbProf(2);
        for (i in 0...ch) {
            if (!doNotDecode[i]) {
                var buffer = residueBuffers[i];
                for (j in 0...buffer.length) {
                    buffer[j] = 0;
                }
            }
        }

        if (type == 2 && ch != 1) {
            for (j in 0...ch) {
                if (!doNotDecode[j]) {
                    break;
                } else if (j == ch - 1) {
                    return;
                }
            }

            VorbisTools.stbProf(3);
            for (pass in 0...8) {
                var pcount = 0, classSet = 0;
                if (ch == 2) {
                    VorbisTools.stbProf(13);
                    while (pcount < partRead) {
                        var z = begin + pcount * partSize;
                        var cInter = (z & 1);
                        var pInter = z >> 1;
                        if (pass == 0) {
                            var c:Codebook = codebooks[classbook];
                            var q = decodeState.decode(c);
                            if (q == VorbisTools.EOP) {
                                return;
                            }
                            var i = classwords;
                            while (--i >= 0) {
                                classifications[i + pcount] = q % this.classifications;
                                q = Std.int(q / this.classifications);
                            }
                        }
                        VorbisTools.stbProf(5);
                        for (i in 0...classwords) {
                            if (pcount >= partRead) {
                                break;
                            }
                            var z = begin + pcount*partSize;
                            var c = classifications[pcount];
                            var b = residueBooks[c][pass];
                            if (b >= 0) {
                                var book = codebooks[b];
                                VorbisTools.stbProf(20);  // accounts for X time
                                var result = book.decodeDeinterleaveRepeat(decodeState, residueBuffers, ch, cInter, pInter, n, partSize);
                                if (result == null) {
                                    return;
                                } else {
                                    cInter = result.cInter;
                                    pInter = result.pInter;
                                }
                                VorbisTools.stbProf(7);
                            } else {
                                z += partSize;
                                cInter = z & 1;
                                pInter = z >> 1;
                            }
                            ++pcount;
                        }
                        VorbisTools.stbProf(8);
                    }
                } else if (ch == 1) {
                    while (pcount < partRead) {
                        var z = begin + pcount*partSize;
                        var cInter = 0;
                        var pInter = z;
                        if (pass == 0) {
                            var c:Codebook = codebooks[classbook];
                            var q = decodeState.decode(c);
                            if (q == VorbisTools.EOP) return;

                            var i = classwords;
                            while (--i >= 0) {
                                classifications[i + pcount] = q % this.classifications;
                                q = Std.int(q / this.classifications);
                            }
                        }

                        for (i in 0...classwords) {
                            if (pcount >= partRead) {
                                break;
                            }
                            var z = begin + pcount * partSize;
                            var b = residueBooks[classifications[pcount]][pass];
                            if (b >= 0) {
                                var book:Codebook = codebooks[b];
                                VorbisTools.stbProf(22);
                                var result = book.decodeDeinterleaveRepeat(decodeState, residueBuffers, ch, cInter, pInter, n, partSize);
                                if (result == null) {
                                    return;
                                } else {
                                    cInter = result.cInter;
                                    pInter = result.pInter;
                                }
                                VorbisTools.stbProf(3);
                            } else {
                                z += partSize;
                                cInter = 0;
                                pInter = z;
                            }
                            ++pcount;
                        }
                    }
                } else {
                    while (pcount < partRead) {
                        var z = begin + pcount * partSize;
                        var cInter = z % ch;
                        var pInter = Std.int(z / ch);

                        if (pass == 0) {
                            var c:Codebook = codebooks[classbook];
                            var q = decodeState.decode(c);
                            if (q == VorbisTools.EOP) {
                                return;
                            }

                            var i = classwords;
                            while (--i >= 0) {
                                classifications[i+pcount] = q % this.classifications;
                                q = Std.int(q / this.classifications);
                            }
                        }

                        for (i in 0...classwords) {
                            if (pcount >= partRead) {
                                break;
                            }
                            var z = begin + pcount * partSize;
                            var b = residueBooks[classifications[pcount]][pass];
                            if (b >= 0) {
                                var book = codebooks[b];
                                VorbisTools.stbProf(22);
                                var result = book.decodeDeinterleaveRepeat(decodeState, residueBuffers, ch, cInter, pInter, n, partSize);
                                if (result == null) {
                                    return;
                                } else {
                                    cInter = result.cInter;
                                    pInter = result.pInter;
                                }
                                VorbisTools.stbProf(3);
                            } else {
                                z += partSize;
                                cInter = z % ch;
                                pInter = Std.int(z / ch);
                            }
                            ++pcount;
                        }
                    }
                }
            }
            return;
        }
        VorbisTools.stbProf(9);

        for (pass in 0...8) {
            var pcount = 0;
            var classSet = 0;
            while (pcount < partRead) {
                if (pass == 0) {
                    for (j in 0...ch) {
                        if (!doNotDecode[j]) {
                            var c:Codebook = codebooks[classbook];
                            var temp = decodeState.decode(c);
                            if (temp == VorbisTools.EOP) {
                                return;
                            }
                            var i = classwords;
                            while (--i >= 0) {
                                classifications[j * partRead + i + pcount] = temp % this.classifications;
                                temp = Std.int(temp / this.classifications);
                            }
                        }
                    }
                }
                for (i in 0...classwords) {
                    if (pcount >= partRead) {
                        break;
                    }
                    for (j in 0...ch) {
                        if (!doNotDecode[j]) {
                            var c = classifications[j  * partRead + pcount];
                            var b = residueBooks[c][pass];
                            if (b >= 0) {
                                var target = residueBuffers[j];
                                var offset = begin + pcount * partSize;
                                var n = partSize;
                                var book = codebooks[b];
                                if (!book.residueDecode(decodeState, target, offset, n, type)) {
                                    return;
                                }
                            }
                        }
                    }
                    ++pcount;
                }
            }
        }
    }
}
