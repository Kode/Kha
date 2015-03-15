package kha.cpp.vr;

import kha.vr.SensorState;
import kha.vr.TimeWarpParms;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Vr/VrInterface.h>
')
class VrInterface extends kha.vr.VrInterface {
	
	
	
	// Returns the current sensor state
	// Returns the predicted sensor state at the specified time
	@:functionCode('
		return Kore::VrInterface::GetSensorState();	
	')
	public override function GetSensorState(): SensorState {
		return null;
	}
	
	// Returns the predicted sensor state at the specified time
	@:functionCode('
		return Kore::VrInterface::GetPredictedSensorState(time);	
	')
	public override function GetPredictedSensorState(time: Float): SensorState {
		return null;
	}
	
	// Sends a black image to the warp swap thread
	@:functionCode('
		Kore::VrInterface::WarpSwapBlack();
	')
	public override function WarpSwapBlack(): Void {
		
	}
	
	
	// Sends the Oculus loading symbol to the warp swap thread
	@:functionCode('
		Kore::VrInterface::WarpSwapLoadingIcon();	
	')
	public override function WarpSwapLoadingIcon(): Void {
		
	}
	
	// Sends the set of images to the warp swap thread
	@:functionCode('
		Kore::VrInterface::WarpSwap(parms.mPtr);	
	')
	public override function WarpSwap(parms: TimeWarpParms): Void {
	}
	
	@:functionCode('
		return Kore::VrInterface::GetTimeInSeconds();
	')
	public override function GetTimeInSeconds(): Float {
		return 0.0;
	}
	
	
	
	public function new() {
		super();
	}
	
}

