
#ifndef _____GRASS__SHADOW__________________
#define _____GRASS__SHADOW__________________
uniform fixed grass_bias;
uniform fixed grass_strength;
uniform fixed grass_farplaneScale;
 
uniform float4x4 grass_depthV;
uniform float4x4 grass_depthVPBias;
uniform sampler2D grass_kkShadowMap;
uniform float4 grass_kkShadowMap_TexelSize;



float4 offset_lookup(sampler2D map, float4 loc, float2 offset)
{
	return tex2D(map, loc.xy + offset * grass_kkShadowMap_TexelSize.xy);
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
			float depth = DecodeFloat(offset_lookup(grass_kkShadowMap, shadowCoord, float2(x, y)));
			float shade = max(step(shadowCoord.z - grass_bias, depth), grass_strength);
			sum += shade;
		}
	sum = sum / 16.0;
	return sum;
}



half4 PCF4Samples(float4 shadowCoord)
{
	float sum = 0;
 
	
	float depth = DecodeFloat(offset_lookup(grass_kkShadowMap, shadowCoord,  float2(0.5, 0.5)));
	sum += max(step(shadowCoord.z - grass_bias, depth), grass_strength) * 0.25;

	depth = DecodeFloat(offset_lookup(grass_kkShadowMap, shadowCoord,       float2(-0.5,  0.5)));
	sum += max(step(shadowCoord.z - grass_bias, depth), grass_strength) * 0.25;

	depth = DecodeFloat(offset_lookup(grass_kkShadowMap, shadowCoord,     float2(-0.5, -0.5)));
	sum += max(step(shadowCoord.z - grass_bias, depth), grass_strength) * 0.25;

	depth = DecodeFloat(offset_lookup(grass_kkShadowMap, shadowCoord,     float2( 0.5, -0.5)));
	sum += max(step(shadowCoord.z - grass_bias, depth), grass_strength) * 0.25;

	return sum ;
}

uniform sampler2D grass_kkShadow;
half4 PCFSamplesTexture(float2 shadowCoord)
{
	return tex2D(grass_kkShadow, shadowCoord.xy );
}

/*half4 PCF4SamplesSafe(float4 shadowCoord)
{
	float sum = 0;
	
	half r0 = step(abs(shadowCoord.x), 0.95)*step(abs(shadowCoord.y), 0.95);
	//float4 val = tex2D(grass_kkShadowMap, shadowCoord.xy);
	//return val;
	//float _d0 = DecodeFloat(val);
 
	float depth = DecodeFloat(offset_lookup(grass_kkShadowMap, shadowCoord, float2(0.5, 0.5)));
 
	sum += max(step(shadowCoord.z - grass_bias, depth), grass_strength) * 0.25;

	depth = DecodeFloat(offset_lookup(grass_kkShadowMap, shadowCoord, float2(-0.5, 0.5)));
	sum += max(step(shadowCoord.z - grass_bias, depth), grass_strength) * 0.25;

	depth = DecodeFloat(offset_lookup(grass_kkShadowMap, shadowCoord, float2(-0.5, -0.5)));
	sum += max(step(shadowCoord.z - grass_bias, depth), grass_strength) * 0.25;

	depth = DecodeFloat(offset_lookup(grass_kkShadowMap, shadowCoord, float2(0.5, -0.5)));
	sum += max(step(shadowCoord.z - grass_bias, depth), grass_strength) * 0.25;

	//return sum  ;
	return sum *r0 + (1-r0);
}*/

half4 PCF4SamplesSafe(float4 shadowCoord)
{
	float sum = 0;

	half r0 = step(abs(shadowCoord.x), 0.95)*step(abs(shadowCoord.y), 0.95);
	//
	float4 depth = tex2D(grass_kkShadowMap, shadowCoord.xy);
	sum = max(step(shadowCoord.z - grass_bias, depth), grass_strength)  ;
	//return sum  ;
	return sum * r0 + (1 - r0);
}

#endif