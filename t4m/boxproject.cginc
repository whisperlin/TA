
#ifndef  ______________BOX_PROJECT_SKY_BOX_________________________
#define ______________BOX_PROJECT_SKY_BOX_________________________  

#if BOX_PROJECT_SKY_BOX

float4 cubemapCenter;
float4 boxMin;
float4 boxMax;

inline half3 BoxProjectedCubemapDirectionT4M(half3 worldRefl, float3 worldPos, float4 cubemapCenter, float4 boxMin, float4 boxMax)
{

	if (cubemapCenter.w > 0.0)
	{
		half3 nrdir = normalize(worldRefl);

		half3 rbmax = (boxMax.xyz - worldPos) / nrdir;
		half3 rbmin = (boxMin.xyz - worldPos) / nrdir;

		half3 rbminmax = (nrdir > 0.0f) ? rbmax : rbmin;

		half fa = min(min(rbminmax.x, rbminmax.y), rbminmax.z);

		worldPos -= cubemapCenter.xyz;
		worldRefl = worldPos + nrdir * fa;

	}
	return worldRefl;
}

#endif


#endif