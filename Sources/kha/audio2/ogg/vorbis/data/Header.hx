package kha.audio2.ogg.vorbis.data;
import haxe.ds.Vector;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.io.Input;
import haxe.io.Output;
import kha.audio2.ogg.vorbis.data.Comment;
import kha.audio2.ogg.vorbis.data.Page.PageFlag;
import kha.audio2.ogg.vorbis.data.ReaderError.ReaderErrorType;
import kha.audio2.ogg.vorbis.VorbisDecodeState;

/**
 * ...
 * @author shohei909
 */
class Header {

    static public inline var PACKET_ID = 1;
    static public inline var PACKET_COMMENT = 3;
    static public inline var PACKET_SETUP = 5;

    public var maximumBitRate(default, null):UInt;
    public var nominalBitRate(default, null):UInt;
    public var minimumBitRate(default, null):UInt;
    public var sampleRate(default, null):UInt;
    public var channel(default, null):Int;
    public var blocksize0(default, null):Int;
    public var blocksize1(default, null):Int;
    public var codebooks(default, null):Vector<Codebook>;
    public var floorConfig(default, null):Vector<Floor>;
    public var residueConfig(default, null):Vector<Residue>;
    public var mapping(default, null):Vector<Mapping>;
    public var modes(default, null):Vector<Mode>; // [64] varies
    public var comment(default, null):Comment;
    public var vendor(default, null):String;

    function new() {

    }

    static public function read(decodeState:VorbisDecodeState):Header {
        var page = decodeState.page;
        page.start(decodeState);

        if ((page.flag & PageFlag.FIRST_PAGE) == 0) {
            throw new ReaderError(INVALID_FIRST_PAGE, "not firstPage");
        }
        if ((page.flag & PageFlag.LAST_PAGE) != 0) {
            throw new ReaderError(INVALID_FIRST_PAGE, "lastPage");
        }
        if ((page.flag & PageFlag.CONTINUED_PACKET) != 0) {
            throw new ReaderError(INVALID_FIRST_PAGE, "continuedPacket");
        }

        decodeState.firstPageValidate();
        if (decodeState.readByte() != PACKET_ID) {
            throw new ReaderError(INVALID_FIRST_PAGE, "decodeState head");
        }

        // vorbis header
        decodeState.vorbisValidate();

        // vorbisVersion
        var version = decodeState.readInt32();
        if (version != 0) {
            throw new ReaderError(INVALID_FIRST_PAGE, "vorbis version : " + version);
        }

        var header = new Header();

        header.channel = decodeState.readByte();
        if (header.channel == 0) {
            throw new ReaderError(INVALID_FIRST_PAGE, "no channel");
        } else if (header.channel > Setting.MAX_CHANNELS) {
            throw new ReaderError(TOO_MANY_CHANNELS, "too many channels");
        }

        header.sampleRate = decodeState.readInt32();
        if (header.sampleRate == 0) {
            throw new ReaderError(INVALID_FIRST_PAGE, "no sampling rate");
        }

        header.maximumBitRate = decodeState.readInt32();
        header.nominalBitRate = decodeState.readInt32();
        header.minimumBitRate = decodeState.readInt32();

        var x = decodeState.readByte();
        var log0 = x & 15;
        var log1 = x >> 4;
        header.blocksize0 = 1 << log0;
        header.blocksize1 = 1 << log1;
        if (log0 < 6 || log0 > 13) {
            throw new ReaderError(INVALID_SETUP);
        }
        if (log1 < 6 || log1 > 13) {
            throw new ReaderError(INVALID_SETUP);
        }
        if (log0 > log1) {
            throw new ReaderError(INVALID_SETUP);
        }

        // framingFlag
        var x = decodeState.readByte();
        if (x & 1 == 0) {
            throw new ReaderError(INVALID_FIRST_PAGE);
        }

        // comment fields
        decodeState.page.start(decodeState);
        decodeState.startPacket();

        var len = 0;
        var output = new BytesOutput();
        while((len = decodeState.next()) != 0) {
            output.write(decodeState.readBytes(len));
            decodeState.bytesInSeg = 0;
        }

        {
            var packetInput = new BytesInput(output.getBytes());
            packetInput.readByte();
            packetInput.read(6);

            var vendorLength:UInt = packetInput.readInt32();
            header.vendor = packetInput.readString(vendorLength);
            header.comment = new Comment();

            var commentCount = packetInput.readInt32();

            for (i in 0...commentCount) {
                var n = packetInput.readInt32();
                var str = packetInput.readString(n);
                var splitter = str.indexOf("=");
                if (splitter != -1) {
                    header.comment.add(str.substring(0, splitter), str.substring(splitter + 1));
                }
            }

            var x = packetInput.readByte();
            if (x & 1 == 0) {
                throw new ReaderError(ReaderErrorType.INVALID_SETUP);
            }
        }

        // third packet!
        decodeState.startPacket();

        if (decodeState.readPacket() != PACKET_SETUP) {
            throw new ReaderError(ReaderErrorType.INVALID_SETUP, "setup packet");
        }

        decodeState.vorbisValidate();

        // codebooks
        var codebookCount = decodeState.readBits(8) + 1;
        header.codebooks = new Vector(codebookCount);
        for (i in 0...codebookCount) {
            header.codebooks[i] = Codebook.read(decodeState);
        }

        // time domain transfers (notused)
        x = decodeState.readBits(6) + 1;
        for (i in 0...x) {
            if (decodeState.readBits(16) != 0) {
                throw new ReaderError(INVALID_SETUP);
            }
        }

        // Floors
        var floorCount = decodeState.readBits(6) + 1;
        header.floorConfig = new Vector(floorCount);
        for (i in 0...floorCount) {
            header.floorConfig[i] = Floor.read(decodeState, header.codebooks);
        }

        // Residue
        var residueCount = decodeState.readBits(6) + 1;
        header.residueConfig = new Vector(residueCount);
        for (i in 0...residueCount) {
            header.residueConfig[i] = Residue.read(decodeState, header.codebooks);
        }

        //Mapping
        var mappingCount = decodeState.readBits(6) + 1;
        header.mapping = new Vector(mappingCount);
        for (i in 0...mappingCount) {
            var map = Mapping.read(decodeState, header.channel);
            header.mapping[i] = map;
            for (j in 0...map.submaps) {
                if (map.submapFloor[j] >= header.floorConfig.length) {
                    throw new ReaderError(INVALID_SETUP);
                }
                if (map.submapResidue[j] >= header.residueConfig.length) {
                    throw new ReaderError(INVALID_SETUP);
                }
            }
        }

        var modeCount = decodeState.readBits(6) + 1;
        header.modes = new Vector(modeCount);
        for (i in 0...modeCount) {
            var mode = Mode.read(decodeState);
            header.modes[i] = mode;
            if (mode.mapping >= header.mapping.length) {
                throw new ReaderError(INVALID_SETUP);
            }
        }

        decodeState.flushPacket();

        return header;
    }
}
