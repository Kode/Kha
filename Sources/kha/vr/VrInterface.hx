package kha.vr;

import kha.math.FastMatrix4;

class VrInterface {

	public static var instance: VrInterface;
	
	// Returns the current sensor state
	public function GetSensorState(): SensorState {
		return null;
	}
	
	// Returns the predicted sensor state at the specified time
	public function GetPredictedSensorState(time: Float): SensorState {
		return null;
	}
	
	// Sends a black image to the warp swap thread
	public function WarpSwapBlack(): Void {
		return null;
	}
	
	// Sends the Oculus loading symbol to the warp swap thread
	public function WarpSwapLoadingIcon(): Void {
		return null;
	}
	
	// Sends the set of images to the warp swap thread
	public function WarpSwap(parms: TimeWarpParms): Void {
		return null;
	}

	//
	public function IsPresenting(): Bool {
		return false;
	}
	
	// This returns the time that the TimeWarp thread uses
	// Since it is created from the library's vsync counting code, we should use this
	public function GetTimeInSeconds(): Float {
		return 0.0;
	}

	// Returns projection to be used for the left or right eye’s rendering
	public function GetProjectionMatrix(eye: Int): FastMatrix4 {
		return null;
	}

	// Returns view transformation to be used for the left or right eye’s rendering
	public function GetViewMatrix(eye: Int): FastMatrix4 {
		return null;
	}
	
	private function new() {
		
	}
	
}