/*
Copyright (c) 2011, Adobe Systems Incorporated
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright notice, 
this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the 
documentation and/or other materials provided with the distribution.

* Neither the name of Adobe Systems Incorporated nor the names of its 
contributors may be used to endorse or promote products derived from 
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package kha.flash.utils;

import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.Vector;

class PerspectiveMatrix3D extends Matrix3D {
	public function new(v : Vector<Float> = null) {
		super(v);
		_x = new Vector3D();
		_y = new Vector3D();
		_z = new Vector3D();
		_w = new Vector3D();
	}

	public function lookAtLH(eye : Vector3D, at : Vector3D, up : Vector3D) : Void {
		_z.copyFrom(at);
		_z.subtract(eye);
		_z.normalize();
		_z.w = 0.0;

		_x.copyFrom(up);
		_crossProductTo(_x,_z);
		_x.normalize();
		_x.w = 0.0;

		_y.copyFrom(_z);
		_crossProductTo(_y,_x);
		_y.w = 0.0;

		_w.x = _x.dotProduct(eye);
		_w.y = _y.dotProduct(eye);
		_w.z = _z.dotProduct(eye);
		_w.w = 1.0;

		copyRowFrom(0,_x);
		copyRowFrom(1,_y);
		copyRowFrom(2,_z);
		copyRowFrom(3,_w);
	}

	public function lookAtRH(eye : Vector3D, at : Vector3D, up : Vector3D) : Void {
		_z.copyFrom(eye);
		_z.subtract(at);
		_z.normalize();
		_z.w = 0.0;

		_x.copyFrom(up);
		_crossProductTo(_x,_z);
		_x.normalize();
		_x.w = 0.0;

		_y.copyFrom(_z);
		_crossProductTo(_y,_x);
		_y.w = 0.0;

		_w.x = _x.dotProduct(eye);
		_w.y = _y.dotProduct(eye);
		_w.z = _z.dotProduct(eye);
		_w.w = 1.0;

		copyRowFrom(0,_x);
		copyRowFrom(1,_y);
		copyRowFrom(2,_z);
		copyRowFrom(3,_w);
	}

	public function perspectiveLH(width : Float, height : Float, zNear : Float, zFar : Float) : Void {
		var vec = new Vector<Float>(16);
		vec[ 0] = 2.0 * zNear / width; vec[ 1] = 0.0;                  vec[ 2] = 0.0;                           vec[ 3] = 0.0;
		vec[ 4] = 0.0;                 vec[ 5] = 2.0 * zNear / height; vec[ 6] = 0.0;                           vec[ 7] = 0.0;
		vec[ 8] = 0.0;                 vec[ 9] = 0.0;                  vec[10] = zFar / (zFar - zNear);         vec[11] = 1.0;
		vec[12] = 0.0;                 vec[12] = 0.0;                  vec[14] = zNear * zFar / (zNear - zFar); vec[13] = 0.0;
		copyRawDataFrom(vec);
	}

	public function perspectiveRH(width : Float, height : Float, zNear : Float, zFar : Float) : Void {
		var vec = new Vector<Float>(16);
		vec[ 0] = 2.0 * zNear / width; vec[ 1] = 0.0;                  vec[ 2] = 0.0;                           vec[ 3] = 0.0;
		vec[ 4] = 0.0;                 vec[ 5] = 2.0 * zNear / height; vec[ 6] = 0.0;                           vec[ 7] = 0.0;
		vec[ 8] = 0.0;                 vec[ 9] = 0.0;                  vec[10] = zFar / (zNear - zFar);         vec[11] = -1.0;
		vec[12] = 0.0;                 vec[13] = 0.0;                  vec[14] = zNear * zFar / (zNear - zFar); vec[15] = 0.0;
		copyRawDataFrom(vec);
	}

	public function perspectiveFieldOfViewLH(fieldOfViewY : Float, aspectRatio : Float, zNear : Float, zFar : Float) : Void {
		var yScale : Float = 1.0 / Math.tan(fieldOfViewY / 2.0);
		var xScale : Float = yScale / aspectRatio;
		var vec = new Vector<Float>(16);
		vec[ 0] = xScale; vec[ 1] = 0.0;    vec[ 2] = 0.0;                             vec[ 3] = 0.0;
		vec[ 4] = 0.0;    vec[ 5] = yScale; vec[ 6] = 0.0;                             vec[ 7] = 0.0;
		vec[ 8] = 0.0;    vec[ 9] = 0.0;    vec[10] = zFar / (zFar - zNear);           vec[11] = 1.0;
		vec[12] = 0.0;    vec[13] = 0.0;    vec[14] = (zNear * zFar) / (zNear - zFar); vec[15] = 0.0;
		copyRawDataFrom(vec);
	}

	public function perspectiveFieldOfViewRH(fieldOfViewY : Float, aspectRatio : Float, zNear : Float, zFar : Float) : Void {
		var yScale : Float = 1.0 / Math.tan(fieldOfViewY / 2.0);
		var xScale : Float = yScale / aspectRatio;
		var vec = new Vector<Float>(16);
		vec[ 0] = xScale; vec[ 1] = 0.0;    vec[ 2] = 0.0;                             vec[ 3] = 0.0;
		vec[ 4] = 0.0;    vec[ 5] = yScale; vec[ 6] = 0.0;                             vec[ 7] = 0.0;
		vec[ 8] = 0.0;    vec[ 9] = 0.0;    vec[10] = zFar / (zNear - zFar);           vec[11] = -1.0;
		vec[12] = 0.0;    vec[13] = 0.0;    vec[14] = (zNear * zFar) / (zNear - zFar); vec[15] = 0.0;
		copyRawDataFrom(vec);
	}

	public function perspectiveOffCenterLH(left : Float, right : Float, bottom : Float, top : Float, zNear : Float, zFar : Float) : Void {
		var vec : Vector<Float> = new Vector<Float>(16);
		vec[ 0] = 2.0 * zNear / (right - left);       vec[ 1] = 0.0;                              vec[ 2] = 0.0;                             vec[ 3] = 0.0;
		vec[ 4] = 0.0;                                vec[ 5] = -2.0 * zNear / (bottom - top);    vec[ 6] = 0.0;                             vec[ 7] = 0.0;
		vec[ 8] = -1.0 - 2.0 * left / (right - left); vec[ 9] = 1.0 + 2.0 * top / (bottom - top); vec[10] = -zFar / (zNear - zFar);          vec[11] = 1.0;
		vec[12] = 0.0;                                vec[13] = 0.0;                              vec[14] = (zNear * zFar) / (zNear - zFar); vec[15] = 0.0;
		copyRawDataFrom(vec);
	}

	public function perspectiveOffCenterRH(left : Float, right : Float, bottom : Float, top : Float, zNear : Float, zFar : Float) : Void {
		var vec : Vector<Float> = new Vector<Float>(16);
		vec[ 0] = 2.0 * zNear / (right - left);      vec[ 1] = 0.0;                               vec[ 2] = 0.0;                             vec[ 3] = 0.0;
		vec[ 4] = 0.0;                               vec[ 5] = -2.0 * zNear / (bottom - top);     vec[ 6] = 0.0;                             vec[ 7] = 0.0;
		vec[ 8] = 1.0 + 2.0 * left / (right - left); vec[ 9] = -1.0 - 2.0 * top / (bottom - top); vec[10] = zFar / (zNear - zFar);           vec[11] = -1.0;
		vec[12] = 0.0;                               vec[13] = 0.0;                               vec[14] = (zNear * zFar) / (zNear - zFar); vec[15] = 0.0;
		
		copyRawDataFrom(vec);
	}

	public function orthoLH(width : Float, height : Float, zNear : Float, zFar : Float) : Void {
		var vec : Vector<Float> = new Vector<Float>(16);
		vec[ 0] = 2.0 / width; vec[ 1] = 0.0;          vec[ 2] = 0.0;                    vec[ 3] = 0.0;
		vec[ 4] = 0.0;         vec[ 5] = 2.0 / height; vec[ 6] = 0.0;                    vec[ 7] = 0.0;
		vec[ 8] = 0.0;         vec[ 9] = 0.0;          vec[10] = 1.0 / (zFar - zNear);   vec[11] = 0.0;
		vec[12] = 0.0;         vec[13] = 0.0;          vec[14] = zNear / (zNear - zFar); vec[15] = 1.0;
		copyRawDataFrom(vec);
	}

	public function orthoRH(width : Float, height : Float, zNear : Float, zFar : Float) : Void {
		var vec : Vector<Float> = new Vector<Float>(16);
		vec[ 0] = 2.0 / width; vec[ 1] = 0.0;          vec[ 2] = 0.0;                    vec[ 3] = 0.0;
		vec[ 4] = 0.0;         vec[ 5] = 2.0 / height; vec[ 6] = 0.0;                    vec[ 7] = 0.0;
		vec[ 8] = 0.0;         vec[ 9] = 0.0;          vec[10] = 1.0 / (zNear - zNear);  vec[11] = 0.0;
		vec[12] = 0.0;         vec[13] = 0.0;          vec[14] = zNear / (zNear - zFar); vec[15] = 1.0;
		copyRawDataFrom(vec);
	}

	public function orthoOffCenterLH(left : Float, right : Float, bottom : Float, top : Float, zNear : Float, zFar : Float) : Void {
		var vec : Vector<Float> = new Vector<Float>(16);
		vec[ 0] = 2.0 / (right - left);               vec[ 1] = 0.0;                              vec[ 2] = 0.0;                    vec[ 3] = 0.0;
		vec[ 4] = 0.0;                                vec[ 5] = 2.0 * zNear / (top - bottom);     vec[ 6] = 0.0;                    vec[ 7] = 0.0;
		vec[ 8] = -1.0 - 2.0 * left / (right - left); vec[ 9] = 1.0 + 2.0 * top / (bottom - top); vec[10] = 1.0 / (zFar - zNear);   vec[11] = 0.0;
		vec[12] = 0.0;                                vec[13] = 0.0;                              vec[14] = zNear / (zNear - zFar); vec[15] = 1.0;
		copyRawDataFrom(vec);
	}

	public function orthoOffCenterRH(left : Float, right : Float, bottom : Float, top : Float, zNear : Float, zFar : Float) : Void {
		var vec : Vector<Float> = new Vector<Float>(16);
		vec[ 0] = 2.0 / (right - left);               vec[ 1] = 0.0;                              vec[ 2] = 0.0;                    vec[ 3] = 0.0;
		vec[ 4] = 0.0;                                vec[ 5] = 2.0 * zNear / (top - bottom);     vec[ 6] = 0.0;                    vec[ 7] = 0.0;
		vec[ 8] = -1.0 - 2.0 * left / (right - left); vec[ 9] = 1.0 + 2.0 * top / (bottom - top); vec[10] = 1.0 / (zNear - zFar);   vec[11] = 0.0;
		vec[12] = 0.0;                                vec[13] = 0.0;                              vec[14] = zNear / (zNear - zFar); vec[15] = 1.0;
		copyRawDataFrom(vec);
	}

	private var _x : Vector3D;
	private var _y : Vector3D;
	private var _z : Vector3D;
	private var _w : Vector3D;

	private function _crossProductTo(a : Vector3D, b : Vector3D) : Void {
		_w.x = a.y * b.z - a.z * b.y;
		_w.y = a.z * b.x - a.x * b.z;
		_w.z = a.x * b.y - a.y * b.x;
		_w.w = 1.0;
		a.copyFrom(_w);
	}
}