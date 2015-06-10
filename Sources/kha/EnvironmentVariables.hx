package kha;

/**
 * Use this class to access environment variables.
 * Mainly for Flash and JS url parameters.
 */
class EnvironmentVariables {
	/**
	 * The instance.
	 */
	public static var instance: EnvironmentVariables;

	/**
	 * Get a new instance.
	 */
	public function new() {
		
	}

	/**
	 * Return a variable.
	 *
	 * @param name		The variable name.
	 */
	public function getVariable(name: String): String {
		return ""; 
	}
}
