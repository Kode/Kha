package kha.js.vr;

import js.Syntax;
import js.lib.Float32Array;
import kha.vr.Pose;
import kha.vr.PoseState;
import kha.vr.SensorState;
import kha.vr.TimeWarpParms;
import kha.math.FastMatrix4;
import kha.math.Vector3;
import kha.math.Quaternion;
import kha.SystemImpl;

class VrInterface extends kha.vr.VrInterface {
	var vrEnabled: Bool = false;

	var vrDisplay: Dynamic;
	var frameData: Dynamic;

	var leftProjectionMatrix: FastMatrix4 = FastMatrix4.identity();
	var rightProjectionMatrix: FastMatrix4 = FastMatrix4.identity();
	var leftViewMatrix: FastMatrix4 = FastMatrix4.identity();
	var rightViewMatrix: FastMatrix4 = FastMatrix4.identity();

	var width: Int = 0;
	var height: Int = 0;
	var vrWidth: Int = 0;
	var vrHeight: Int = 0;

	public function new() {
		super();
		#if kha_webvr
		var displayEnabled: Bool = Syntax.code("navigator.getVRDisplays");
		#else
		var displayEnabled = false;
		#end
		if (displayEnabled) {
			vrEnabled = true;
			getVRDisplays();
			trace("Display enabled.");
		}
	}

	function getVRDisplays() {
		var vrDisplayInstance = Syntax.code("navigator.getVRDisplays()");
		vrDisplayInstance.then(function(displays) {
			if (displays.length > 0) {
				frameData = Syntax.code("new VRFrameData()");
				vrDisplay = Syntax.code("displays[0]");
				vrDisplay.depthNear = 0.1;
				vrDisplay.depthFar = 1024.0;

				var leftEye = vrDisplay.getEyeParameters("left");
				var rightEye = vrDisplay.getEyeParameters("right");
				width = SystemImpl.khanvas.width;
				height = SystemImpl.khanvas.height;
				vrWidth = Std.int(Math.max(leftEye.renderWidth, rightEye.renderWidth) * 2);
				vrHeight = Std.int(Math.max(leftEye.renderHeight, rightEye.renderHeight));
			}
			else {
				trace("There are no VR displays connected.");
			}
		});
	}

	public override function onVRRequestPresent() {
		try {
			vrDisplay.requestPresent([{source: SystemImpl.khanvas}]).then(function() {
				onResize();
				vrDisplay.requestAnimationFrame(onAnimationFrame);
			});
		}
		catch (err:Dynamic) {
			trace("Failed to requestPresent.");
			trace(err);
		}
	}

	public override function onVRExitPresent() {
		try {
			vrDisplay.exitPresent([{source: SystemImpl.khanvas}]).then(function() {
				onResize();
			});
		}
		catch (err:Dynamic) {
			trace("Failed to exitPresent.");
			trace(err);
		}
	}

	public override function onResetPose() {
		try {
			vrDisplay.resetPose();
		}
		catch (err:Dynamic) {
			trace("Failed to resetPose");
			trace(err);
		}
	}

	function onAnimationFrame(timestamp: Float): Void {
		if (vrDisplay != null && vrDisplay.isPresenting) {
			vrDisplay.requestAnimationFrame(onAnimationFrame);

			vrDisplay.getFrameData(frameData);

			leftProjectionMatrix = createMatrixFromArray(untyped frameData.leftProjectionMatrix);
			leftViewMatrix = createMatrixFromArray(untyped frameData.leftViewMatrix);

			rightProjectionMatrix = createMatrixFromArray(untyped frameData.rightProjectionMatrix);
			rightViewMatrix = createMatrixFromArray(untyped frameData.rightViewMatrix);

			// Submit the newly rendered layer to be presented by the VRDisplay
			vrDisplay.submitFrame();
		}
	}

	function onResize() {
		if (vrDisplay != null && vrDisplay.isPresenting) {
			SystemImpl.khanvas.width = vrWidth;
			SystemImpl.khanvas.height = vrHeight;
		}
		else {
			SystemImpl.khanvas.width = width;
			SystemImpl.khanvas.height = height;
		}
	}

	public override function GetSensorState(): SensorState {
		return GetPredictedSensorState(0.0);
	}

	public override function GetPredictedSensorState(time: Float): SensorState {
		var result: SensorState = new SensorState();

		result.Predicted = new PoseState();
		result.Recorded = result.Predicted;

		result.Predicted.AngularAcceleration = new Vector3();
		result.Predicted.AngularVelocity = new Vector3();
		result.Predicted.LinearAcceleration = new Vector3();
		result.Predicted.LinearVelocity = new Vector3();
		result.Predicted.TimeInSeconds = time;
		result.Predicted.Pose = new Pose();
		result.Predicted.Pose.Orientation = new Quaternion();
		result.Predicted.Pose.Position = new Vector3();

		var mPose = frameData.pose; // predicted pose of the vrDisplay
		if (mPose != null) {
			result.Predicted.AngularVelocity = createVectorFromArray(untyped mPose.angularVelocity);
			result.Predicted.AngularAcceleration = createVectorFromArray(untyped mPose.angularAcceleration);
			result.Predicted.LinearVelocity = createVectorFromArray(untyped mPose.linearVelocity);
			result.Predicted.LinearAcceleration = createVectorFromArray(untyped mPose.linearAcceleration);
			result.Predicted.Pose.Orientation = createQuaternion(untyped mPose.orientation);
			result.Predicted.Pose.Position = createVectorFromArray(untyped mPose.position);
		}

		return result;
	}

	// Sends a black image to the warp swap thread
	public override function WarpSwapBlack(): Void {
		// TODO: Implement
	}

	// Sends the Oculus loading symbol to the warp swap thread
	public override function WarpSwapLoadingIcon(): Void {
		// TODO: Implement
	}

	// Sends the set of images to the warp swap thread
	public override function WarpSwap(parms: TimeWarpParms): Void {
		// TODO: Implement
	}

	public override function IsPresenting(): Bool {
		if (vrDisplay != null)
			return vrDisplay.isPresenting;
		return false;
	}

	public override function IsVrEnabled(): Bool {
		return vrEnabled;
	}

	public override function GetTimeInSeconds(): Float {
		return Scheduler.time();
	}

	public override function GetProjectionMatrix(eye: Int): FastMatrix4 {
		if (eye == 0) {
			return leftProjectionMatrix;
		}
		else {
			return rightProjectionMatrix;
		}
	}

	public override function GetViewMatrix(eye: Int): FastMatrix4 {
		if (eye == 0) {
			return leftViewMatrix;
		}
		else {
			return rightViewMatrix;
		}
	}

	function createMatrixFromArray(array: Float32Array): FastMatrix4 {
		var matrix: FastMatrix4 = FastMatrix4.identity();
		matrix._00 = array[0];
		matrix._01 = array[1];
		matrix._02 = array[2];
		matrix._03 = array[3];
		matrix._10 = array[4];
		matrix._11 = array[5];
		matrix._12 = array[6];
		matrix._13 = array[7];
		matrix._20 = array[8];
		matrix._21 = array[9];
		matrix._22 = array[10];
		matrix._23 = array[11];
		matrix._30 = array[12];
		matrix._31 = array[13];
		matrix._32 = array[14];
		matrix._33 = array[15];
		return matrix;
	}

	function createVectorFromArray(array: Float32Array): Vector3 {
		var vector: Vector3 = new Vector3(0, 0, 0);
		if (array != null) {
			vector.x = array[0];
			vector.y = array[1];
			vector.z = array[2];
		}
		return vector;
	}

	function createQuaternion(array: Float32Array): Quaternion {
		var quaternion: Quaternion = new Quaternion(0, 0, 0, 0);
		if (array != null) {
			quaternion.x = array[0];
			quaternion.y = array[1];
			quaternion.z = array[2];
			quaternion.w = array[3];
		}
		return quaternion;
	}
}
