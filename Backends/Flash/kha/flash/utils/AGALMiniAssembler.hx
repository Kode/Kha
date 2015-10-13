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

import flash.display3D.Context3DProgramType;
import flash.utils.ByteArray;
import flash.utils.Endian;

class AGALMiniAssembler {
	// ======================================================================
	//  Properties
	// ----------------------------------------------------------------------
	// AGAL bytes and error buffer 
	private var _agalcode : ByteArray;
	private var _error : String;

	private var debugEnabled : Bool;

	private static var initialized : Bool = false;

	// ======================================================================
	//  Getters
	// ----------------------------------------------------------------------
	public function error() : String       { return _error; }
	public function agalcode() : ByteArray { return _agalcode; }

	// ======================================================================
	//  Constructor
	// ----------------------------------------------------------------------
	public function new(debugging : Bool = false) : Void {
		_agalcode = null;
		_error = "";
		debugEnabled = debugging;
		if (!initialized) init();
	}
	// ======================================================================
	//  Methods
	// ----------------------------------------------------------------------
	public function assemble(mode : Context3DProgramType, source : String, verbose : Bool = false) : ByteArray {
		//var start:UInt = getTimer();

		_agalcode = new ByteArray();
		_error = "";

		var isFrag:Bool = false;

		if (mode == Context3DProgramType.FRAGMENT) isFrag = true;

		_agalcode.endian = Endian.LITTLE_ENDIAN;
		_agalcode.writeByte(0xa0);            // tag version
		_agalcode.writeUnsignedInt(0x2);      // AGAL version, big endian, bit pattern will be 0x01000000
		_agalcode.writeByte(0xa1);            // tag program id
		_agalcode.writeByte(isFrag ? 1 : 0);  // vertex or fragment

		var reg : EReg = ~/[\n\r]+/g;
		var lines : Array<String> = reg.replace(source, "\n").split("\n");
		var nest : Int = 0;
		var nops : Int = 0;
		var i : Int;
		var lng : Int = lines.length;

		i = 0;
		while (i < lng && _error == "") {
			var line : String = new String(lines[i]);
			if (line == "") {
				++i;
				continue;
			}
			
			// remove comments
			var startcomment : Int = line.indexOf("//");
			if (startcomment != -1) line = line.substr(0, startcomment);

			// grab options
			reg = ~/<.*>/g;
			var optsi : Int = -1;
			if (reg.match(line)) optsi = reg.matchedPos().pos;
			var opts : String = "";
			if (optsi != -1) {
				reg = ~/([\w\.\-\+]+)/gi;
				reg.match(line.substr(optsi));
				opts = reg.matched(0);
				line = line.substr(0, optsi);
			}

			// find opcode
			reg = ~/^\w{3}/ig;
			reg.match(line);
			var opCode : String = reg.matched(0);
			var opFound : OpCode = OPMAP.get(opCode);

			// if debug is enabled, output the opcodes
			if (debugEnabled) trace(opFound);

			if (opFound == null) {
				if (line.length >= 3) trace("warning: bad line " + i + ": " + lines[i]);
				++i;
				continue;
			}

			line = line.substr(line.indexOf(opFound.name()) + opFound.name().length);

			// nesting check
			if ((opFound.flags() & OP_DEC_NEST) != 0) {
				nest--;
				if (nest < 0) {
					_error = "error: conditional closes without open.";
					break;
				}
			}
			if ((opFound.flags() & OP_INC_NEST) != 0) {
				nest++;
				if (nest > MAX_NESTING) {
					_error = "error: nesting to deep, maximum allowed is " + MAX_NESTING + ".";
					break;
				}
			}
			if (((opFound.flags() & OP_FRAG_ONLY) != 0) && !isFrag) {
				_error = "error: opcode is only allowed in fragment programs.";
				break;
			}
			if (verbose) trace("emit opcode=" + opFound);

			_agalcode.writeUnsignedInt( opFound.emitCode() );
			nops++;

			if (nops > MAX_OPCODES) {
				_error = "error: too many opcodes. maximum is " + MAX_OPCODES + ".";
				break;
			}

			// get operands, use regexp
			reg = ~/vc\[([vof][actps]?)(\d*)?(\.[xyzw](\+\d{1,3})?)?\](\.[xyzw]{1,4})?|([vof][actps]?)(\d*)?(\.[xyzw]{1,4})?/gi;
			var subline : String = line;
			var regs : Array<String> = new Array<String>();
			while (reg.match(subline)) {
				regs.push(reg.matched(0));
				subline = subline.substr(reg.matchedPos().pos + reg.matchedPos().len);
				if (subline.charAt(0) == ",") subline = subline.substr(1);
				reg = ~/vc\[([vof][actps]?)(\d*)?(\.[xyzw](\+\d{1,3})?)?\](\.[xyzw]{1,4})?|([vof][actps]?)(\d*)?(\.[xyzw]{1,4})?/gi;
			}
			if (regs.length != Std.int(opFound.numRegister())) {
				_error = "error: wrong number of operands. found " + regs.length + " but expected " + opFound.numRegister + ".";
				break;
			}

			var badreg : Bool    = false;
			var pad : UInt       = 64 + 64 + 32;
			var regLength : UInt = regs.length;

			var j : Int = 0;
			while (j < Std.int(regLength)) {
				var isRelative : Bool = false;
				reg = ~/\[.*\]/ig;
				var relreg : String = "";
				if (reg.match(regs[j])) {
					relreg = reg.matched(0);
					var relpos : Int = source.indexOf(relreg);
					regs[j] = regs[j].substr(0, relpos) + "0" + regs[j].substr(relpos + relreg.length);

					if (verbose) trace("IS REL");
					isRelative = true;
				}

				reg = ~/^\b[A-Za-z]{1,2}/ig;
				reg.match(regs[j]);
				var res : String = reg.matched(0);
				var regFound : Register = REGMAP.get(res);

				// if debug is enabled, output the registers
				if (debugEnabled) trace(regFound);

				if (regFound == null) {
					_error = "error: could not parse operand " + j + " (" + regs[j] + ").";
					badreg = true;
					break;
				}

				if (isFrag) {
					if ((regFound.flags() & REG_FRAG) == 0) {
						_error = "error: register operand "+j+" ("+regs[j]+") only allowed in vertex programs.";
						badreg = true;
						break;
					}
					if (isRelative) {
						_error = "error: register operand " + j + " (" + regs[j] + ") relative adressing not allowed in fragment programs.";
						badreg = true;
						break;
					}
				}
				else {
					if ((regFound.flags() & REG_VERT) == 0) {
						_error = "error: register operand " + j + " (" + regs[j] + ") only allowed in fragment programs.";
						badreg = true;
						break;
					}
				}

				regs[j] = regs[j].substr(regs[j].indexOf( regFound.name() ) + regFound.name().length);
				//trace( "REGNUM: " +regs[j] );
				reg = ~/\d+/;
				var idxmatched : Bool;
				if (isRelative) idxmatched = reg.match(relreg);
				else idxmatched = reg.match(regs[j]);

				var regidx : UInt = 0;

				if (idxmatched) regidx = Std.parseInt(reg.matched(0));

				if (regFound.range() < regidx) {
					_error = "error: register operand " + j + " (" + regs[j] + ") index exceeds limit of " + (regFound.range() + 1) + ".";
					badreg = true;
					break;
				}

				var regmask : UInt   = 0;
				var isDest : Bool    = (j == 0 && (opFound.flags() & OP_NO_DEST) == 0);
				var isSampler : Bool = (j == 2 && (opFound.flags() & OP_SPECIAL_TEX) != 0);
				var reltype : UInt   = 0;
				var relsel : UInt    = 0;
				var reloffset : Int  = 0;

				if (isDest && isRelative) {
					_error = "error: relative can not be destination";  
					badreg = true; 
					break;                
				}

				reg = ~/(\.[xyzw]{1,4})/;
				if (reg.match(regs[j])) {
					var maskmatch : String = reg.matched(0);
					regmask = 0;
					var cv : UInt = 0;
					var maskLength : UInt = maskmatch.length;
					var k : Int = 1;
					while (k < Std.int(maskLength)) {
						cv = maskmatch.charCodeAt(k) - "x".charCodeAt(0);
						if (cv > 2) cv = 3;
						if (isDest) regmask |= 1 << cv;
						else regmask |= cv << ( ( k - 1 ) << 1 );
						++k;
					}
					if (!isDest) {
						while (k <= 4) {
							regmask |= cv << ( ( k - 1 ) << 1 ); // repeat last
							++k;
						}
					}
				}
				else regmask = isDest ? 0xf : 0xe4; // id swizzle or mask

				if (isRelative) {
					reg = ~/[A-Za-z]{1,2}/ig;
					reg.match(relreg);
					var relname : String = reg.matched(0);
					var regFoundRel : Register = REGMAP.get(relname);
					if (regFoundRel == null) {
						_error = "error: bad index register";
						badreg = true;
						break;
					}
					reltype = regFoundRel.emitCode();
					reg = ~/(\.[xyzw]{1,1})/;
					if (!reg.match(relreg)) {
						_error = "error: bad index register select";
						badreg = true;
						break;
					}
					var selmatch : String = reg.matched(0);
					relsel = selmatch.charCodeAt(1) - "x".charCodeAt(0);
					if (relsel > 2) relsel = 3;
					reg = ~/\+\d{1,3}/ig;
					if (reg.match(relreg)) {
						reloffset = Std.parseInt(reg.matched(0));
					}
					if (reloffset < 0 || reloffset > 255) {
						_error = "error: index offset "+reloffset+" out of bounds. [0..255]"; 
						badreg = true;
						break;
					}
					if (verbose) trace( "RELATIVE: type="+reltype+"=="+relname+" sel="+relsel+"=="+selmatch+" idx="+regidx+" offset="+reloffset ); 
				}

				if (verbose) trace("  emit argcode=" + regFound + "[" + regidx + "][" + regmask + "]");
				if (isDest) {
					_agalcode.writeShort(regidx);
					_agalcode.writeByte(regmask);
					_agalcode.writeByte(regFound.emitCode());
					pad -= 32;
				}
				else {
					if (isSampler) {
						if (verbose) trace("  emit sampler");
						var samplerbits : UInt = 5; // type 5
						var optsLength:UInt = opts.length;
						var bias:Float = 0;
						var k : Int = 0;
						while (k < Std.int(optsLength)) {
							if (verbose) trace("    opt: " + opts.charAt(k));
							var optfound : Sampler = SAMPLEMAP.get(opts.charAt(k));
							if (optfound == null) {
								// todo check that it's a number...
								//trace( "Warning, unknown sampler option: "+opts[k] );
								bias = Std.parseFloat(opts.charAt(k));
								if (verbose) trace("    bias: " + bias);
							}
							else {
								if (optfound.flag() != SAMPLER_SPECIAL_SHIFT) samplerbits &= ~(0xf << optfound.flag());
								samplerbits |= optfound.mask() << optfound.flag();
							}
							++k;
						}
						_agalcode.writeShort(regidx);
						_agalcode.writeByte(Std.int(bias * 8.0));
						_agalcode.writeByte(0);
						_agalcode.writeUnsignedInt(samplerbits);

						if (verbose) trace("    bits: " + ( samplerbits - 5 ));
						pad -= 64;
					}
					else {
						if (j == 0) {
							_agalcode.writeUnsignedInt(0);
							pad -= 32;
						}
						_agalcode.writeShort(regidx);
						_agalcode.writeByte(reloffset);
						_agalcode.writeByte(regmask);
						_agalcode.writeByte(regFound.emitCode());
						_agalcode.writeByte(reltype);
						_agalcode.writeShort(isRelative ? ( relsel | ( 1 << 15 ) ) : 0);

						pad -= 64;
					}
				}
				++j;
			}

			// pad unused regs
			j = 0;
			while (j < Std.int(pad)) {
				_agalcode.writeByte(0);
				j += 8;
			}

			if (badreg) break;
			++i;
		}

		if (_error != "") {
			_error += "\n  at line " + i + " " + lines[i];
			_agalcode.length = 0;
			trace(_error);
		}

		// trace the bytecode bytes if debugging is enabled
		if (debugEnabled) {
			var dbgLine : String = "generated bytecode:";
			var agalLength : UInt = _agalcode.length;
			var index : UInt = 0;
			while (index < agalLength) {
				if (( index % 16) == 0) dbgLine += "\n";
				if ((index % 4) == 0) dbgLine += " ";

				var byteStr : String = Std.string(_agalcode[index]);// .toString( 16 );
				if (byteStr.length < 2) byteStr = "0" + byteStr;

				dbgLine += byteStr;
				++index;
			}
			trace( dbgLine );
		}

		//if (verbose) trace( "AGALMiniAssembler.assemble time: " + ( ( getTimer() - start ) / 1000 ) + "s" );

		return _agalcode;
	}

	static private function init() : Void {
		initialized = true;

		// Fill the dictionaries with opcodes and registers
		OPMAP.set(MOV, new OpCode(MOV, 2, 0x00, 0));
		OPMAP.set(ADD, new OpCode(ADD, 3, 0x01, 0));
		OPMAP.set(SUB, new OpCode(SUB, 3, 0x02, 0));
		OPMAP.set(MUL, new OpCode(MUL, 3, 0x03, 0));
		OPMAP.set(DIV, new OpCode(DIV, 3, 0x04, 0));
		OPMAP.set(RCP, new OpCode(RCP, 2, 0x05, 0));
		OPMAP.set(MIN, new OpCode(MIN, 3, 0x06, 0));
		OPMAP.set(MAX, new OpCode(MAX, 3, 0x07, 0));
		OPMAP.set(FRC, new OpCode(FRC, 2, 0x08, 0));
		OPMAP.set(SQT, new OpCode(SQT, 2, 0x09, 0));
		OPMAP.set(RSQ, new OpCode(RSQ, 2, 0x0a, 0));
		OPMAP.set(POW, new OpCode(POW, 3, 0x0b, 0));
		OPMAP.set(LOG, new OpCode(LOG, 2, 0x0c, 0));
		OPMAP.set(EXP, new OpCode(EXP, 2, 0x0d, 0));
		OPMAP.set(NRM, new OpCode(NRM, 2, 0x0e, 0));
		OPMAP.set(SIN, new OpCode(SIN, 2, 0x0f, 0));
		OPMAP.set(COS, new OpCode(COS, 2, 0x10, 0));
		OPMAP.set(CRS, new OpCode(CRS, 3, 0x11, 0));
		OPMAP.set(DP3, new OpCode(DP3, 3, 0x12, 0));
		OPMAP.set(DP4, new OpCode(DP4, 3, 0x13, 0));
		OPMAP.set(ABS, new OpCode(ABS, 2, 0x14, 0));
		OPMAP.set(NEG, new OpCode(NEG, 2, 0x15, 0));
		OPMAP.set(SAT, new OpCode(SAT, 2, 0x16, 0));
		OPMAP.set(M33, new OpCode(M33, 3, 0x17, OP_SPECIAL_MATRIX));
		OPMAP.set(M44, new OpCode(M44, 3, 0x18, OP_SPECIAL_MATRIX));
		OPMAP.set(M34, new OpCode(M34, 3, 0x19, OP_SPECIAL_MATRIX));
		OPMAP.set(IFZ, new OpCode(IFZ, 1, 0x1a, OP_NO_DEST | OP_INC_NEST | OP_SCALAR));
		OPMAP.set(INZ, new OpCode(INZ, 1, 0x1b, OP_NO_DEST | OP_INC_NEST | OP_SCALAR));
		OPMAP.set(IFE, new OpCode(IFE, 2, 0x1c, OP_NO_DEST | OP_INC_NEST | OP_SCALAR));
		OPMAP.set(INE, new OpCode(INE, 2, 0x1d, OP_NO_DEST | OP_INC_NEST | OP_SCALAR));
		OPMAP.set(IFG, new OpCode(IFG, 2, 0x1e, OP_NO_DEST | OP_INC_NEST | OP_SCALAR));
		OPMAP.set(IFL, new OpCode(IFL, 2, 0x1f, OP_NO_DEST | OP_INC_NEST | OP_SCALAR));
		OPMAP.set(IEG, new OpCode(IEG, 2, 0x20, OP_NO_DEST | OP_INC_NEST | OP_SCALAR));
		OPMAP.set(IEL, new OpCode(IEL, 2, 0x21, OP_NO_DEST | OP_INC_NEST | OP_SCALAR));
		OPMAP.set(ELS, new OpCode(ELS, 0, 0x22, OP_NO_DEST | OP_INC_NEST | OP_DEC_NEST));
		OPMAP.set(EIF, new OpCode(EIF, 0, 0x23, OP_NO_DEST | OP_DEC_NEST));
		OPMAP.set(REP, new OpCode(REP, 1, 0x24, OP_NO_DEST | OP_INC_NEST | OP_SCALAR));
		OPMAP.set(ERP, new OpCode(ERP, 0, 0x25, OP_NO_DEST | OP_DEC_NEST));
		OPMAP.set(BRK, new OpCode(BRK, 0, 0x26, OP_NO_DEST));
		OPMAP.set(KIL, new OpCode(KIL, 1, 0x27, OP_NO_DEST | OP_FRAG_ONLY));
		OPMAP.set(TEX, new OpCode(TEX, 3, 0x28, OP_FRAG_ONLY | OP_SPECIAL_TEX));
		OPMAP.set(SGE, new OpCode(SGE, 3, 0x29, 0));
		OPMAP.set(SLT, new OpCode(SLT, 3, 0x2a, 0));
		OPMAP.set(SGN, new OpCode(SGN, 2, 0x2b, 0));

		REGMAP.set(VA, new Register(VA,  "vertex attribute",   0x0,   7, REG_VERT | REG_READ));
		REGMAP.set(VC, new Register(VC,  "vertex constant",    0x1, 127, REG_VERT | REG_READ));
		REGMAP.set(VT, new Register(VT,  "vertex temporary",   0x2,  25, REG_VERT | REG_WRITE | REG_READ));
		REGMAP.set(OP, new Register(OP,  "vertex output",      0x3,   0, REG_VERT | REG_WRITE));
		REGMAP.set( V, new Register( V,  "varying",            0x4,   7, REG_VERT | REG_FRAG | REG_READ | REG_WRITE));
		REGMAP.set(FC, new Register(FC,  "fragment constant",  0x1,  27, REG_FRAG | REG_READ));
		REGMAP.set(FT, new Register(FT,  "fragment temporary", 0x2,  25, REG_FRAG | REG_WRITE | REG_READ));
		REGMAP.set(FS, new Register(FS,  "texture sampler",    0x5,   7, REG_FRAG | REG_READ));
		REGMAP.set(OC, new Register(OC,  "fragment output",    0x3,   0, REG_FRAG | REG_WRITE));

		SAMPLEMAP.set(D2,         new Sampler(D2,         SAMPLER_DIM_SHIFT,     0));
		SAMPLEMAP.set(D3,         new Sampler(D3,         SAMPLER_DIM_SHIFT,     2));
		SAMPLEMAP.set(CUBE,       new Sampler(CUBE,       SAMPLER_DIM_SHIFT,     1));
		SAMPLEMAP.set(MIPNEAREST, new Sampler(MIPNEAREST, SAMPLER_MIPMAP_SHIFT,  1));
		SAMPLEMAP.set(MIPLINEAR,  new Sampler(MIPLINEAR,  SAMPLER_MIPMAP_SHIFT,  2));
		SAMPLEMAP.set(MIPNONE,    new Sampler(MIPNONE,    SAMPLER_MIPMAP_SHIFT,  0));
		SAMPLEMAP.set(NOMIP,      new Sampler(NOMIP,      SAMPLER_MIPMAP_SHIFT,  0));
		SAMPLEMAP.set(NEAREST,    new Sampler(NEAREST,    SAMPLER_FILTER_SHIFT,  0));
		SAMPLEMAP.set(LINEAR,     new Sampler(LINEAR,     SAMPLER_FILTER_SHIFT,  1));
		SAMPLEMAP.set(CENTROID,   new Sampler(CENTROID,   SAMPLER_SPECIAL_SHIFT, 1 << 0));
		SAMPLEMAP.set(SINGLE,     new Sampler(SINGLE,     SAMPLER_SPECIAL_SHIFT, 1 << 1));
		SAMPLEMAP.set(DEPTH,      new Sampler(DEPTH,      SAMPLER_SPECIAL_SHIFT, 1 << 2));
		SAMPLEMAP.set(REPEAT,     new Sampler(REPEAT,     SAMPLER_REPEAT_SHIFT,  1));
		SAMPLEMAP.set(WRAP,       new Sampler(WRAP,       SAMPLER_REPEAT_SHIFT,  1));
		SAMPLEMAP.set(CLAMP,      new Sampler(CLAMP,      SAMPLER_REPEAT_SHIFT,  0));
	}

	// ======================================================================
	//  Constants
	// ----------------------------------------------------------------------
	private static var OPMAP : Map<String, OpCode>      = new Map<String, OpCode>();
	private static var REGMAP : Map<String, Register>   = new Map<String, Register>();
	private static var SAMPLEMAP : Map<String, Sampler> = new Map<String, Sampler>();

	private static var MAX_NESTING : Int         = 4;
	private static var MAX_OPCODES : Int         = 256;

	private static var FRAGMENT : String         = "fragment";
	private static var VERTEX : String           = "vertex";

	// masks and shifts
	private static var SAMPLER_DIM_SHIFT : UInt     = 12;
	private static var SAMPLER_SPECIAL_SHIFT : UInt = 16;
	private static var SAMPLER_REPEAT_SHIFT : UInt  = 20;
	private static var SAMPLER_MIPMAP_SHIFT : UInt  = 24;
	private static var SAMPLER_FILTER_SHIFT : UInt  = 28;

	// regmap flags
	private static var REG_WRITE : UInt           = 0x1;
	private static var REG_READ : UInt            = 0x2;
	private static var REG_FRAG : UInt            = 0x20;
	private static var REG_VERT : UInt            = 0x40;

	// opmap flags
	private static var OP_SCALAR : UInt            = 0x1;
	private static var OP_INC_NEST : UInt          = 0x2;
	private static var OP_DEC_NEST : UInt          = 0x4;
	private static var OP_SPECIAL_TEX : UInt       = 0x8;
	private static var OP_SPECIAL_MATRIX : UInt    = 0x10;
	private static var OP_FRAG_ONLY : UInt         = 0x20;
	private static var OP_VERT_ONLY : UInt         = 0x40;
	private static var OP_NO_DEST : UInt           = 0x80;

	// opcodes
	private static var MOV : String              = "mov";
	private static var ADD : String              = "add";
	private static var SUB : String              = "sub";
	private static var MUL : String              = "mul";
	private static var DIV : String              = "div";
	private static var RCP : String              = "rcp";
	private static var MIN : String              = "min";
	private static var MAX : String              = "max";
	private static var FRC : String              = "frc";
	private static var SQT : String              = "sqt";
	private static var RSQ : String              = "rsq";
	private static var POW : String              = "pow";
	private static var LOG : String              = "log";
	private static var EXP : String              = "exp";
	private static var NRM : String              = "nrm";
	private static var SIN : String              = "sin";
	private static var COS : String              = "cos";
	private static var CRS : String              = "crs";
	private static var DP3 : String              = "dp3";
	private static var DP4 : String              = "dp4";
	private static var ABS : String              = "abs";
	private static var NEG : String              = "neg";
	private static var SAT : String              = "sat";
	private static var M33 : String              = "m33";
	private static var M44 : String              = "m44";
	private static var M34 : String              = "m34";
	private static var IFZ : String              = "ifz";
	private static var INZ : String              = "inz";
	private static var IFE : String              = "ife";
	private static var INE : String              = "ine";
	private static var IFG : String              = "ifg";
	private static var IFL : String              = "ifl";
	private static var IEG : String              = "ieg";
	private static var IEL : String              = "iel";
	private static var ELS : String              = "els";
	private static var EIF : String              = "eif";
	private static var REP : String              = "rep";
	private static var ERP : String              = "erp";
	private static var BRK : String              = "brk";
	private static var KIL : String              = "kil";
	private static var TEX : String              = "tex";
	private static var SGE : String              = "sge";
	private static var SLT : String              = "slt";
	private static var SGN : String              = "sgn";

	// registers
	private static var VA : String              = "va";
	private static var VC : String              = "vc";
	private static var VT : String              = "vt";
	private static var OP : String              = "op";
	private static var V  : String              = "v";
	private static var FC : String              = "fc";
	private static var FT : String              = "ft";
	private static var FS : String              = "fs";
	private static var OC : String              = "oc";

	// samplers
	private static var D2 : String              = "2d";
	private static var D3 : String              = "3d";
	private static var CUBE : String            = "cube";
	private static var MIPNEAREST : String      = "mipnearest";
	private static var MIPLINEAR : String       = "miplinear";
	private static var MIPNONE : String         = "mipnone";
	private static var NOMIP : String           = "nomip";
	private static var NEAREST : String         = "nearest";
	private static var LINEAR : String          = "linear";
	private static var CENTROID : String        = "centroid";
	private static var SINGLE : String          = "single";
	private static var DEPTH : String           = "depth";
	private static var REPEAT : String          = "repeat";
	private static var WRAP : String            = "wrap";
	private static var CLAMP : String           = "clamp";
}

// ================================================================================
//  Helper Classes
// --------------------------------------------------------------------------------

// ===========================================================================
//  Class
// ---------------------------------------------------------------------------
class OpCode {
	// ======================================================================
	//  Properties
	// ----------------------------------------------------------------------
	private var _emitCode : UInt;
	private var _flags : UInt;
	private var _name : String;
	private var _numRegister : UInt;

	// ======================================================================
	//  Getters
	// ----------------------------------------------------------------------
	public function emitCode() : UInt    { return _emitCode; }
	public function flags() : UInt       { return _flags; }
	public function name() : String      { return _name; }
	public function numRegister() : UInt { return _numRegister; }

	// ======================================================================
	//  Constructor
	// ----------------------------------------------------------------------
	public function new(name : String, numRegister : UInt, emitCode : UInt, flags : UInt) {
		_name = name;
		_numRegister = numRegister;
		_emitCode = emitCode;
		_flags = flags;
	}

	// ======================================================================
	//  Methods
	// ----------------------------------------------------------------------
	public function toString() : String {
		return "[OpCode name=\"" + _name + "\", numRegister=" + _numRegister + ", emitCode=" + _emitCode + ", flags=" + _flags + "]";
	}
}

// ===========================================================================
//  Class
// ---------------------------------------------------------------------------
class Register {
	// ======================================================================
	//  Properties
	// ----------------------------------------------------------------------
	private var _emitCode : UInt;
	private var _name:String;
	private var _longName:String;
	private var _flags:UInt;
	private var _range:UInt;

	// ======================================================================
	//  Getters
	// ----------------------------------------------------------------------
	public function emitCode() : UInt   { return _emitCode; }
	public function longName() : String { return _longName; }
	public function name() : String     { return _name; }
	public function flags() : UInt      { return _flags; }
	public function range() : UInt      { return _range; }

	// ======================================================================
	//  Constructor
	// ----------------------------------------------------------------------
	public function new(name : String, longName : String, emitCode : UInt, range : UInt, flags : UInt) {
		_name = name;
		_longName = longName;
		_emitCode = emitCode;
		_range = range;
		_flags = flags;
	}

	// ======================================================================
	//  Methods
	// ----------------------------------------------------------------------
	public function toString() : String {
		return "[Register name=\"" + _name + "\", longName=\"" + _longName + "\", emitCode=" + _emitCode + ", range=" + _range + ", flags=" + _flags + "]";
	}
}

// ===========================================================================
//  Class
// ---------------------------------------------------------------------------
class Sampler {
	// ======================================================================
	//  Properties
	// ----------------------------------------------------------------------
	private var _flag : UInt;
	private var _mask : UInt;
	private var _name : String;

	// ======================================================================
	//  Getters
	// ----------------------------------------------------------------------
	public function flag() : UInt    { return _flag; }
	public function mask() : UInt    { return _mask; }
	public function name() : String  { return _name; }

	// ======================================================================
	//  Constructor
	// ----------------------------------------------------------------------
	public function new(name : String, flag : UInt, mask : UInt) {
		_name = name;
		_flag = flag;
		_mask = mask;
	}

	// ======================================================================
	//  Methods
	// ----------------------------------------------------------------------
	public function toString() : String {
		return "[Sampler name=\"" + _name + "\", flag=\"" + _flag + "\", mask=" + mask + "]";
	}
}