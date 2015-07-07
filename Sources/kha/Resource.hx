package kha;

/**
 * Interface representing a generic application resource.
 * It can go from images, to sound or music, videos or blobs.
 */
interface Resource {
	/**
	 * Unload the resource from memory. Normally called by the Loader.
	 */
	function unload(): Void;
}