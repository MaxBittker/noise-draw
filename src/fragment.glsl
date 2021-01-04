precision highp float;
uniform float t;
uniform vec2 resolution;
uniform sampler2D backBuffer;
uniform vec2 point;
uniform vec2 prevPoint;
// uniform float aspectRatio;
uniform float force;
// uniform float radius;

// uniform sampler2D webcam;
// uniform vec2 videoResolution;
// uniform vec2 eyes[2];

varying vec2 uv;

// clang-format off
#pragma glslify: squareFrame = require("glsl-square-frame")
#pragma glslify: worley2D = require(glsl-worley/worley2D.glsl)
#pragma glslify: hsv2rgb = require('glsl-hsv2rgb')
#pragma glslify: luma = require(glsl-luma)
#pragma glslify: smin = require(glsl-smooth-min)
#pragma glslify: fbm3d = require('glsl-fractal-brownian-noise/3d')
#pragma glslify: noise = require('glsl-noise/simplex/3d')

// clang-format on
#define PI 3.14159265359

float sdSegment(in vec2 p, in vec2 a, in vec2 b, in float R) {
  float h = min(1.0, max(0.0, dot(p - a, b - a) / dot(b - a, b - a)));
  return length(p - a - (b - a) * h) - R;
}
void main() {
  float aspectRatio = resolution.x / resolution.y;
  vec2 pixel = vec2(1.0) / resolution;
  vec2 scale = vec2(aspectRatio, 1.0);
  vec2 vUv = uv * 0.5 + vec2(0.5);

  float radius = (force * 0.8 + 0.3) / 300.;
  vec2 p = vUv - point.xy;

  p.x *= aspectRatio;

  // vec3 splat = exp(-dot(p, p) / radius) * vec3(0.1);

  float seg = sdSegment(vUv * scale, point.xy * scale, prevPoint.xy * scale,
                        0.05 * (0.1 + force * 0.4));
  // seg = 0.001;

  // seg = exp(-dot(seg, seg) / r/adius);
  seg = 1.0 - (200. * seg);
  seg = max(0., seg);
  vec3 splat = vec3(1.0) * seg;
  // if (seg < 0.) {
  // splat = vec3(1.0);
  // }
  //  * seg;
  // exp(-dot(p, p) / radius) * vec3(0.1);
  vec3 base = texture2D(backBuffer, vUv).xyz;

  vec3 drip = texture2D(backBuffer, vUv + vec2(0., pixel.y)).xyz;
  vec3 below = texture2D(backBuffer, vUv - vec2(0., pixel.y)).xyz;

  float n = 0.8 + noise(vec3(vUv * 500., t * 0.05)) * 0.2;
  float dripmap = noise(vec3(vUv.xy * vec2(50.0, 1.0), t * 0.000));

  float fn = 1.0;
  // if (length(base) < 0.37) {
  // base *= 0.4;
  // }
  // fn = 1.0;
  float splatf = luma(splat);
  float basef = luma(base);
  float fill = (1.0 - luma(base)) * luma(splat) * n * 0.7;
  gl_FragColor = vec4(base * fn + fill * vec3(1.0), 1.0);
  // gl_FragColor =
  // vec4((vec3(1.0) - base) * splat + ((vec3(1.0) - splat) * base), 1.0);
  // gl_FragColor = vec4(base + vec3(1.0) * seg, 1.0);
}