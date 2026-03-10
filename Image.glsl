#define COLORDEPTH 3.0
#define RESOLUTIONFACTOR 9.0

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	// Snap to block grid FIRST — everything derives from this
	vec2 blockCoord = floor(fragCoord / RESOLUTIONFACTOR) * RESOLUTIONFACTOR;

	float rawH;
	if (iFrame % 2 == 1)
		rawH = texture(iChannel0, blockCoord / iResolution.xy).r;
	else
		rawH = texture(iChannel1, blockCoord / iResolution.xy).r;

	float signal = rawH * 0.5 + 0.25;  // was + 0.5

	// Tile Bayer on the block grid too
	vec2 bayerUV = mod(blockCoord, iChannelResolution[2].xy) / iChannelResolution[2].xy;
	float bayer = texture(iChannel2, bayerUV).r;

	float stepSize = 1.0 / COLORDEPTH;
	float dithered = signal + (bayer - 0.5) * stepSize;
	float quantized = floor(dithered * COLORDEPTH + 0.5) / COLORDEPTH;
	// quantized = 1.0 - quantized;
	quantized = step(0.5, quantized);

	vec3 blue = vec3(0.0, 0.0, 251.0/255.0);
	vec3 white = vec3(1.0);
	fragColor = vec4(quantized > 0.5 ? white : blue, 1.0);
}
