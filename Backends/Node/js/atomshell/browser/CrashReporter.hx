package js.atomshell.browser;

/**
* @author AS3Boyan
 */
typedef CrashReporterOptions = 
{
	?productName:String,
	?companyName:String,
	?submitUrl:String,
	?autoSubmit:Bool,
	?ignoreSystemCrashHandler:Bool,
	?extra:Dynamic
}

class CrashReporter implements atomshell.Package.Require<"crash-reporter","*">
{
	static function start(?options:CrashReporterOptions):Void;
}