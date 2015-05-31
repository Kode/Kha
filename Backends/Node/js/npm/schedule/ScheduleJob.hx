package js.npm.schedule;

@:native('scheduleJob')
extern class ScheduleJob 
implements npm.Package.RequireNamespace<"node-schedule","*">
{
	public function new( date : Date , cb : Void -> Void ) : Void;
	public function cancel() : Void;
}