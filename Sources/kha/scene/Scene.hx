package kha.scene;

import kha.Color;
import kha.Game;
import kha.graphics.FragmentShader;
import kha.graphics.IndexBuffer;
import kha.graphics.MipMapFilter;
import kha.graphics.Program;
import kha.graphics.Texture;
import kha.graphics.TextureAddressing;
import kha.graphics.TextureFilter;
import kha.graphics.TextureFormat;
import kha.graphics.Usage;
import kha.graphics.VertexBuffer;
import kha.graphics.VertexShader;
import kha.Loader;
import kha.math.Matrix4;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.Rectangle;
import kha.Scheduler;
import kha.Sys;

class Scene {
	public static var layers(default, null): Array<Layer>;
	
	private static var lightColor: Vector4 = new Vector4(2.0, 2.0, 2.0, 1.0);
	private static var lightDirection: Vector4 = new Vector4(0.1, -0.8, 0.1, 1.0);
	private static var shadowsEnabled: Bool = true;
	private static var environment: Texture;
	private static var sky: Dynamic;
	private static var skyImage: Texture;
	private static var terrain: Bool;
	private static var program: Program;
	private static var sceneMeshes: Array<Dynamic>;
	private static var sceneMeshesSize: Int = 0;
	private static var skeletonMeshes: Array<Dynamic>;
	private static var vertexMeshes: Array<Dynamic>;
	//private static var splines: Array<SplineMesh>;
	private static var target: Texture;

	private static var positions: Texture;
	private static var normals: Texture;
	private static var occlusion: Texture;
	private static var occlusionTemp: Texture;
	private static var dssdoTarget: Texture;
	private static var geometryProgram: Program;
	private static var eye_pos: Vector4;

	//OcclusionPass* occlusionPass;
	//Pass* blurHPass;
	//Pass* blurVPass;
	//Pass* outputPass;

	private static var shadow: Texture;
	private static var lightProjection: Matrix4;
	private static var shadowProgram: Program;
	private static var lightView: Array<Matrix4>;
	private static var lightWorld: Array<Matrix4>;

	private static var particles: Array<Particle>;
	private static var particleVertexShader: VertexShader;
	private static var particleFragmentShader: FragmentShader;
	private static var fog: Bool;
	
	private static var ambientOcclusionEnabled: Bool = false;

	private static function paintShadowMesh(mesh: Dynamic, i: Int): Void {
		var trans = mesh.transformation;
		//Graphics::setWorldMatrix(toMatrix(trans));
		//shadowVertexShader->assign("view", Graphics::view());
		//lightView[i] = Graphics::view();
		//shadowVertexShader->assign("world", Graphics::world());
		//lightWorld[i] = Graphics::world();
		var m: VertexMesh = mesh.mesh;
		Sys.graphics.setTexture(null, m.material.texture);
		Sys.graphics.setIndexBuffer(m.ib);
		Sys.graphics.setVertexBuffer(m.vb);
		Sys.graphics.drawIndexedVertices();
	}

	private static var shadowOrthoSize: Float = 1000;
	private static var shadowZMin: Float = 10;
	private static var shadowZMax: Float = 1500;
	private static var shadowEyeDirDistance: Float = 500;
	private static var shadowLightDirDistance: Float = 750;

	private static function renderShadowMap(): Void {
		if (lightView.length < sceneMeshesSize) {
			//lightView.resize(sceneMeshesSize);
			//lightWorld.resize(sceneMeshesSize);
		}

		var lightDir = new Vector3(lightDirection.x, lightDirection.y, lightDirection.z);

		Sys.graphics.renderToTexture(shadow);
		Sys.graphics.clear(Color.fromValue(0xffffffff), 0);
		
		//Graphics::begin();

		var cam = new Camera();

		//Graphics::ortho(-shadowOrthoSize / 2.0f, shadowOrthoSize / 2.0f, -shadowOrthoSize / 2.0f, shadowOrthoSize / 2.0f, shadowZMin, shadowZMax);
		var eyeDir = cam.at.sub(cam.eye);
		eyeDir.normalize();
		var eye = cam.eye.add(eyeDir.mult(shadowEyeDirDistance)).sub(lightDir.mult(shadowLightDirDistance));
		//Graphics::lookAt(eye, eye + lightDir, cam.up);
		//lightProjection = Graphics::projection();
		
		Sys.graphics.setProgram(shadowProgram);
		
		//Sys.graphics.setMatrix("projection", Graphics::projection());
		
		for (i in 0...sceneMeshesSize) {
			paintShadowMesh(sceneMeshes[i], i);
		}

		//Graphics::end();
		Sys.graphics.renderToBackbuffer();
	}

	private static function geometryMultiTarget() {
		Sys.graphics.renderToTexture(positions);// , 0);
		Sys.graphics.renderToTexture(normals);// , 1);

		Sys.graphics.clear(Color.fromValue(0xff000000), 0);
		
		//Graphics::begin();

		var cam = new Camera();
		//Graphics::perspective(pi / 4, static_cast<float>(Application::the()->width()) / static_cast<float>(Application::the()->height()), cam.zNear, cam.zFar);
		//Graphics::lookAt(cam.eye, cam.at, cam.up);

		eye_pos = new Vector4(cam.eye.x, cam.eye.y, cam.eye.z, 1);

		Sys.graphics.setProgram(geometryProgram);

		//for (i in 0...splines.length) {
		//	splines[i].vertices.set();
		//	splines[i].indices.set();
			//Graphics::setWorldMatrix(Matrix4x4f::Identity());
			//Sys.graphics.setMatrix("matViewProjection", Graphics::projection() * Graphics::view() * Graphics::world());
		//	Sys.graphics.setMatrix("worldRotation", Matrix4.identity());
		//	Sys.graphics.drawIndexedVertices();
		//}

		for (i in 0...sceneMeshesSize) {
			var mesh = sceneMeshes[i];
			var trans = mesh.transformation;
			//Graphics::setWorldMatrix(toMatrix(trans));

			//Sys.graphics.setMatrix("matViewProjection", Graphics::projection() * Graphics::view() * Graphics::world());
			//var rotation = Graphics::world();
			//rotation.set(3, 0, 0);
			//rotation.set(3, 1, 0);
			//rotation.set(3, 2, 0);
			//Sys.graphics.setMatrix("worldRotation", rotation);

			var m: VertexMesh = mesh.mesh;
			Sys.graphics.setIndexBuffer(m.ib);
			Sys.graphics.setVertexBuffer(m.vb);
			Sys.graphics.drawIndexedVertices();
		}

		Sys.graphics.renderToBackbuffer();
		//Graphics::end();
	}

	private static function calculateAmbientOcclusion(): Void {
		geometryMultiTarget();
		for (i in 0...4) {
			Sys.graphics.setTextureParameters(null /* i */, TextureAddressing.Clamp, TextureAddressing.Clamp, TextureFilter.PointFilter, TextureFilter.PointFilter, MipMapFilter.PointMipFilter);
		}
		//occlusionPass->eyePos = eye_pos;
		//occlusionPass->execute();
		//blurHPass->execute();
		//blurVPass->execute();
		//outputPass->execute();
	}

	private static var ib: IndexBuffer;
	private static var vb: VertexBuffer;

	private static function drawParticle(particle: Particle): Void {
		var scale = 1.0 / 256.0;
		//Matrix4x4f viewRotation = Graphics::view();
		//viewRotation = viewRotation.Transpose3x3();
		//viewRotation.Set(3, 0, particle.position.x());
		//viewRotation.Set(3, 1, particle.position.y());
		//viewRotation.Set(3, 2, particle.position.z());
		//viewRotation.Set(0, 3, 0); viewRotation.Set(1, 3, 0); viewRotation.Set(2, 3, 0); viewRotation.Set(3, 3, 1);
	
		//Graphics::setWorldMatrix(viewRotation);

		if (particle.image.width == 0 || particle.image.height == 0) return;
		Sys.graphics.setTexture(null, particle.image);

		//if (ib == null) ib = Kt::Graphics::createIndexBufferForQuads(1);
		if (vb == null) vb = Sys.graphics.createVertexBuffer(4, null, Usage.DynamicUsage);
		var vertices = vb.lock();
	
		var width = particle.image.width * scale;
		var height = particle.image.height * scale;

		var x1 = width / -2.0;
		var x2 = width / 2.0;
		var y1 = 0.0;
		var y2 = height;

		var opacity = particle.lifetime / particle.alive;
		var color = Color.fromFloats(1, 1, 1, opacity);

		//x,y,z,argb,u,v
		vertices[0]  = x1; vertices[1]  = y1; vertices[2]  = 0;
		//((unsigned*)vertices)[3] = color.value();
		//vertices[4]  = particle.image.Tex()->getU(0); vertices[5]  = particle.image.Tex()->getV(1);
	
		vertices[6]  = x2; vertices[7]  = y1; vertices[8]  = 0;
		//((unsigned*)vertices)[9] = color.value();
		//vertices[10] = particle.image.Tex()->getU(1); vertices[11] = particle.image.Tex()->getV(1);

		vertices[12] = x1; vertices[13] = y2; vertices[14] = 0;
		//((unsigned*)vertices)[15] = color.value();
		//vertices[16] = particle.image.Tex()->getU(0); vertices[17] = particle.image.Tex()->getV(0);

		vertices[18] = x2; vertices[19] = y2; vertices[20] = 0;
		//((unsigned*)vertices)[21] = color.value();
		//vertices[22] = particle.image.Tex()->getU(1); vertices[23] = particle.image.Tex()->getV(0);

		vb.unlock();
		Sys.graphics.setVertexBuffer(vb);
		Sys.graphics.setIndexBuffer(ib);
		Sys.graphics.drawIndexedVertices();
	}

	/*class Comparator {
	public:
		Comparator(Vector3f eye) : eye(eye) {

		}

		bool operator()(Scene::Particle first, Scene::Particle second) {
			return (first.position - eye).squareLength() > (second.position - eye).squareLength();
		}
	private:
		Vector3f eye;
	}*/

	private static function updateParticles(): Void {
		for (i in 0...particles.length) {
			particles[i].alive += 1.0 / 60.0;
			if (particles[i].alive >= particles[i].lifetime) {
				//particles.eraseIndex(i);
				//--i;
			}
			else {
				particles[i].speed = particles[i].speed.add(particles[i].acceleration);
				particles[i].position = particles[i].position.add(particles[i].speed);
			}
		}
	}

	private static function drawParticles(eye: Vector3) {
		//Graphics::disableShaders();
		//Graphics::setRenderState(RenderState::Lighting, false);
		//Graphics::setRenderState(RenderState::DepthWrite, false);
		
		//Comparator comparator(eye);
		//particles.quicksort(comparator);

		for (i in 0...particles.length) {
			drawParticle(particles[i]);
		}

		//Graphics::setRenderState(RenderState::Lighting, true);
		//Graphics::setRenderState(RenderState::DepthWrite, true);
	}

	public static function render() {
		//Graphics::end();
		if (shadowsEnabled) {
			renderShadowMap();
		}
		if (ambientOcclusionEnabled) {
			calculateAmbientOcclusion();
		}
		
		for (i in 0...16) {
			//Sys.graphics.setTextureParameters(i, TextureAddressing.Repeat, TextureAddressing.Repeat, TextureFilter.AnisotropicFilter, TextureFilter.AnisotropicFilter, MipMapFilter.LinearMipFilter);
		}

		Sys.graphics.renderToTexture(target);

		Sys.graphics.clear(Color.fromValue(0xffffffff), 0);
		
		//Graphics::begin();
		var cam = new Camera();
		var perspective = Matrix4.perspectiveProjection(Math.PI / 4, Game.the.width / Game.the.height, 10.0, 10000.0);

		var skyDir = cam.at.sub(cam.eye);
		skyDir.normalize();
		skyDir = skyDir.mult(100);
		var skyheight = 200.0;
		//var cam = Matrix4.lookAt(
		cam.eye = new Vector3(0.0, skyheight, 0.0);
		cam.at = new Vector3(skyDir.x, skyDir.y + skyheight, skyDir.z);
		cam.up = new Vector3(0.0, 1.0, 0.0);
		//Graphics::setWorldMatrix(Matrix4x4f::Identity());
		var skyMesh = sky.mesh;
		Sys.graphics.setTexture(null, skyImage);
		skyMesh.data.indexBuffer().set();
		skyMesh.data.vertexBuffer().set();
		Sys.graphics.drawIndexedVertices();
		
		Sys.graphics.clear(null, 0);
		perspective = Matrix4.perspectiveProjection(Math.PI / 4, Game.the.width / Game.the.height, cam.zNear, cam.zFar);
		var view = Matrix4.lookAt(cam.eye, cam.at, cam.up);
		
		//for (i in 0...splines.length) {
		//	splines[i].vertices.set();
		//	splines[i].indices.set();
		//	splines[i].texture.set(0);
			//Graphics::setWorldMatrix(Matrix4x4f::Identity());
			//Graphics::setTextureAddressing(0, Kt::U, Kt::Repeat);
			//Graphics::setTextureAddressing(0, Kt::V, Kt::Repeat);
		//	Sys.graphics.drawIndexedVertices();
		//}
		
		Sys.graphics.setProgram(program);
		Sys.graphics.setMatrix(program.getConstantLocation("projection"), perspective);
		if (shadowsEnabled) {
			Sys.graphics.setBool(program.getConstantLocation("shadows"), true);
			Sys.graphics.setTexture(program.getTextureUnit("shadowSampler"), shadow);
		}
		else {
			Sys.graphics.setBool(program.getConstantLocation("shadows"), false);
		}
		Sys.graphics.setBool(program.getConstantLocation("fog"), fog);

		if (ambientOcclusionEnabled) {
			Sys.graphics.setBool(program.getConstantLocation("ambienOcclusion"), true);
			Sys.graphics.setTexture(null /* 3 */, dssdoTarget);
		}
		else {
			Sys.graphics.setBool(program.getConstantLocation("ambienOcclusion"), false);
		}
		Sys.graphics.setTexture(program.getTextureUnit("environmentmap"), environment);
		Sys.graphics.setBool(program.getConstantLocation("texturing"), true);
		Sys.graphics.setBool(program.getConstantLocation("lighting"), true);
		Sys.graphics.setVector4(program.getConstantLocation("lightDir"), lightDirection);
		Sys.graphics.setFloat(program.getConstantLocation("shininess"), 20.0);
		Sys.graphics.setVector4(program.getConstantLocation("emissiveColor"), new Vector4(0.0, 0.0, 0.0, 1.0));
		Sys.graphics.setVector4(program.getConstantLocation("lightColor"), lightColor);
		Sys.graphics.setVector4(program.getConstantLocation("ambientColor"), new Vector4(0.2, 0.2, 0.2, 1.0));
		Sys.graphics.setVector4(program.getConstantLocation("diffuseColor"), new Vector4(1.0, 1.0, 1.0, 1.0));
		Sys.graphics.setVector4(program.getConstantLocation("specularColor"), new Vector4(1.0, 1.0, 1.0, 1.0));
		Sys.graphics.setFloat(program.getConstantLocation("specularFactor"), 0.3);
		Sys.graphics.setVector4(program.getConstantLocation("eyePos"), new Vector4(cam.eye.x, cam.eye.y, cam.eye.z, 1.0));

		//Graphics::setRenderState(RenderState::BackfaceCulling, false);
		//Graphics::setRenderState(RenderState::AlphaTestState, true);
		//Graphics::setRenderStateI(RenderState::AlphaReferenceState, 250);
		
		for (i in 0...sceneMeshesSize) {
			var mesh = sceneMeshes[i];

			if (!mesh.visible) continue;
			var world = mesh.transformation;
			var m = mesh.mesh;
			m.material.texture.set(0);
			//Graphics::setMaterial(m->material());

			if (mesh.reflection) Sys.graphics.setBool(program.getConstantLocation("environmentmapping"), true);
			else Sys.graphics.setBool(program.getConstantLocation("environmentmapping"), false);

			if (m.hasNormalMap()) {
				m.normalMap().set(2);
				Sys.graphics.setBool(program.getConstantLocation("normalmapping"), true);
			}
			else {
				Sys.graphics.setBool(program.getConstantLocation("normalmapping"), false);
			}

			Sys.graphics.setMatrix(program.getConstantLocation("view"), view);
			Sys.graphics.setMatrix(program.getConstantLocation("world"), world);

			var rotation = new Matrix4(world.matrix);
			rotation.set(3, 0, 0);
			rotation.set(3, 1, 0);
			rotation.set(3, 2, 0);
			Sys.graphics.setMatrix(program.getConstantLocation("worldRotation"), rotation);
			if (shadowsEnabled) {
				Sys.graphics.setMatrix(program.getConstantLocation("lightworld"), lightWorld[i]);
				Sys.graphics.setMatrix(program.getConstantLocation("lightview"), lightView[i]);
				Sys.graphics.setMatrix(program.getConstantLocation("lightprojection"), lightProjection);
			}
			m.indexBuffer().set();
			m.vertexBuffer().set();
			Sys.graphics.drawIndexedVertices();
		}

		Sys.graphics.setBool(program.getConstantLocation("environmentmapping"), false);
		for (i in 0...skeletonMeshes.length) {
			var mesh = skeletonMeshes[i];
			var trans = mesh.transformation;
			//Graphics::setWorldMatrix(transObj.get<MatrixData>()->data);
			Sys.graphics.setBool(null /*"normalmapping"*/, false);
			//Sys.graphics.setMatrix("view", Graphics::view());
			//Sys.graphics.setMatrix("world", Graphics::world());

			//Matrix4x4f rotation = Graphics::world();
			//rotation.set(3, 0, 0);
			//rotation.set(3, 1, 0);
			//rotation.set(3, 2, 0);
			//Sys.graphics.setMatrix("worldRotation", rotation);
			//var position = new Vector3(Graphics::world().get(3, 0), Graphics::world().get(3, 1), Graphics::world().get(3, 2));
			//if ((position - cam.eye).getLength() < 150) mesh.render(skeletonMeshes[i].animationindex);
		}

		for (i in 0...vertexMeshes.length) {
			var mesh = vertexMeshes[i];
			var trans = vertexMeshes[i].transformation;
			//Graphics::setWorldMatrix(transObj.get<MatrixData>()->data);
			Sys.graphics.setBool(null /*"normalmapping"*/, false);
			//Sys.graphics.setMatrix("view", Graphics::view());
			//Sys.graphics.setMatrix("world", Graphics::world());

			//var rotation = Graphics::world();
			//rotation.set(3, 0, 0);
			//rotation.set(3, 1, 0);
			//rotation.set(3, 2, 0);
			//Sys.graphics.setMatrix("worldRotation", rotation);
			mesh.render(vertexMeshes[i].animationindex);
		}

		//Graphics::setRenderState(RenderState::BackfaceCulling, false);
		//Graphics::setRenderState(RenderState::AlphaTestState, false);

		//if (terrain) renderTerrain2();
		
		drawParticles(cam.eye);
		
		Sys.graphics.renderToBackbuffer();
		//Graphics::end();

		//renderHDR(target);

		//Graphics::begin();
	}

	private static function debugPass(): Void {
		//screenVertexShader.set();
		Sys.graphics.setVector4(null /*"resolution"*/, new Vector4(Game.the.width, Game.the.height, 0, 0));
		//screenFragmentShader.set();
		Sys.graphics.renderToTexture(target);
		//drawFullScreenQuad(0, 0, 1, 1);
	}

	private static function textPaint(): Void {
		//if (hdrrendering) renderHDRLastStep(target);
		//else debugPass();

		//Graphics::setRenderState(BlendingState, true);
	}

	private static function updateAnimations(): Void {
		for (i in 0...skeletonMeshes.length) {
			if (skeletonMeshes[i].manualAnimation) skeletonMeshes[i].animationindex = -1;
			else {
				++skeletonMeshes[i].animationindex;
			}
		}
	}

	public static function update(): Void {
		updateParticles();
		updateAnimations();
	}

	public static function setSkyImage(image: Texture): Void {
		skyImage = image;
	}

	public static function setShadows(enabled: Bool): Void {
		shadowsEnabled = enabled;
	}

	public static function init(terrain: Bool, height: Float, terrainPosition: Rectangle, heightmap: Texture = null, heightnormalmap: Texture = null): Void {
		Scene.terrain = terrain;
		environment = cast Loader.the.getImage("angmap11");
		sky = new VertexMesh("himmel");
		skyImage = sky.mesh.material.texture;
		target = Sys.graphics.createRenderTargetTexture(Game.the.width, Game.the.height, TextureFormat.RGBA32, false); // true, true, Target64BitFloat);
		var vertexShader = Sys.graphics.createVertexShader(Loader.the.getBlob("mesh"));
		var fragmentShader = Sys.graphics.createFragmentShader(Loader.the.getBlob("mesh"));
		program = Sys.graphics.createProgram();
		program.setVertexShader(vertexShader);
		program.setFragmentShader(fragmentShader);
		program.link(null);
		if (shadowsEnabled) {
			var shadowVertexShader = Sys.graphics.createVertexShader(Loader.the.getBlob("shadow"));
			var shadowFragmentShader = Sys.graphics.createFragmentShader(Loader.the.getBlob("shadow"));
			shadowProgram = Sys.graphics.createProgram();
			shadowProgram.setVertexShader(shadowVertexShader);
			shadowProgram.setFragmentShader(shadowFragmentShader);
			shadowProgram.link(null);
			shadow = Sys.graphics.createRenderTargetTexture(Game.the.width * 2, Game.the.height * 2, TextureFormat.RGBA32, false); // true, false, Target32BitRedFloat);
		}
		var layer = new Layer3D();
		layer.lighting = true;
		//layer.render = render;
		
		var layers = Scene.layers;
		layers.push(layer);
		
		var layer2D = new Layer2D();
		layer2D.push(layer2D);
		
		var text: Dynamic = {};
		text.x = 0;
		text.y = 0;
		text.width = Game.the.width;
		text.height = Game.the.height;
		text.visible = true;
		text.clipping = false;
		text.paint = textPaint;
		layer2D.push(text);
		
		//if (terrain) initTerrain2(height, terrainPosition, heightmap, heightnormalmap);

		//initHDR();
		if (ambientOcclusionEnabled) {
			positions = Sys.graphics.createRenderTargetTexture(Game.the.width, Game.the.height, TextureFormat.RGBA32, false); // true, false, Target64BitFloat);
			normals = Sys.graphics.createRenderTargetTexture(Game.the.width, Game.the.height, TextureFormat.RGBA32, false); // false, false, Target64BitFloat);
			var geometryVertexShader = Sys.graphics.createVertexShader(Loader.the.getBlob("geometry"));
			var geometryFragmentShader = Sys.graphics.createFragmentShader(Loader.the.getBlob("geometry"));
			geometryProgram = Sys.graphics.createProgram();
			geometryProgram.setVertexShader(geometryVertexShader);
			geometryProgram.setFragmentShader(geometryFragmentShader);
			geometryProgram.link(null);
			occlusion = Sys.graphics.createRenderTargetTexture(Game.the.width, Game.the.height, TextureFormat.RGBA32, false); // false, false, Target64BitFloat);
			occlusionTemp = Sys.graphics.createRenderTargetTexture(Game.the.width, Game.the.height, TextureFormat.RGBA32, false); // false, false, Target64BitFloat);
			dssdoTarget = Sys.graphics.createRenderTargetTexture(Game.the.width, Game.the.height, TextureFormat.RGBA32, false); // false);

			//initPasses();
			//occlusionPass = new OcclusionPass(occlusion, positions, normals);
			//blurHPass = new BlurHPass(occlusionTemp, occlusion, normals);
			//blurVPass = new BlurVPass(occlusion, occlusionTemp, normals);
			//outputPass = new OutputPass(dssdoTarget, positions, normals, occlusion);
		}
		Scheduler.addTimeTask(update, 0, 1.0 / 60.0);
	}

	//private static function add(billboad: Billboard): Void {
	//
	//}

	//public static function add(spline: SplineMesh): Void {
	//	splines.add(spline);
	//}

	public static function addMesh(mesh: Dynamic): Void {
		sceneMeshes[sceneMeshesSize] = mesh;
		++sceneMeshesSize;
	}

	public static function addSkeletonMesh(mesh: Dynamic): Void {
		skeletonMeshes.push(mesh);
	}

	public static function addVertexMesh(mesh: Dynamic): Void {
		vertexMeshes.push(mesh);
	}

	public static function setShadowOrthoSize(value: Float): Void {
		shadowOrthoSize = value;
	}

	public static function setShadowZMin(value: Float): Void {
		shadowZMin = value;
	}

	public static function setShadowZMax(value: Float): Void {
		shadowZMax = value;
	}

	public static function setShadowEyeDirDistance(value: Float): Void {
		shadowEyeDirDistance = value;
	}

	public static function setShadowLightDirDistance(value: Float): Void {
		shadowLightDirDistance = value;
	}

	public static function add(particle: Particle): Void {
		particles.push(particle);
	}

	public static function setFog(enabled: Bool): Void {
		fog = enabled;
	}

	public static function setLight(color: Vector3, direction: Vector3): Void {
		lightColor = new Vector4(color.x, color.y, color.z, 1.0);
		lightDirection = new Vector4(direction.x, direction.y, direction.z, 1.0);
	}
}
