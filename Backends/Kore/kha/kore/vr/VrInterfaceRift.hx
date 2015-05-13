package kha.kore.vr;

import kha.math.Quaternion;
import kha.math.Vector3;
import kha.vr.Pose;
import kha.vr.PoseState;
import kha.vr.SensorState;
import kha.vr.TimeWarpParms;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Vr/VrInterface.h>
')

/**
 * ...
 * @author Florian Mehm
 */
class VrInterfaceRift extends VrInterface
{

	// Returns the current sensor state
	#if VR_RIFT	
	@:functionCode('
		return Kore::VrInterface::GetSensorState();
	')
	#end
	public override function GetSensorState(): SensorState {
		return null;
	}
	
	// Returns the predicted sensor state at the specified time
	public override function GetPredictedSensorState(time: Float): SensorState {
		return GetSensorState();
	}
	
	// Sends a black image to the warp swap thread
	public override function WarpSwapBlack(): Void {
		return null;
	}
	
	// Sends the Oculus loading symbol to the warp swap thread
	public override function WarpSwapLoadingIcon(): Void {
		return null;
	}
	
	// Sends the set of images to the warp swap thread
	#if VR_RIFT	
	@:functionCode('
		Kore::VrInterface::WarpSwap(parms.mPtr);
	')
	#end
	public override function WarpSwap(parms: TimeWarpParms): Void {
		return null;
	}
	
	// This returns the time that the TimeWarp thread uses
	// Since it is created from the library's vsync counting code, we should use this
	public override function GetTimeInSeconds(): Float {
		return Sys.getTime();
	}
	
	
	public function new() 
	{
		super();
	}
	
}