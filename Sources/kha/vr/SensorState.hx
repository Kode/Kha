package kha.vr;

// State of the sensor at a given absolute time.
class SensorState {
	// Predicted pose configuration at requested absolute time.
    // One can determine the time difference between predicted and actual
    // readings by comparing ovrPoseState.TimeInSeconds.
    public var Predicted: PoseState;
	
	// Actual recorded pose configuration based on the sensor sample at a 
    // moment closest to the requested time.
    public var Recorded: PoseState;
	
	// Sensor temperature reading, in degrees Celsius, as sample time.
    public var Temperature: Float;
    // Sensor status described by ovrStatusBits.
    public var Status: Int;
	
	public function new() {
		
	}
	
}