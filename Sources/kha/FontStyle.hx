package kha;

class FontStyle {
	public  static var Default(default, never) : FontStyle = new FontStyle(false, false, false);
	
	private var bold : Bool;
	private var italic : Bool;
	private var underlined : Bool;
	
	public function new(bold : Bool, italic : Bool, underlined : Bool) {
		this.bold = bold;
		this.italic = italic;
		this.underlined = underlined;
	}
	
	public function getBold() : Bool {
		return bold;
	}
	
	public function getItalic() : Bool {
		return italic;
	}
	
	public function getUnderlined() : Bool {
		return underlined;
	}
}