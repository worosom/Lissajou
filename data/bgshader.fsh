/* Radial gradient shader
 */

#ifdef GL_ES
precision highp float;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform float volume;
uniform vec2 resolution;

varying vec4 vertColor;
varying vec4 gl_FragCoord;

void main()
{
	vec2 u = gl_FragCoord.st/resolution.xy;
	vec2 uv = (gl_FragCoord.st/resolution.xy * 2.) - 1.;

	vec3 c = texture2D(texture, u).rgb;

	float alpha =  clamp((length(uv) * length(uv)) + volume * 2., 0., 1.);
	gl_FragColor = vec4(1.-c * alpha, 1.);
}
