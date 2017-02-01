package kha.vr;

import js.Browser;

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
import kha.math.Matrix4;
import kha.math.Quaternion;
import kha.math.Vector4;
import kha.math.Vector3;
import kha.math.Vector2;
import kha.Image;

class VrInterface {

	public var vrEnabled: Bool = false;

	static var vrDisplay;
	static var frameData;
	static var layerSource;

	private var leftProjectionMatrix: FastMatrix4 = FastMatrix4.identity();
	private var rightProjectionMatrix: FastMatrix4 = FastMatrix4.identity();
	private var leftViewMatrix: FastMatrix4 = FastMatrix4.identity();
	private var rightViewMatrix: FastMatrix4 = FastMatrix4.identity();

	public function new() {
		initWebGLProgram();

		var displayEnabled:Bool = untyped __js__('navigator.getVRDisplays');
		if (displayEnabled) {
			getVRDisplays();
			trace("Display enabled.");
        } else {
			trace("WebVR is not supported on this browser.");
			trace("To support progressive enhancement your fallback code should render a normal Canvas based WebGL experience for the user.");
        }
	}

	private function initWebGLProgram() {
		// TODO: do we need all this
		layerSource = Browser.document.getElementById("khanvas");
	}

	private function getVRDisplays() {
		var vrDisplayInstance = untyped __js__('navigator.getVRDisplays()');
		vrDisplayInstance.then(function (displays) {
			if (displays.length > 0) {
				frameData = untyped __js__('new VRFrameData()');
				vrDisplay = untyped __js__('displays[0]');

				var leftEye = vrDisplay.getEyeParameters("left");
				var rightEye = vrDisplay.getEyeParameters("right");

				//layerSource.width = Math.max(leftEye.renderWidth, rightEye.renderWidth) * 2;
				//layerSource.height = Math.max(leftEye.renderHeight, rightEye.renderHeight);

				vrEnabled = true;
				try {
					vrDisplay.requestPresent([{ source: layerSource }]).then(function () {
						trace("request present");
						vrDisplay.requestAnimationFrame(onAnimationFrame);
					});
				} catch( msg : String ) {
					trace("Failed to requestPresent.");
				}

			} else {
				trace("There are no VR displays connected.");
			}
		});
	}

	private function onAnimationFrame(timestamp) {
		trace("call on animation frame");
		vrDisplay.requestAnimationFrame(onAnimationFrame);

        vrDisplay.getFrameData(frameData);

		// Render the left eye
		//gl.viewport(0, 0, layerSource.width * 0.5, layerSource.height);
		//render(frameData.leftProjectionMatrix, frameData.leftViewMatrix);
		leftProjectionMatrix = createMatrixFromArray(frameData.leftProjectionMatrix);
		leftViewMatrix = createMatrixFromArray(frameData.leftViewMatrix);

		// Render the right eye
		//gl.viewport(layerSource.width * 0.5, 0, layerSource.width * 0.5, layerSource.height);
		//render(frameData.rightProjectionMatrix, frameData.rightViewMatrix);
		rightProjectionMatrix = createMatrixFromArray(frameData.rightProjectionMatrix);
		rightViewMatrix = createMatrixFromArray(frameData.rightViewMatrix);

		// Submit the newly rendered layer to be presented by the VRDisplay
		vrDisplay.submitFrame();

	}

	public function getProjectionMatrix(eye: Int) : FastMatrix4 {
		if (eye == 0) {
			return leftProjectionMatrix;
		} else {
			return rightProjectionMatrix;
		}
	}

	public function getViewMatrix(eye: Int) : FastMatrix4 {
		if (eye == 0) {
			return leftViewMatrix;
		} else {
			return rightViewMatrix;
		}
	}

	private function createMatrixFromArray(array/*: js.html.Float32Array*/) : FastMatrix4 {
		var matrix : FastMatrix4 = FastMatrix4.identity();

		untyped __js__ ('
		matrix._00 = array[0];  matrix._01 = array[1];  matrix._02 = array[2];  matrix._03 = array[3];
		matrix._10 = array[4];  matrix._11 = array[5];  matrix._12 = array[6];  matrix._13 = array[7];
		matrix._20 = array[8];  matrix._21 = array[9];  matrix._22 = array[10]; matrix._23 = array[11];
		matrix._30 = array[12]; matrix._31 = array[13]; matrix._32 = array[14]; matrix._33 = array[15]'
		);

		return matrix;
	}
}