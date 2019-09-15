package kha;

import haxe.macro.Context;
import haxe.macro.Expr;

class Macros {
	public static macro function canvasId(): Expr {
		return {
			expr: EConst(CString(Context.getDefines().get("canvas_id"))),
			pos: Context.currentPos()
		};
	}
}
