package js.npm;

import js.npm.express.ViewEngine;

extern class Consolidate 
implements npm.Package.Require<"consolidate","*">
{
	public static var dust : ViewEngine;
	public static var jade : ViewEngine;
	// TODO : others
}