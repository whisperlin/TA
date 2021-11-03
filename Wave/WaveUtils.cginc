#ifndef WAVE_UTILS
#define WAVE_UTILS

float4 EncodeHeight(float height) {
	return float4((height > 0 ? height : 0), (height <= 0 ? -height : 0),0,0);
	//float2 rg = EncodeFloatRG(height > 0 ? height : 0);
	//float2 ba = EncodeFloatRG(height <= 0 ? -height : 0);
	//float2 rg = EncodeFloatRG(height > 0 ? height : 0);
	//float2 ba = EncodeFloatRG(height <= 0 ? -height : 0);
	//return float4(rg, ba);
}

float DecodeHeight(float4 rgba) {
	float h1 = rgba.r;
	float h2 = rgba.g;
	//float h1 = DecodeFloatRG(rgba.rg);
	//float h2 = DecodeFloatRG(rgba.ba);
	int c = step(h2, h1);
	return lerp(h2, h1, c);
}


float4 EncodeHeightRG(float height) {
	return float4((height > 0 ? height : 0), (height <= 0 ? -height : 0),0,0);
}
float DecodeHeightRG(float2 val) {
	float h1 = val.r;
	float h2 = val.g;
	int c = step(h2, h1);
	return lerp(h2, h1, c);
}
#endif
