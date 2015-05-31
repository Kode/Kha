package kha.audio2.ogg.vorbis.data;
import haxe.ds.Vector;
import haxe.io.Input;
import kha.audio2.ogg.tools.MathTools;
import kha.audio2.ogg.vorbis.VorbisDecodeState;

class Mapping
{
    public var couplingSteps:Int; // uint16 
    public var chan:Vector<MappingChannel>;
    public var submaps:Int;            // uint8 
    public var submapFloor:Vector<Int>;   // uint8 varies
    public var submapResidue:Vector<Int>; // uint8 varies
    public function new() {
    }
    
    public static function read(decodeState:VorbisDecodeState, channels:Int):Mapping
    {
        var m = new Mapping();
        var mappingType = decodeState.readBits(16);
        if (mappingType != 0) {
            throw new ReaderError(INVALID_SETUP, "mapping type " + mappingType);
        }
        
        m.chan = new Vector(channels);
        for (j in 0...channels) {
            m.chan[j] = new MappingChannel();
        }
        
        if (decodeState.readBits(1) != 0) {
            m.submaps = decodeState.readBits(4)+1;
        } else {
            m.submaps = 1;
        }
        
        //if (m.submaps > maxSubmaps) {
        //    maxSubmaps = m.submaps;
        //}
        
        if (decodeState.readBits(1) != 0) {
            m.couplingSteps = decodeState.readBits(8)+1;
            for (k in 0...m.couplingSteps) {
                m.chan[k].magnitude = decodeState.readBits(MathTools.ilog(channels-1));
                m.chan[k].angle = decodeState.readBits(MathTools.ilog(channels-1));
                if (m.chan[k].magnitude >= channels) {
                    throw new ReaderError(INVALID_SETUP);
                }
                if (m.chan[k].angle >= channels) {
                    throw new ReaderError(INVALID_SETUP);
                }
                if (m.chan[k].magnitude == m.chan[k].angle) {
                    throw new ReaderError(INVALID_SETUP);
                }
            }
        } else {
            m.couplingSteps = 0;
        }

        // reserved field
        if (decodeState.readBits(2) != 0) {
            throw new ReaderError(INVALID_SETUP);
        }
        if (m.submaps > 1) {
            for (j in 0...channels) {
                m.chan[j].mux = decodeState.readBits(4);
                if (m.chan[j].mux >= m.submaps) {
                    throw new ReaderError(INVALID_SETUP);
                }
            }
        } else {
            for (j in 0...channels) {
                m.chan[j].mux = 0;
            }
        }
        
        m.submapFloor = new Vector(m.submaps);
        m.submapResidue = new Vector(m.submaps);
        
        for (j in 0...m.submaps) {
            decodeState.readBits(8); // discard
            m.submapFloor[j] = decodeState.readBits(8);
            m.submapResidue[j] = decodeState.readBits(8);
        }
        
        return m;
    }
    
    public function doFloor(floors:Vector<Floor>, i:Int, n:Int, target:Vector<Float>, finalY:Array<Int>, step2Flag:Vector<Bool>) 
    {
        var n2 = n >> 1;
        var s = chan[i].mux, floor;
        var floor = floors[submapFloor[s]];
        if (floor.type == 0) {
            throw new ReaderError(INVALID_STREAM);
        } else {
            var g = floor.floor1;
            var lx = 0, ly = finalY[0] * g.floor1Multiplier;
            for (q in 1...g.values) {
                var j = g.sortedOrder[q];
                if (finalY[j] >= 0)
                {
                    var hy = finalY[j] * g.floor1Multiplier;
                    var hx = g.xlist[j];
                    VorbisTools.drawLine(target, lx, ly, hx, hy, n2);
                    lx = hx;
                    ly = hy;
                }
            }
            if (lx < n2) {
                // optimization of: drawLine(target, lx,ly, n,ly, n2);
                for (j in lx...n2) {
                    target[j] *= VorbisTools.INVERSE_DB_TABLE[ly];
                }
            }
        }
    }
}

class MappingChannel
{
    public var magnitude:Int; // uint8 
    public var angle:Int;     // uint8 
    public var mux:Int;       // uint8 
    
    public function new() {
    }
}
