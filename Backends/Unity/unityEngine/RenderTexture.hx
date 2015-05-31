package unityEngine;

@:native('UnityEngine.RenderTexture')
extern class RenderTexture extends Texture {
	public function new(width: Int, height: Int, depth: Int);
	public static var active: RenderTexture;
}
