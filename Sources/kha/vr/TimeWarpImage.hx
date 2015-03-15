package kha.vr;

import kha.Image;
import kha.math.Matrix4;

class TimeWarpImage {
	
	// If TexId == 0, this image is disabled.
	// Most applications will have the overlay image
	// disabled.
	//
	// Because OpenGL ES doesn't support clampToBorder,
	// it is the application's responsibility to make sure
	// that all mip levels of the texture have a black border
	// that will show up when time warp pushes the texture partially
	// off screen.
	//
	// Overlap textures will only show through where alpha on the
	// primary texture is not 1.0, so they do not require a border.
	//unsigned		TexId;
	public var Image: Image;

	// Experimental separate R/G/B cube maps
	//unsigned		PlanarTexId[3];

	// Points on the screen are mapped by a distortion correction
	// function into ( TanX, TanY, 1, 1 ) vectors that are transformed
	// by this matrix to get ( S, T, Q, _ ) vectors that are looked
	// up with texture2dproj() to get texels.
	
	public var TexCoordsFromTanAngles: Matrix4;

	// The sensor state for which ModelViewMatrix is correct.
	// It is ok to update the orientation for each eye, which
	// can help minimize black edge pull-in, but the position
	// must remain the same for both eyes, or the position would
	// seem to judder "backwards in time" if a frame is dropped.
	public var Pose: PoseState;
	
	public function new() {
		
	}
	
}