package js.atomshell.browserandwebpage;

/**
 * @author AS3Boyan
 * MIT

 */
extern class Process implements npm.Package.Require<"process","*"> extends js.node.Process
{
	var type:String;
	var resourcesPath:String;
}