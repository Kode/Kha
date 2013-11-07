package kha.flash;


class EnvironmentVariables extends kha.EnvironmentVariables
{
	
	
	
	public function new() {
		super();
	}
	
	override public function getVariable(name: String): String {
		if (name == "username") {
			return "Florian Mehm";			
		} else if (name == "questionid") {
			return "12345";			
		}
		
		return "";
	}
	
}