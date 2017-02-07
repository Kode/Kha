package kha.vr;

import js.Browser;
import js.html.Float32Array;
import js.html.Event;
import js.html.KeyboardEvent;

import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;
import kha.graphics4.PipelineState;
import kha.graphics4.Graphics;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.math.FastMatrix4;
import kha.math.Vector3;
import kha.math.Quaternion;
import kha.Image;
import kha.SystemImpl;

class VrInterface {

	public var vrEnabled: Bool = false;

	private static var vrDisplay: Dynamic;
	private static var frameData: Dynamic;

	private var leftProjectionMatrix: FastMatrix4 = FastMatrix4.identity();
	private var rightProjectionMatrix: FastMatrix4 = FastMatrix4.identity();
	private var leftViewMatrix: FastMatrix4 = FastMatrix4.identity();
	private var rightViewMatrix: FastMatrix4 = FastMatrix4.identity();

	public function new() {
		var displayEnabled: Bool = untyped __js__('navigator.getVRDisplays');
		if (displayEnabled) {
			getVRDisplays();
			trace("Display enabled.");
        } else {
			trace("WebVR is not supported on this browser.");
			trace("To support progressive enhancement your fallback code should render a normal Canvas based WebGL experience for the user.");
        }
	}

	private function getVRDisplays() {
		var vrDisplayInstance = untyped __js__('navigator.getVRDisplays()');
		vrDisplayInstance.then(function (displays) {
			if (displays.length > 0) {
				frameData = untyped __js__('new VRFrameData()');
				vrDisplay = untyped __js__('displays[0]');

				var leftEye = vrDisplay.getEyeParameters("left");
				var rightEye = vrDisplay.getEyeParameters("right");
				//SystemImpl.khanvas.width = Std.int(Math.max(leftEye.renderWidth, rightEye.renderWidth) * 2);
				//SystemImpl.khanvas.height = Std.int(Math.max(leftEye.renderHeight, rightEye.renderHeight));
				//trace(SystemImpl.khanvas.width + " " + SystemImpl.khanvas.height);

				//onResize();

				// Reset pose button
				var resetButton = Browser.document.createButtonElement();
        		resetButton.textContent = "Reset Pose!";
        		resetButton.onclick = function(event) {
            		vrDisplay.resetPose();
        		}
        		Browser.document.body.appendChild(resetButton);

				// Enter VR button
				if (vrDisplay.capabilities.canPresent) {
					var vrButton = Browser.document.createButtonElement();
					vrButton.textContent = "Enter VR";
					vrButton.onclick = function(event) {
						onVRRequestPresent();
					}
					Browser.document.body.appendChild(vrButton);
				}

				Browser.window.addEventListener('vrdisplaypresentchange', onVRPresentChange, false);
				Browser.window.requestAnimationFrame(onAnimationFrame);

				vrEnabled = true;
			} else {
				trace("There are no VR displays connected.");
			}
		});
	}

	private function onVRPresentChange () {
		if (vrDisplay.isPresenting) {
			if (vrDisplay.capabilities.hasExternalDisplay) {
				//TODO: "Exit VR" button
			}
		} else {
			if (vrDisplay.capabilities.hasExternalDisplay) {
            	//TODO: "Enter VR" button
			}
		}
        //onResize();
      }

	private function onVRRequestPresent () {
		try {
			//onResize();
			vrDisplay.requestPresent([{ source: SystemImpl.khanvas }]).then(function () {
				//vrDisplay.requestAnimationFrame(onAnimationFrame);
			});
		} catch(err: Dynamic) {
			trace("Failed to requestPresent.");
			trace(err);
		}
	}

	private function onVRExitPresent () {
		try {
			vrDisplay.exitPresent([{ source: SystemImpl.khanvas }]).then(function () {
				// TODO Exit VR
			});
		} catch(err: Dynamic) {
			trace("Failed to exitPresent.");
			trace(err);
		}
	}

	private function onAnimationFrame(timestamp: Float): Void {
		if(vrDisplay != null) {
			vrDisplay.requestAnimationFrame(onAnimationFrame);

			vrDisplay.getFrameData(frameData);

			// Render the left eye
			//gl.viewport(0, 0, layerSource.width * 0.5, layerSource.height);
			//render(frameData.leftProjectionMatrix, frameData.leftViewMatrix);
			leftProjectionMatrix = createMatrixFromArray(untyped frameData.leftProjectionMatrix);
			leftViewMatrix = createMatrixFromArray(untyped frameData.leftViewMatrix);

			// Render the right eye
			//gl.viewport(layerSource.width * 0.5, 0, layerSource.width * 0.5, layerSource.height);
			//render(frameData.rightProjectionMatrix, frameData.rightViewMatrix);
			rightProjectionMatrix = createMatrixFromArray(untyped frameData.rightProjectionMatrix);
			rightViewMatrix = createMatrixFromArray(untyped frameData.rightViewMatrix);

			// Submit the newly rendered layer to be presented by the VRDisplay
			vrDisplay.submitFrame();
		}
	}

	private function onResize () {
		if(vrDisplay != null && vrDisplay.isPresenting) {
			var leftEye = vrDisplay.getEyeParameters("left");
			var rightEye = vrDisplay.getEyeParameters("right");
			SystemImpl.khanvas.width = Std.int(Math.max(leftEye.renderWidth, rightEye.renderWidth) * 2);
			SystemImpl.khanvas.height = Std.int(Math.max(leftEye.renderHeight, rightEye.renderHeight));
		} else {
			SystemImpl.khanvas.width = SystemImpl.khanvas.offsetWidth * Std.int(Browser.window.devicePixelRatio);
          	SystemImpl.khanvas.height = SystemImpl.khanvas.offsetHeight * Std.int(Browser.window.devicePixelRatio);
		}

		trace("onResize [widht, height]");
		trace(SystemImpl.khanvas.width + " " + SystemImpl.khanvas.height);
	}

	public function getProjectionMatrix(eye: Int): FastMatrix4 {
		if (eye == 0) {
			return leftProjectionMatrix;
		} else {
			return rightProjectionMatrix;
		}
	}

	public function getViewMatrix(eye: Int): FastMatrix4 {
		if (eye == 0) {
			return leftViewMatrix;
		} else {
			return rightViewMatrix;
		}
	}

	public function GetSensorState(): SensorState {
		var result: SensorState = new SensorState();

		var mPose = vrDisplay.getPose();	// predicted pose of the vrDisplay

		result.Predicted = new PoseState();
		result.Predicted.AngularVelocity = createVectorFromArray(untyped mPose.angularVelocity);
		result.Predicted.AngularAcceleration = createVectorFromArray(untyped mPose.angularAcceleration);
		result.Predicted.LinearVelocity = createVectorFromArray(untyped mPose.linearVelocity);
		result.Predicted.LinearAcceleration = createVectorFromArray(untyped mPose.linearAcceleration);
		result.Predicted.Pose = new Pose();
		result.Predicted.Pose.Orientation = createQuaternion(untyped mPose.orientation);
		result.Predicted.Pose.Position = createVectorFromArray(untyped mPose.position);
		
		return result;
	}

	private function createMatrixFromArray(array: Float32Array): FastMatrix4 {
		var matrix: FastMatrix4 = FastMatrix4.identity();
		matrix._00 = array[0];  matrix._01 = array[1];  matrix._02 = array[2];  matrix._03 = array[3];
		matrix._10 = array[4];  matrix._11 = array[5];  matrix._12 = array[6];  matrix._13 = array[7];
		matrix._20 = array[8];  matrix._21 = array[9];  matrix._22 = array[10]; matrix._23 = array[11];
		matrix._30 = array[12]; matrix._31 = array[13]; matrix._32 = array[14]; matrix._33 = array[15];
		return matrix;
	}

	private function createVectorFromArray(array: Float32Array): Vector3 {
		var vector: Vector3 = new Vector3(0, 0, 0);
		if (array != null) {
			vector.x = array[0];	vector.y = array[1];	vector.z = array[2];
		}
		return vector;
	}

	private function createQuaternion(array: Float32Array): Quaternion {
		var quaternion: Quaternion = new Quaternion(0, 0, 0, 0);
		if (array != null) {
			quaternion.x = array[0];	quaternion.y = array[1];	quaternion.z = array[2];	quaternion.w = array[3];
		}
		return quaternion;
	}

}