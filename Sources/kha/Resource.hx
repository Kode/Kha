package kha;

/**
 * Interface representing a generic application resource.
 * It can go from images, to sound or music, videos or blobs.
 */
interface Resource {
	/**
	 * Unload the resource from memory.
	 */
	function unload(): Void;
}