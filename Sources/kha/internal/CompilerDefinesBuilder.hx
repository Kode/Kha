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
	public static macro function build() : Array<Field> {
		var fields = Context.getBuildFields();

		var defines = Context.getDefines();

		for (k in defines.keys()) {
			var key = $v{k};
			addField(fields, key, $v{Std.string(defines.get(key))});
		}

		return fields;
	}

	/**
	 * Constructs the structure for defining a class field with public
	 * static visibility, and pushes it to the class fields array.
	 *
	 * @param	fields	Array of class fields.
	 * @param	name	Field name.
	 * @param	value	Field value.
	 */
	static function addField(fields : Array<Field>, name : String, value : String) : Void {
		fields.push({
			name: name,
			access: [ APublic, AStatic ],
			kind: FVar(macro : String, macro $v{value}),
			pos: Context.currentPos()
		});
	}
}
#end
