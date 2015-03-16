package kha.vr;

import kha.math.Vector3;

// Full pose (rigid body) configuration with first and second derivatives.
class PoseState {

    public var Pose: Pose;
    
	public var AngularVelocity: Vector3;
    public var LinearVelocity: Vector3;
    public var AngularAcceleration: Vector3;
    public var LinearAcceleration: Vector3;
    public var TimeInSeconds: Float;			// Absolute time of this state sample.
	
	public function new() {
		
	}
}