package kha;

import js.Browser;

class EnvironmentVariables {
	public static function get(name: String): String {
		try {
			var query = Browser.location.href.substr(Browser.location.href.indexOf("?") + 1);
			var parts = query.split("&");

			for (part in parts) {
				var subparts = part.split("=");
				if (subparts[0] == name) {
					return subparts[1];
				}
			}

			return null;
		}
		catch (error: Dynamic) {
			return null;
		}
	}
}
