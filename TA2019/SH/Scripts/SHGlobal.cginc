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



float Y1(float3 v)//SH_1_0
{
	return  v.y;
}
float Y2(float3 v)//SH_1_1
{
	return  v.z;
}
float Y3(float3 v)//SH_1_2
{
	return  v.x;
}
float Y4(float3 v)//SH_2_0
{
	return  v.x * v.y;
}
float Y5(float3 v)//SH_2_1
{
	return  v.y * v.z;
}
float Y6(float3 v)//SH_2_2
{
	return  (3.0f * v.z * v.z - 1.0f);
}
float Y7(float3 v)//SH_2_3
{
	return  v.x * v.z;
}
float Y8(float3 v)//SH_2_4
{
	return  (v.x * v.x - v.y * v.y);
}


#define CMP_SH9_ORDER3(v,name,col)\
float3 col = saturate (\
name##0.xyz   +\
name##1.xyz * Y1(v) +\
name##2.xyz * Y2(v) +\
name##3.xyz * Y3(v) +\
name##4.xyz * Y4(v) +\
name##5.xyz * Y5(v) +\
name##6.xyz * Y6(v) +\
name##7.xyz * Y7(v) +\
name##8.xyz * Y8(v)\
);\
 

#define CMP_SH9_ORDER2(v,name,col)\
float3 col = saturate(\
name##0.xyz    +\
name##1.xyz * Y1(v) +\
name##2.xyz * Y2(v) +\
name##3.xyz * Y3(v) );\
 
#endif
