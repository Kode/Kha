package kha.internal;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * Builds public static variables with references to available
 * compiler define values (as `String` type).
 */
class CompilerDefinesBuilder {
	/**
	 * Iterates through a map of compiler defines, and adds class fields
	 * for every one of them.
	 *
	 * @return	Array of class fields.
	 */
	public static macro function build(): Array<Field> {
		final fields = Context.getBuildFields();
		final defines = Context.getDefines();
		final added:Map<String, Bool> = [];

		for (k in defines.keys()) {
			final key = prepareFieldName($v{k});
			if (added[key]) continue;
			added[key] = true;
			addField(fields, key, $v{Std.string(defines.get(key))});
		}

		return fields;
	}

	/**
	 * Fix wrong field names like keywords.
	 *
	 * @param	name	Field name.
	 * @return	New field name.
	 */
	static function prepareFieldName(name: String): String {
		if (isKeyword(name)) return '_$name';
		name = ~/[^A-z0-9_]/.replace(name, "_");
		if (~/^[0-9]/.match(name)) return '_$name';
		return name;
	}

	static final keywords = [
		"function", "class", "static", "var", "if", "else", "while", "do", "for",
		"break", "return", "continue", "extends", "implements", "import",
		"switch", "case", "default", "public", "private", "try", "untyped",
		"catch", "new", "this", "throw", "extern", "enum", "in", "interface",
		"cast", "override", "dynamic", "typedef", "package",
		"inline", "using", "null", "true", "false", "abstract", "macro", "final",
		"operator", "overload"
	];

	/** Checks for keywords (see `is_valid_identifier` from Haxe) */
	static function isKeyword(name: String): Bool {
		return keywords.indexOf(name) != -1;
	}

	/**
	 * Constructs the structure for defining a class field with public
	 * static visibility, and pushes it to the class fields array.
	 *
	 * @param	fields	Array of class fields.
	 * @param	name	Field name.
	 * @param	value	Field value.
	 */
	static function addField(fields: Array<Field>, name: String, value: String): Void {
		fields.push({
			name: name,
			access: [ APublic, AStatic ],
			kind: FVar(macro : String, macro $v{value}),
			pos: Context.currentPos()
		});
	}
}
#end
