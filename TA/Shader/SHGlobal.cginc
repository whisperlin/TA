#ifndef ___GLOBAL_SH9___
#define ___GLOBAL_SH9___ 1


#define DEFINE_SH9(name)\
uniform float4 name##0;\
uniform float4 name##1;\
uniform float4 name##2;\
uniform float4 name##3;\
uniform float4 name##4;\
uniform float4 name##5;\
uniform float4 name##6;\
uniform float4 name##7;\
uniform float4 name##8;
 

DEFINE_SH9(g_sph)
DEFINE_SH9(g_sph_role)


 

float Y0(float3 v)//SH_0_0
{
	return 0.2820947917f;
}
float Y1(float3 v)//SH_1_0
{
	return 0.4886025119f * v.y;
}
float Y2(float3 v)//SH_1_1
{
	return 0.4886025119f * v.z;
}
float Y3(float3 v)//SH_1_2
{
	return 0.4886025119f * v.x;
}
float Y4(float3 v)//SH_2_0
{
	return 1.0925484306f * v.x * v.y;
}
float Y5(float3 v)//SH_2_1
{
	return 1.0925484306f * v.y * v.z;
}
float Y6(float3 v)//SH_2_2
{
	return 0.3153915652f * (3.0f * v.z * v.z - 1.0f);
}
float Y7(float3 v)//SH_2_3
{
	return 1.0925484306f * v.x * v.z;
}
float Y8(float3 v)//SH_2_4
{
	return 0.5462742153f * (v.x * v.x - v.y * v.y);
}


#define CMP_SH9_ORDER3(v,name,col)\
float3 name##result = (\
name##0.xyz * Y0(v) +\
name##1.xyz * Y1(v) +\
name##2.xyz * Y2(v) +\
name##3.xyz * Y3(v) +\
name##4.xyz * Y4(v) +\
name##5.xyz * Y5(v) +\
name##6.xyz * Y6(v) +\
name##7.xyz * Y7(v) +\
name##8.xyz * Y8(v)\
);\
col= max(name##result, float3(0, 0, 0));


#define CMP_SH9_ORDER2(v,name,col)\
float3 name##result = (\
name##0.xyz * Y0(v) +\
name##1.xyz * Y1(v) +\
name##2.xyz * Y2(v) +\
name##3.xyz * Y3(v) );\
col= max(name##result, float3(0, 0, 0));

 
float3 g_sh(float3 v)
{
	float3 col;
	CMP_SH9_ORDER3(v,g_sph,col);
	return col*2;
	/*float3 result = (
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
	return max(result, float3(0, 0, 0));*/
}
float3 g_sh3(float3 v)
{
	float3 col;
	CMP_SH9_ORDER2(v, g_sph, col);
	return col*2;

	/*float3 result = (
		g_sph0.xyz * Y0(v) +
		g_sph1.xyz * Y1(v) +
		g_sph2.xyz * Y2(v) +
		g_sph3.xyz * Y3(v)

		);
	return max(result, float3(0, 0, 0));*/
}


float3 g_sh_role(float3 v)
{
	float3 col;
	CMP_SH9_ORDER3(v, g_sph_role, col);
	return col * 2;
	/*float3 result = (
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
	return max(result, float3(0, 0, 0));*/
}

#endif