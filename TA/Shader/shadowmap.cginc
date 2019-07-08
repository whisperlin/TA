


uniform fixed _bias;
uniform fixed _strength;
uniform fixed _farplaneScale;
 
uniform float4x4 _depthV;
uniform float4x4 _depthVPBias;
uniform sampler2D _kkShadowMap;
uniform float4 _kkShadowMap_TexelSize;



float4 offset_lookup(sampler2D map, float4 loc, float2 offset)
{
	return tex2D(map, loc.xy + offset * _kkShadowMap_TexelSize.xy);
}

float DecodeFloat(float4 col)
{
	return DecodeFloatRGBA(col);
	//return col.r;
}

half PCF4x4(float4 shadowCoord)
{
	float sum = 0;
	float x, y;
	//16´Î
	for (y = -1.5; y <= 1.5; y += 1.0)
		for (x = -1.5; x <= 1.5; x += 1.0)
		{
			float depth = DecodeFloat(offset_lookup(_kkShadowMap, shadowCoord, float2(x, y)));
			float shade = max(step(shadowCoord.z - _bias, depth), _strength);
			sum += shade;
		}
	sum = sum / 16.0;
	return sum;
}



half4 PCF4Samples(float4 shadowCoord)
{
	float sum = 0;
 
	float depth = DecodeFloat(offset_lookup(_kkShadowMap, shadowCoord,  float2(0.5, 0.5)));
	sum += max(step(shadowCoord.z - _bias, depth), _strength) * 0.25;

	depth = DecodeFloat(offset_lookup(_kkShadowMap, shadowCoord,       float2(-0.5,  0.5)));
	sum += max(step(shadowCoord.z - _bias, depth), _strength) * 0.25;

	depth = DecodeFloat(offset_lookup(_kkShadowMap, shadowCoord,     float2(-0.5, -0.5)));
	sum += max(step(shadowCoord.z - _bias, depth), _strength) * 0.25;

	depth = DecodeFloat(offset_lookup(_kkShadowMap, shadowCoord,     float2( 0.5, -0.5)));
	sum += max(step(shadowCoord.z - _bias, depth), _strength) * 0.25;

	return sum ;
}