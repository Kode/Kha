package kha.audio2.ogg.vorbis.data;

/**
 * ...
 * @author shohei909
 */
class Comment {
    public var data(default, null):Map<String, Array<String>>;

    public var title(get, never):String;
    function get_title() {
        return getString("title");
    }

    public var loopStart(get, never):Null<Int>;
    function get_loopStart() {
        return Std.parseInt(getString("loopstart"));
    }

    public var loopLength(get, never):Null<Int>;
    function get_loopLength() {
        return Std.parseInt(getString("looplength"));
    }

    public var version(get, never):String;
    function get_version() {
        return getString("version");
    }

    public var album(get, never):String;
    function get_album() {
        return getString("album");
    }

    public var organization(get, never):String;
    function get_organization() {
        return getString("organization");
    }

    public var tracknumber(get, never):String;
    function get_tracknumber() {
        return getString("tracknumber");
    }

    public var performer(get, never):String;
    function get_performer() {
        return getString("performer");
    }

    public var copyright(get, never):String;
    function get_copyright() {
        return getString("copyright");
    }

    public var license(get, never):String;
    function get_license() {
        return getString("license");
    }

    public var artist(get, never):String;
    function get_artist() {
        return getString("artist");
    }

    public var description(get, never):String;
    function get_description() {
        return getString("description");
    }

    public var genre(get, never):String;
    function get_genre() {
        return getString("genre");
    }

    public var date(get, never):String;
    function get_date() {
        return getString("date");
    }

    public var location(get, never):String;
    function get_location() {
        return getString("location");
    }

    public var contact(get, never):String;
    function get_contact() {
        return getString("contact");
    }

    public var isrc(get, never):String;
    function get_isrc() {
        return getString("isrc");
    }

    public var artists(get, never):Array<String>;
    function get_artists() {
        return getArray("artist");
    }

    public function new() {
        data = new Map();
    }

    public function add(key:String, value:String) {
        key = key.toLowerCase();
        if (data.exists(key)) {
            data[key].push(value);
        } else {
            data[key] = [value];
        }
    }

    public function getString(key:String) {
        key = key.toLowerCase();
        return if (data.exists(key)) {
            data[key][0];
        } else {
            null;
        }
    }

    public function getArray(key:String) {
        key = key.toLowerCase();
        return if (data.exists(key)) {
            data[key];
        } else {
            null;
        }
    }
}
