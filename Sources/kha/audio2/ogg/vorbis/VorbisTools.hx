package kha.audio2.ogg.vorbis;
import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.Input;
import haxe.PosInfos;
import kha.audio2.ogg.vorbis.data.IntPoint;
import kha.audio2.ogg.vorbis.data.ReaderError;
import kha.audio2.ogg.tools.MathTools;

/**
 * ...
 * @author shohei909
 */
class VorbisTools
{
    static public inline var EOP = -1;
    static public var integerDivideTable:Vector<Vector<Int>>;
    static inline var M__PI = 3.14159265358979323846264;

    static inline var DIVTAB_NUMER = 32;
    static inline var DIVTAB_DENOM = 64;

    static public var INVERSE_DB_TABLE = [
        1.0649863e-07, 1.1341951e-07, 1.2079015e-07, 1.2863978e-07,
        1.3699951e-07, 1.4590251e-07, 1.5538408e-07, 1.6548181e-07,
        1.7623575e-07, 1.8768855e-07, 1.9988561e-07, 2.1287530e-07,
        2.2670913e-07, 2.4144197e-07, 2.5713223e-07, 2.7384213e-07,
        2.9163793e-07, 3.1059021e-07, 3.3077411e-07, 3.5226968e-07,
        3.7516214e-07, 3.9954229e-07, 4.2550680e-07, 4.5315863e-07,
        4.8260743e-07, 5.1396998e-07, 5.4737065e-07, 5.8294187e-07,
        6.2082472e-07, 6.6116941e-07, 7.0413592e-07, 7.4989464e-07,
        7.9862701e-07, 8.5052630e-07, 9.0579828e-07, 9.6466216e-07,
        1.0273513e-06, 1.0941144e-06, 1.1652161e-06, 1.2409384e-06,
        1.3215816e-06, 1.4074654e-06, 1.4989305e-06, 1.5963394e-06,
        1.7000785e-06, 1.8105592e-06, 1.9282195e-06, 2.0535261e-06,
        2.1869758e-06, 2.3290978e-06, 2.4804557e-06, 2.6416497e-06,
        2.8133190e-06, 2.9961443e-06, 3.1908506e-06, 3.3982101e-06,
        3.6190449e-06, 3.8542308e-06, 4.1047004e-06, 4.3714470e-06,
        4.6555282e-06, 4.9580707e-06, 5.2802740e-06, 5.6234160e-06,
        5.9888572e-06, 6.3780469e-06, 6.7925283e-06, 7.2339451e-06,
        7.7040476e-06, 8.2047000e-06, 8.7378876e-06, 9.3057248e-06,
        9.9104632e-06, 1.0554501e-05, 1.1240392e-05, 1.1970856e-05,
        1.2748789e-05, 1.3577278e-05, 1.4459606e-05, 1.5399272e-05,
        1.6400004e-05, 1.7465768e-05, 1.8600792e-05, 1.9809576e-05,
        2.1096914e-05, 2.2467911e-05, 2.3928002e-05, 2.5482978e-05,
        2.7139006e-05, 2.8902651e-05, 3.0780908e-05, 3.2781225e-05,
        3.4911534e-05, 3.7180282e-05, 3.9596466e-05, 4.2169667e-05,
        4.4910090e-05, 4.7828601e-05, 5.0936773e-05, 5.4246931e-05,
        5.7772202e-05, 6.1526565e-05, 6.5524908e-05, 6.9783085e-05,
        7.4317983e-05, 7.9147585e-05, 8.4291040e-05, 8.9768747e-05,
        9.5602426e-05, 0.00010181521, 0.00010843174, 0.00011547824,
        0.00012298267, 0.00013097477, 0.00013948625, 0.00014855085,
        0.00015820453, 0.00016848555, 0.00017943469, 0.00019109536,
        0.00020351382, 0.00021673929, 0.00023082423, 0.00024582449,
        0.00026179955, 0.00027881276, 0.00029693158, 0.00031622787,
        0.00033677814, 0.00035866388, 0.00038197188, 0.00040679456,
        0.00043323036, 0.00046138411, 0.00049136745, 0.00052329927,
        0.00055730621, 0.00059352311, 0.00063209358, 0.00067317058,
        0.00071691700, 0.00076350630, 0.00081312324, 0.00086596457,
        0.00092223983, 0.00098217216, 0.0010459992,  0.0011139742,
        0.0011863665,  0.0012634633,  0.0013455702,  0.0014330129,
        0.0015261382,  0.0016253153,  0.0017309374,  0.0018434235,
        0.0019632195,  0.0020908006,  0.0022266726,  0.0023713743,
        0.0025254795,  0.0026895994,  0.0028643847,  0.0030505286,
        0.0032487691,  0.0034598925,  0.0036847358,  0.0039241906,
        0.0041792066,  0.0044507950,  0.0047400328,  0.0050480668,
        0.0053761186,  0.0057254891,  0.0060975636,  0.0064938176,
        0.0069158225,  0.0073652516,  0.0078438871,  0.0083536271,
        0.0088964928,  0.009474637,   0.010090352,   0.010746080,
        0.011444421,   0.012188144,   0.012980198,   0.013823725,
        0.014722068,   0.015678791,   0.016697687,   0.017782797,
        0.018938423,   0.020169149,   0.021479854,   0.022875735,
        0.024362330,   0.025945531,   0.027631618,   0.029427276,
        0.031339626,   0.033376252,   0.035545228,   0.037855157,
        0.040315199,   0.042935108,   0.045725273,   0.048696758,
        0.051861348,   0.055231591,   0.058820850,   0.062643361,
        0.066714279,   0.071049749,   0.075666962,   0.080584227,
        0.085821044,   0.091398179,   0.097337747,   0.10366330,
        0.11039993,    0.11757434,    0.12521498,    0.13335215,
        0.14201813,    0.15124727,    0.16107617,    0.17154380,
        0.18269168,    0.19456402,    0.20720788,    0.22067342,
        0.23501402,    0.25028656,    0.26655159,    0.28387361,
        0.30232132,    0.32196786,    0.34289114,    0.36517414,
        0.38890521,    0.41417847,    0.44109412,    0.46975890,
        0.50028648,    0.53279791,    0.56742212,    0.60429640,
        0.64356699,    0.68538959,    0.72993007,    0.77736504,
        0.82788260,    0.88168307,    0.9389798,     1.0
    ];

    public static inline function assert(b:Bool, ?p:PosInfos) {
#if debug
        if (!b) {
            throw new ReaderError(ReaderErrorType.OTHER, "", p);
        }
#end
    }

    public static inline function neighbors(x:Vector<Int>, n:Int)
    {
        var low = -1;
        var high = 65536;
        var plow  = 0;
        var phigh = 0;

        for (i in 0...n) {
            if (x[i] > low  && x[i] < x[n]) { plow  = i; low = x[i]; }
            if (x[i] < high && x[i] > x[n]) { phigh = i; high = x[i]; }
        }
        return {
            low : plow,
            high : phigh,
        }
    }

    public static inline function floatUnpack(x:UInt):Float
    {
        // from the specification
        var mantissa:Float = x & 0x1fffff;
        var sign:Int = x & 0x80000000;
        var exp:Int = (x & 0x7fe00000) >>> 21;
        var res:Float = (sign != 0) ? -mantissa : mantissa;
        return res * Math.pow(2, exp - 788);
    }

    public static inline function bitReverse(n:UInt):UInt
    {
        n = ((n & 0xAAAAAAAA) >>>  1) | ((n & 0x55555555) << 1);
        n = ((n & 0xCCCCCCCC) >>>  2) | ((n & 0x33333333) << 2);
        n = ((n & 0xF0F0F0F0) >>>  4) | ((n & 0x0F0F0F0F) << 4);
        n = ((n & 0xFF00FF00) >>>  8) | ((n & 0x00FF00FF) << 8);
        return (n >>> 16) | (n << 16);
    }

    public static inline function pointCompare(a:IntPoint, b:IntPoint) {
        return if (a.x < b.x) -1 else if (a.x > b.x) 1 else 0;
    }

    public static function uintAsc(a:UInt, b:UInt) {
        return if (a < b) {
            -1;
        } else if (a == b){
            0;
        } else {
            1;
        }
    }

    public static function lookup1Values(entries:Int, dim:Int)
    {
        var r = Std.int(Math.exp(Math.log(entries) / dim));
        if (Std.int(Math.pow(r + 1, dim)) <= entries) {
            r++;
        }

        assert(Math.pow(r+1, dim) > entries);
        assert(Std.int(Math.pow(r, dim)) <= entries); // (int),floor() as above
        return r;
    }

    public static function computeWindow(n:Int, window:Vector<Float>)
    {
        var n2 = n >> 1;
        for (i in 0...n2) {
            window[i] = Math.sin(0.5 * M__PI * square(Math.sin((i - 0 + 0.5) / n2 * 0.5 * M__PI)));
        }
    }

    public static function square(f:Float) {
        return f * f;
    }

    public static function computeBitReverse(n:Int, rev:Vector<Int>)
    {
        var ld = MathTools.ilog(n) - 1;
        var n8 = n >> 3;

        for (i in 0...n8) {
          rev[i] = (bitReverse(i) >>> (32 - ld + 3)) << 2;
        }
    }

    public static function computeTwiddleFactors(n:Int, af:Vector<Float>, bf:Vector<Float>, cf:Vector<Float>)
    {
        var n4 = n >> 2;
        var n8 = n >> 3;

        var k2 = 0;
        for (k in 0...n4) {
            af[k2] = Math.cos(4*k*M__PI/n);
            af[k2 + 1] = -Math.sin(4*k*M__PI/n);
            bf[k2] = Math.cos((k2+1)*M__PI/n/2) * 0.5;
            bf[k2 + 1] = Math.sin((k2 + 1) * M__PI / n / 2) * 0.5;
            k2 += 2;
        }

        var k2 = 0;
        for (k in 0...n8) {
            cf[k2  ] = Math.cos(2*(k2+1) * M__PI/n);
            cf[k2+1] = -Math.sin(2*(k2+1) * M__PI/n);
            k2 += 2;
        }
    }


    public static function drawLine(output:Vector<Float>, x0:Int, y0:Int, x1:Int, y1:Int, n:Int)
    {
        if (integerDivideTable == null) {
            integerDivideTable = new Vector(DIVTAB_NUMER);
            for (i in 0...DIVTAB_NUMER) {
                integerDivideTable[i] = new Vector(DIVTAB_DENOM);
                for (j in 1...DIVTAB_DENOM) {
                    integerDivideTable[i][j] = Std.int(i / j);
                }
            }
        }

        var dy = y1 - y0;
        var adx = x1 - x0;
        var ady = dy < 0 ? -dy : dy;
        var base:Int;
        var x = x0;
        var y = y0;
        var err = 0;
        var sy = if (adx < DIVTAB_DENOM && ady < DIVTAB_NUMER) {
            if (dy < 0) {
                base = -integerDivideTable[ady][adx];
                base - 1;
            } else {
                base = integerDivideTable[ady][adx];
                base + 1;
            }
        } else {
            base = Std.int(dy / adx);
            if (dy < 0) {
                base - 1;
            } else {
                base + 1;
            }
        }
        ady -= (base < 0 ? -base : base) * adx;
        if (x1 > n) {
            x1 = n;
        }

        output[x] *= INVERSE_DB_TABLE[y];

        for (i in (x + 1)...x1) {
            err += ady;
            if (err >= adx) {
                err -= adx;
                y += sy;
            } else {
                y += base;
            }
            output[i] *= INVERSE_DB_TABLE[y];
        }
    }

    public macro static inline function stbProf(i:Int)
    {
    return macro null;// macro trace($v { i }, channelBuffers[0][0], channelBuffers[0][1]);
    }

    public static inline function predictPoint(x:Int, x0:Int,  x1:Int,  y0:Int, y1:Int):Int
    {
        var dy = y1 - y0;
        var adx = x1 - x0;
        // @OPTIMIZE: force int division to round in the right direction... is this necessary on x86?
        var err = Math.abs(dy) * (x - x0);
        var off = Std.int(err / adx);
        return dy < 0 ? (y0 - off) : (y0 + off);
    }

    public static inline function emptyFloatVector(len:Int) {
        var vec = new Vector<Float>(len);
        #if neko
        for (i in 0...len) {
            vec[i] = 0;
        }
        #end
        return vec;
    }

    static public function copyVector(source:Vector<Float>):Vector<Float> {
        var dest:Vector<Float> = new Vector<Float>(source.length);
        for (i in 0...source.length) {
            dest[i] = source[i];
        }
        return dest;
    }
}
