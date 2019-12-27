
#ifndef ___GLOBAL_SH9___
#define ___GLOBAL_SH9___ 1


uniform float4 g_sph0;
uniform float4 g_sph1;
uniform float4 g_sph2;
uniform float4 g_sph3;
uniform float4 g_sph4;
uniform float4 g_sph5;
uniform float4 g_sph6;
uniform float4 g_sph7;
uniform float4 g_sph8;


 

float Y0(float3 v)
{
	return 0.2820947917f;
}
float Y1(float3 v)
{
	return 0.4886025119f * v.y;
}
float Y2(float3 v)
{
	return 0.4886025119f * v.z;
}
float Y3(float3 v)
{
	return 0.4886025119f * v.x;
}
float Y4(float3 v)
{
	return 1.0925484306f * v.x * v.y;
}
float Y5(float3 v)
{
	return 1.0925484306f * v.y * v.z;
}
float Y6(float3 v)
{
	return 0.3153915652f * (3.0f * v.z * v.z - 1.0f);
}
float Y7(float3 v)
{
	return 1.0925484306f * v.x * v.z;
}
float Y8(float3 v)
{
	return 0.5462742153f * (v.x * v.x - v.y * v.y);
}




float3 g_sh(float3 v)
{
	float3 result = (
		g_sph0.xyz * Y0(v) +
		g_sph1.xyz * Y1(v) +
		g_sph2.xyz * Y2(v) +
		g_sph3.xyz * Y3(v) +
		g_sph4.xyz * Y4(v) +
		g_sph5.xyz * Y5(v) +
		g_sph6.xyz * Y6(v) +
		g_sph7.xyz * Y7(v) +
		g_sph8.xyz * Y8(v)
	);
	return max(result, float3(0, 0, 0));
}

#endif