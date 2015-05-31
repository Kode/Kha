package kha.audio2.ogg.vorbis.data;
import haxe.PosInfos;

/**
 * ...
 * @author shohei909
 */
class ReaderError
{
    public var type(default, null):ReaderErrorType;
    public var message(default, null):String;
    public var posInfos(default, null):PosInfos;

    public function new(type:ReaderErrorType, ?message:String = "", ?posInfos:PosInfos) {
        this.type = type;
        this.message = message;
        this.posInfos = posInfos;
    }
}

enum ReaderErrorType
{
   NEED_MORE_DATA;             // not a real error

   INVALID_API_MIXING;           // can't mix API modes
   OUTOFMEM;                     // not enough memory
   FEATURE_NOT_SUPPORTED;        // uses floor 0
   TOO_MANY_CHANNELS;            // STB_VORBIS_MAX_CHANNELS is too small
   FILE_OPEN_FAILURE;            // fopen() failed
   SEEK_WITHOUT_LENGTH;          // can't seek in unknown-length file

   UNEXPECTED_EOF;            // file is truncated?
   SEEK_INVALID;                 // seek past EOF

   // decoding errors (corrupt/invalid input) -- you probably
   // don't care about the exact details of these

   // vorbis errors:
   INVALID_SETUP;
   INVALID_STREAM;

   // ogg errors:
   MISSING_CAPTURE_PATTERN;
   INVALID_STREAM_STRUCTURE_VERSION;
   CONTINUED_PACKET_FLAG_INVALID;
   INCORRECT_STREAM_SERIAL_NUMBER;
   INVALID_FIRST_PAGE;
   BAD_PACKET_TYPE;
   CANT_FIND_LAST_PAGE;
   SEEK_FAILED;

   OTHER;
}
