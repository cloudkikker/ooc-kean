#version 300 es
precision highp float;
uniform float pointSize;
uniform mat4 transform;
layout(location = 0) in vec2 vertexPosition;
void main() {
	gl_PointSize = pointSize;
	gl_Position = transform * vec4(vertexPosition.x, vertexPosition.y, 0, 1);
}
