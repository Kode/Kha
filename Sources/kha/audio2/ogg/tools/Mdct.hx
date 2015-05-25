package kha.audio2.ogg.tools;
import haxe.ds.Vector;

/**
 * modified discrete cosine transform
 * @author shohei909
 */
class Mdct {
    static public inline function inverseTransform(buffer:Vector<Float>, n:Int, a:Vector<Float>, b:Vector<Float>, c:Vector<Float>, bitReverse:Vector<Int>)
    {
        var n2 = n >> 1;
        var n4 = n >> 2;
        var n8 = n >> 3;
        // @OPTIMIZE: reduce register pressure by using fewer variables?
        //int save_point = temp_alloc_save(f);

        var buf2 = new Vector(n2);
        // twiddle factors

        // IMDCT algorithm from "The use of multirate filter banks for coding of high quality digital audio"
        // See notes about bugs in that paper in less-optimal implementation 'inverseMdct_old' after this function.

        // kernel from paper


        // merged:
        //    copy and reflect spectral data
        //    step 0

        // note that it turns out that the items added together during
        // this step are, in fact, being added to themselves (as reflected
        // by step 0). inexplicable inefficiency! this became obvious
        // once I combined the passes.

        // so there's a missing 'times 2' here (for adding X to itself).
        // this propogates through linearly to the end, where the numbers
        // are 1/2 too small, and need to be compensated for.

        {
            var dOffset = n2 - 2;
            var aaOffset = 0;
            var eOffset = 0;
            var eStopOffset = n2;
            while (eOffset != eStopOffset) {
                buf2[dOffset + 1] = (buffer[eOffset + 0] * a[aaOffset + 0] - buffer[eOffset + 2] * a[aaOffset + 1]);
                buf2[dOffset + 0] = (buffer[eOffset + 0] * a[aaOffset + 1] + buffer[eOffset + 2] * a[aaOffset + 0]);
                dOffset -= 2;
                aaOffset += 2;
                eOffset += 4;
            }

            eOffset = n2 - 3;
            while (dOffset >= 0) {
                buf2[dOffset + 1] = (-buffer[eOffset + 2] * a[aaOffset + 0] - -buffer[eOffset + 0]*a[aaOffset + 1]);
                buf2[dOffset + 0] = (-buffer[eOffset + 2] * a[aaOffset + 1] + -buffer[eOffset + 0]*a[aaOffset + 0]);
                dOffset -= 2;
                aaOffset += 2;
                eOffset -= 4;
            }
        }

        // now we use symbolic names for these, so that we can
        // possibly swap their meaning as we change which operations
        // are in place

        var u = buffer;
        var v = buf2;

        // step 2     (paper output is w, now u)
        // this could be in place, but the data ends up in the wrong
        // place... _somebody_'s got to swap it, so this is nominated
        {
            var aaOffset = n2 - 8;
            var eOffset0 = n4;
            var eOffset1 = 0;

            var dOffset0 = n4;
            var dOffset1 = 0;

            while (aaOffset >= 0) {

                var v41_21:Float = v[eOffset0 + 1] - v[eOffset1 + 1];
                var v40_20:Float = v[eOffset0 + 0] - v[eOffset1 + 0];
                u[dOffset0 + 1]  = v[eOffset0 + 1] + v[eOffset1 + 1];
                u[dOffset0 + 0]  = v[eOffset0 + 0] + v[eOffset1 + 0];
                u[dOffset1 + 1]  = v41_21*a[aaOffset + 4] - v40_20*a[aaOffset + 5];
                u[dOffset1 + 0]  = v40_20*a[aaOffset + 4] + v41_21*a[aaOffset + 5];

                v41_21 = v[eOffset0 + 3] - v[eOffset1 + 3];
                v40_20 = v[eOffset0 + 2] - v[eOffset1 + 2];
                u[dOffset0 + 3]  = v[eOffset0 + 3] + v[eOffset1 + 3];
                u[dOffset0 + 2]  = v[eOffset0 + 2] + v[eOffset1 + 2];
                u[dOffset1 + 3]  = v41_21*a[aaOffset + 0] - v40_20*a[aaOffset + 1];
                u[dOffset1 + 2]  = v40_20*a[aaOffset + 0] + v41_21*a[aaOffset + 1];

                aaOffset -= 8;

                dOffset0 += 4;
                dOffset1 += 4;
                eOffset0 += 4;
                eOffset1 += 4;
            }

        }

        // step 3
        var ld = MathTools.ilog(n) - 1; // ilog is off-by-one from normal definitions

        // optimized step 3:

        // the original step3 loop can be nested r inside s or s inside r;
        // it's written originally as s inside r, but this is dumb when r
        // iterates many times, and s few. So I have two copies of it and
        // switch between them halfway.

        // this is iteration 0 of step 3
        step3Iter0Loop(n >> 4, u, n2-1-n4*0, -(n >> 3), a);
        step3Iter0Loop(n >> 4, u, n2-1-n4*1, -(n >> 3), a);

        // this is iteration 1 of step 3
        step3InnerRLoop(n >> 5, u, n2-1 - n8*0, -(n >> 4), a, 16);
        step3InnerRLoop(n >> 5, u, n2-1 - n8*1, -(n >> 4), a, 16);
        step3InnerRLoop(n >> 5, u, n2-1 - n8*2, -(n >> 4), a, 16);
        step3InnerRLoop(n >> 5, u, n2-1 - n8*3, -(n >> 4), a, 16);

        for (l in 2...((ld - 3) >> 1)) {
            var k0 = n >> (l + 2);
            var k0_2 = k0 >> 1;
            var lim = 1 << (l+1);
            for (i in 0...lim) {
                step3InnerRLoop(n >> (l + 4), u, n2 - 1 - k0 * i, -k0_2, a, 1 << (l + 3));
            }
        }

        for (l in ((ld - 3) >> 1)...(ld-6)) {
            var k0 = n >> (l + 2);
            var k1 = 1 << (l + 3);
            var k0_2 = k0 >> 1;
            var rlim = n >> (l+6);
            var lim = 1 << (l+1);
            var aOffset = 0;
            var i_off = n2 - 1;
            var r = rlim + 1;
            while (--r > 0) {
                step3InnerSLoop(lim, u, i_off, -k0_2, a, aOffset, k1, k0);
                aOffset += k1 * 4;
                i_off -= 8;
            }
        }


        // iterations with count:
        //    ld-6,-5,-4 all interleaved together
        //         the big win comes from getting rid of needless flops
        //            due to the constants on pass 5 & 4 being all 1 and 0;
        //         combining them to be simultaneous to improve cache made little difference
        step3InnerSLoopLd654(n >> 5, u, n2-1, a, n);


        // output is u

        // step 4, 5, and 6
        // cannot be in-place because of step 5
        {
            // weirdly, I'd have thought reading sequentially and writing
            // erratically would have been better than vice-versa, but in
            // fact that's not what my testing showed. (That is, with
            // j = bitreverse(i), do you read i and write j, or read j and write i.)
            var brOffset = 0;
            var dOffset0 = n4-4; // v
            var dOffset1 = n2-4; // v

            while (dOffset0 >= 0) {
                var k4 = bitReverse[brOffset + 0];
                v[dOffset1 +3] = u[k4+0];
                v[dOffset1 +2] = u[k4+1];
                v[dOffset0 +3] = u[k4+2];
                v[dOffset0 +2] = u[k4+3];

                k4 = bitReverse[brOffset + 1];
                v[dOffset1 +1] = u[k4+0];
                v[dOffset1 +0] = u[k4+1];
                v[dOffset0 +1] = u[k4+2];
                v[dOffset0 +0] = u[k4+3];

                dOffset0 -= 4;
                dOffset1 -= 4;
                brOffset += 2;
            }
        }

        // (paper output is u, now v)

        // data must be in buf2
        //assert(v == buf2);

        // step 7    (paper output is v, now v)
        // this is now in place
        {
            var cOffset = 0;
            var dOffset = 0; // v
            var eOffset = n2 - 4; // v

            while (dOffset < eOffset) {
                var a02 = v[dOffset + 0] - v[eOffset + 2];
                var a11 = v[dOffset + 1] + v[eOffset + 3];

                var b0 = c[cOffset + 1]*a02 + c[cOffset + 0]*a11;
                var b1 = c[cOffset + 1]*a11 - c[cOffset + 0]*a02;

                var b2 = v[dOffset + 0] + v[eOffset + 2];
                var b3 = v[dOffset + 1] - v[eOffset + 3];

                v[dOffset + 0] = b2 + b0;
                v[dOffset + 1] = b3 + b1;
                v[eOffset + 2] = b2 - b0;
                v[eOffset + 3] = b1 - b3;

                a02 = v[dOffset + 2] - v[eOffset + 0];
                a11 = v[dOffset + 3] + v[eOffset + 1];

                b0 = c[cOffset + 3]*a02 + c[cOffset + 2]*a11;
                b1 = c[cOffset + 3]*a11 - c[cOffset + 2]*a02;

                b2 = v[dOffset + 2] + v[eOffset + 0];
                b3 = v[dOffset + 3] - v[eOffset + 1];

                v[dOffset + 2] = b2 + b0;
                v[dOffset + 3] = b3 + b1;
                v[eOffset + 0] = b2 - b0;
                v[eOffset + 1] = b1 - b3;

                cOffset += 4;
                dOffset += 4;
                eOffset -= 4;
            }
        }

        // data must be in buf2

        // step 8+decode    (paper output is X, now buffer)
        // this generates pairs of data a la 8 and pushes them directly through
        // the decode kernel (pushing rather than pulling) to avoid having
        // to make another pass later

        // this cannot POSSIBLY be in place, so we refer to the buffers directly

        {
            var bOffset = n2 - 8; //b
            var eOffset = n2 - 8; //buf2
            var dOffset0 = 0; //buffer
            var dOffset1 = n2-4; //buffer
            var dOffset2 = n2; //buffer
            var dOffset3 = n - 4; //buffer

            while (eOffset >= 0) {
                var p3 =  buf2[eOffset + 6]*b[bOffset + 7] - buf2[eOffset + 7]*b[bOffset + 6];
                var p2 = -buf2[eOffset + 6]*b[bOffset + 6] - buf2[eOffset + 7]*b[bOffset + 7];

                buffer[dOffset0 + 0] =    p3;
                buffer[dOffset1 + 3] = - p3;
                buffer[dOffset2 + 0] =    p2;
                buffer[dOffset3 + 3] =    p2;

                var p1 =  buf2[eOffset + 4]*b[bOffset + 5] - buf2[eOffset + 5]*b[bOffset + 4];
                var p0 = -buf2[eOffset + 4]*b[bOffset + 4] - buf2[eOffset + 5]*b[bOffset + 5];

                buffer[dOffset0 + 1] =    p1;
                buffer[dOffset1 + 2] = - p1;
                buffer[dOffset2 + 1] =    p0;
                buffer[dOffset3 + 2] =    p0;

                p3 =  buf2[eOffset + 2]*b[bOffset + 3] - buf2[eOffset + 3]*b[bOffset + 2];
                p2 = -buf2[eOffset + 2]*b[bOffset + 2] - buf2[eOffset + 3]*b[bOffset + 3];

                buffer[dOffset0 + 2] =    p3;
                buffer[dOffset1 + 1] = - p3;
                buffer[dOffset2 + 2] =    p2;
                buffer[dOffset3 + 1] =    p2;

                p1 =  buf2[eOffset + 0]*b[bOffset + 1] - buf2[eOffset + 1]*b[bOffset + 0];
                p0 = -buf2[eOffset + 0]*b[bOffset + 0] - buf2[eOffset + 1]*b[bOffset + 1];

                buffer[dOffset0 + 3] =    p1;
                buffer[dOffset1 + 0] = - p1;
                buffer[dOffset2 + 3] =    p0;
                buffer[dOffset3 + 0] =    p0;

                bOffset -= 8;
                eOffset -= 8;
                dOffset0 += 4;
                dOffset2 += 4;
                dOffset1 -= 4;
                dOffset3 -= 4;
            }
        }
    }


    // the following were split out into separate functions while optimizing;
    // they could be pushed back up but eh. __forceinline showed no change;
    // they're probably already being inlined.
    static inline function step3Iter0Loop(n:Int, e:Vector<Float>, i_off:Int, k_off:Int, a:Vector<Float>)
    {
        var eeOffset0 = i_off; // e
        var eeOffset2 = i_off + k_off; // e
        var aOffset = 0;
        var i = (n >> 2) + 1;

        while (--i > 0) {
            var k00_20  = e[eeOffset0 +  0] - e[eeOffset2 +  0];
            var k01_21  = e[eeOffset0 + -1] - e[eeOffset2 + -1];

            e[eeOffset0 +  0] += e[eeOffset2 +  0];//e[eeOffset0 +  0] = e[eeOffset0 +  0] + e[eeOffset2 +  0];
            e[eeOffset0 + -1] += e[eeOffset2 + -1];//e[eeOffset0 + -1] = e[eeOffset0 + -1] + e[eeOffset2 + -1];
            e[eeOffset2 +  0] = k00_20 * a[aOffset + 0] - k01_21 * a[aOffset + 1];
            e[eeOffset2 + -1] = k01_21 * a[aOffset + 0] + k00_20 * a[aOffset + 1];
            aOffset +=  8;

            k00_20  = e[eeOffset0 + -2] - e[eeOffset2 + -2];
            k01_21  = e[eeOffset0 + -3] - e[eeOffset2 + -3];
            e[eeOffset0 + -2] += e[eeOffset2 + -2];//e[eeOffset0 + -2] = e[eeOffset0 + -2] + e[eeOffset2 + -2];
            e[eeOffset0 + -3] += e[eeOffset2 + -3];//e[eeOffset0 + -3] = e[eeOffset0 + -3] + e[eeOffset2 + -3];
            e[eeOffset2 + -2] = k00_20 * a[aOffset + 0] - k01_21 * a[aOffset + 1];
            e[eeOffset2 + -3] = k01_21 * a[aOffset + 0] + k00_20 * a[aOffset + 1];
            aOffset +=  8;

            k00_20  = e[eeOffset0 + -4] - e[eeOffset2 + -4];
            k01_21  = e[eeOffset0 + -5] - e[eeOffset2 + -5];
            e[eeOffset0 + -4] += e[eeOffset2 + -4];//e[eeOffset0 + -4] = e[eeOffset0 + -4] + e[eeOffset2 + -4];
            e[eeOffset0 + -5] += e[eeOffset2 + -5];//e[eeOffset0 + -5] = e[eeOffset0 + -5] + e[eeOffset2 + -5];
            e[eeOffset2 + -4] = k00_20 * a[aOffset + 0] - k01_21 * a[aOffset + 1];
            e[eeOffset2 + -5] = k01_21 * a[aOffset + 0] + k00_20 * a[aOffset + 1];
            aOffset +=  8;

            k00_20  = e[eeOffset0 + -6] - e[eeOffset2 + -6];
            k01_21  = e[eeOffset0 + -7] - e[eeOffset2 + -7];
            e[eeOffset0 + -6] += e[eeOffset2 + -6];//e[eeOffset0 + -6] = e[eeOffset0 + -6] + e[eeOffset2 + -6];
            e[eeOffset0 + -7] += e[eeOffset2 + -7];//e[eeOffset0 + -7] = e[eeOffset0 + -7] + e[eeOffset2 + -7];
            e[eeOffset2 + -6] = k00_20 * a[aOffset + 0] - k01_21 * a[aOffset + 1];
            e[eeOffset2 + -7] = k01_21 * a[aOffset + 0] + k00_20 * a[aOffset + 1];
            aOffset += 8;
            eeOffset0 -= 8;
            eeOffset2 -= 8;
        }
    }


    static inline function step3InnerRLoop(lim:Int, e:Vector<Float>, d0:Int, k_off:Int, a:Vector<Float>, k1:Int) {
        var aOffset = 0;
        var eOffset0 = d0; //e
        var eOffset2 = d0 + k_off; //e
        var i = (lim >> 2) + 1;

        while (--i > 0) {
            var k00_20 = e[eOffset0 + -0] - e[eOffset2 + -0];
            var k01_21 = e[eOffset0 + -1] - e[eOffset2 + -1];
            e[eOffset0 + -0] += e[eOffset2 + -0];//e[eOffset0 + -0] = e[eOffset0 + -0] + e[eOffset2 + -0];
            e[eOffset0 + -1] += e[eOffset2 + -1];//e[eOffset0 + -1] = e[eOffset0 + -1] + e[eOffset2 + -1];
            e[eOffset2 + -0] = (k00_20)*a[aOffset + 0] - (k01_21) * a[aOffset + 1];
            e[eOffset2 + -1] = (k01_21)*a[aOffset + 0] + (k00_20) * a[aOffset + 1];

            aOffset +=  k1;

            k00_20 = e[eOffset0 + -2] - e[eOffset2 + -2];
            k01_21 = e[eOffset0 + -3] - e[eOffset2 + -3];
            e[eOffset0 + -2] += e[eOffset2 + -2];//e[eOffset0 + -2] = e[eOffset0 + -2] + e[eOffset2 + -2];
            e[eOffset0 + -3] += e[eOffset2 + -3];//e[eOffset0 + -3] = e[eOffset0 + -3] + e[eOffset2 + -3];
            e[eOffset2 + -2] = (k00_20)*a[aOffset + 0] - (k01_21) * a[aOffset + 1];
            e[eOffset2 + -3] = (k01_21)*a[aOffset + 0] + (k00_20) * a[aOffset + 1];

            aOffset +=  k1;

            k00_20 = e[eOffset0 + -4] - e[eOffset2 + -4];
            k01_21 = e[eOffset0 + -5] - e[eOffset2 + -5];
            e[eOffset0 + -4] += e[eOffset2 + -4];//e[eOffset0 + -4] = e[eOffset0 + -4] + e[eOffset2 + -4];
            e[eOffset0 + -5] += e[eOffset2 + -5];//e[eOffset0 + -5] = e[eOffset0 + -5] + e[eOffset2 + -5];
            e[eOffset2 + -4] = (k00_20)*a[aOffset + 0] - (k01_21) * a[aOffset + 1];
            e[eOffset2 + -5] = (k01_21)*a[aOffset + 0] + (k00_20) * a[aOffset + 1];

            aOffset +=  k1;

            k00_20 = e[eOffset0 + -6] - e[eOffset2 + -6];
            k01_21 = e[eOffset0 + -7] - e[eOffset2 + -7];
            e[eOffset0 + -6] += e[eOffset2 + -6];//e[eOffset0 + -6] = e[eOffset0 + -6] + e[eOffset2 + -6];
            e[eOffset0 + -7] += e[eOffset2 + -7];//e[eOffset0 + -7] = e[eOffset0 + -7] + e[eOffset2 + -7];
            e[eOffset2 + -6] = (k00_20)*a[aOffset + 0] - (k01_21) * a[aOffset + 1];
            e[eOffset2 + -7] = (k01_21)*a[aOffset + 0] + (k00_20) * a[aOffset + 1];

            eOffset0 -= 8;
            eOffset2 -= 8;

            aOffset +=  k1;
        }
    }

    static inline function step3InnerSLoop(n:Int, e:Vector<Float>, i_off:Int, k_off:Int, a:Vector<Float>, aOffset0:Int, aOffset1:Int, k0:Int)
    {
        var A0 = a[aOffset0];
        var A1 = a[aOffset0 + 1];
        var A2 = a[aOffset0 + aOffset1];
        var A3 = a[aOffset0 + aOffset1 + 1];
        var A4 = a[aOffset0 + aOffset1 * 2+0];
        var A5 = a[aOffset0 + aOffset1 * 2+1];
        var A6 = a[aOffset0 + aOffset1 * 3+0];
        var A7 = a[aOffset0 + aOffset1 * 3+1];

        var eeOffset0 = i_off; // e
        var eeOffset2 = i_off + k_off; // e
        var i = n + 1;
        while (--i > 0) {
            var k00      = e[eeOffset0 +  0] - e[eeOffset2 +  0];
            var k11      = e[eeOffset0 + -1] - e[eeOffset2 + -1];
            e[eeOffset0 +  0] =  e[eeOffset0 +  0] + e[eeOffset2 +  0];
            e[eeOffset0 + -1] =  e[eeOffset0 + -1] + e[eeOffset2 + -1];
            e[eeOffset2 +  0] = (k00) * A0 - (k11) * A1;
            e[eeOffset2 + -1] = (k11) * A0 + (k00) * A1;

            k00      = e[eeOffset0 + -2] - e[eeOffset2 + -2];
            k11      = e[eeOffset0 + -3] - e[eeOffset2 + -3];
            e[eeOffset0 + -2] =  e[eeOffset0 + -2] + e[eeOffset2 + -2];
            e[eeOffset0 + -3] =  e[eeOffset0 + -3] + e[eeOffset2 + -3];
            e[eeOffset2 + -2] = (k00) * A2 - (k11) * A3;
            e[eeOffset2 + -3] = (k11) * A2 + (k00) * A3;

            k00      = e[eeOffset0 + -4] - e[eeOffset2 + -4];
            k11      = e[eeOffset0 + -5] - e[eeOffset2 + -5];
            e[eeOffset0 + -4] =  e[eeOffset0 + -4] + e[eeOffset2 + -4];
            e[eeOffset0 + -5] =  e[eeOffset0 + -5] + e[eeOffset2 + -5];
            e[eeOffset2 + -4] = (k00) * A4 - (k11) * A5;
            e[eeOffset2 + -5] = (k11) * A4 + (k00) * A5;

            k00      = e[eeOffset0 + -6] - e[eeOffset2 + -6];
            k11      = e[eeOffset0 + -7] - e[eeOffset2 + -7];
            e[eeOffset0 + -6] =  e[eeOffset0 + -6] + e[eeOffset2 + -6];
            e[eeOffset0 + -7] =  e[eeOffset0 + -7] + e[eeOffset2 + -7];
            e[eeOffset2 + -6] = (k00) * A6 - (k11) * A7;
            e[eeOffset2 + -7] = (k11) * A6 + (k00) * A7;

            eeOffset0 -= k0;
            eeOffset2 -= k0;
        }
    }

    static inline function iter54(e:Vector<Float>, zOffset:Int)
    {
        var t0 = e[zOffset +  0];
        var t1 = e[zOffset + -4];
        var k00  = t0 - t1;
        var y0    = t0 + t1;

        t0 = e[zOffset + -2];
        t1 = e[zOffset + -6];
        var y2    = t0 + t1;
        var k22  = t0 - t1;

        e[zOffset + -0] = y0 + y2;        // z0 + z4 + z2 + z6
        e[zOffset + -2] = y0 - y2;        // z0 + z4 - z2 - z6

        // done with y0,y2

        var k33  = e[zOffset + -3] - e[zOffset + -7];

        e[zOffset + -4] = k00 + k33;     // z0 - z4 + z3 - z7
        e[zOffset + -6] = k00 - k33;     // z0 - z4 - z3 + z7

        // done with k33

        t0 = e[zOffset + -1];
        t1 = e[zOffset + -5];
        var k11  = t0 - t1;
        var y1    = t0 + t1;
        var y3    = e[zOffset + -3] + e[zOffset + -7];

        e[zOffset + -1] = y1 + y3;        // z1 + z5 + z3 + z7
        e[zOffset + -3] = y1 - y3;        // z1 + z5 - z3 - z7
        e[zOffset + -5] = k11 - k22;     // z1 - z5 + z2 - z6
        e[zOffset + -7] = k11 + k22;     // z1 - z5 - z2 + z6
    }

    static inline function step3InnerSLoopLd654(n:Int, e:Vector<Float>, i_off:Int, a:Vector<Float>, baseN:Int)
    {
        var A2 = a[baseN >> 3];
        var zOffset = i_off; // e
        var baseOffset = i_off - 16 * n; //e

        while (zOffset > baseOffset) {
            var t0 = e[zOffset];
            var t1 = e[zOffset + -8];
            e[zOffset + -8]    = t0 - t1;
            e[zOffset + -0] = t0 + t1;

            t0 = e[zOffset + -1];
            t1 = e[zOffset + -9];
            e[zOffset + -9]    = t0 - t1;
            e[zOffset + -1] = t0 + t1;


            t0 = e[zOffset +  -2];
            t1 = e[zOffset + -10];
            var k00    = t0 - t1;
            e[zOffset +  -2] = t0 + t1;

            t0 = e[zOffset +  -3];
            t1 = e[zOffset + -11];
            var k11    = t0 - t1;
            e[zOffset +  -3] = t0 + t1;

            e[zOffset + -10] = (k00+k11) * A2;
            e[zOffset + -11] = (k11-k00) * A2;


            t0 = e[zOffset +  -4];
            t1 = e[zOffset + -12];
            k00     = t1 - t0; // reverse to avoid a unary negation
            e[zOffset +  -4] = t0 + t1;

            t0 = e[zOffset +  -5];
            t1 = e[zOffset + -13];
            k11     = t0 - t1;
            e[zOffset +  -5] = t0 + t1;

            e[zOffset + -12] = k11;
            e[zOffset + -13] = k00;


            t0 = e[zOffset +  -6];
            t1 = e[zOffset + -14];
            k00     = t1 - t0;  // reverse to avoid a unary negation
            e[zOffset +  -6] = t0 + t1;

            t0 = e[zOffset +  -7];
            t1 = e[zOffset + -15];
            k11     = t0 - t1;
            e[zOffset +  -7] = t0 + t1;

            e[zOffset + -14] = (k00+k11) * A2;
            e[zOffset + -15] = (k00-k11) * A2;

            iter54(e, zOffset);
            iter54(e, zOffset - 8);
            zOffset -= 16;
        }
    }
}
