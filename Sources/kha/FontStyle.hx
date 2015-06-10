package kha;

/**
 * The font style (bold, italic, ect).
 */
class FontStyle {
	/**
	 * The default style.
	 */
	public  static var Default(default, never) : FontStyle = new FontStyle(false, false, false);
	/**
	 * If the font is bold.
	 */
	private var bold : Bool;
	/**
	 * If the font is italic.
	 */
	private var italic : Bool;
	/**
	 * If the font is underlined.
	 */
	private var underlined : Bool;

	/**
	 * Initialize a new font style.
	 * 
	 * @param bold				If the font is bold, default = false.
	 * @param italic			If the font is italic, default = false.
 	 * @param underlined		If the font is underlined, default = false.
	 */
	public function new(bold : Bool, italic : Bool, underlined : Bool) {
		this.bold = bold;
		this.italic = italic;
		this.underlined = underlined;
	}

	/**
	 * Returns true if the font is bold.
	 */
	public function getBold() : Bool {
		return bold;
	}

	/**
	 * Returns true if the font is italic.
	 */
	public function getItalic() : Bool {
		return italic;
	}

	/**
	 * Returns true if the font is underlined.
	 */	
	public function getUnderlined() : Bool {
		return underlined;
	}
}