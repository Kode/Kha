package kha.audio2.ogg.tools;

/**
 * ...
 * @author shohei909
 */
class MathTools
{
    public static inline function ilog(n:Int)
    {
        var log2_4 = [0, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4];
        
        // 2 compares if n < 16, 3 compares otherwise (4 if signed or n > 1<<29)
        return if (n < (1 << 14)) {
            if (n < (1 <<  4)) {
                0 + log2_4[n];
            } else if (n < (1 << 9)) {
                5 + log2_4[n >>  5];
            } else {
                10 + log2_4[n >> 10];
            }
        } else if (n < (1 << 24)) {
            if (n < (1 << 19)) {
                15 + log2_4[n >> 15];
            } else {
                20 + log2_4[n >> 20];
            }
        } else if (n < (1 << 29)) {
            25 + log2_4[n >> 25];
        } else if (n < (1 << 31)) {
            30 + log2_4[n >> 30];
        } else {
            0; // signed n returns 0
        }
    }
}