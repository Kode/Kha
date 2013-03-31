#ifdef GL_ES
precision highp float;
#endif

uniform sampler2D tex;
varying vec2 texCoord;

void main() {
	//gl_FragColor = vec4(1.0,1.0,1.0,1.0);
	//vec4 color = texture2D(tex, texCoord);
	//color += vec4(0.1, 0.1, 0.1, 1);
	//gl_FragColor = color; //vec4(color.xyz * v_Dot, color.a);
	gl_FragColor = texture2D(tex, texCoord);
}
