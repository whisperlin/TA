

#include "virtuallight.cginc"
#if GLOBAL_ENV_SH9

#include "SHGlobal.cginc"


uniform float4 evn_sph0;
uniform float4 evn_sph1;
uniform float4 evn_sph2;
uniform float4 evn_sph3;
uniform float4 evn_sph4;
uniform float4 evn_sph5;
uniform float4 evn_sph6;
uniform float4 evn_sph7;
uniform float4 evn_sph8;





float3 envsh9(float3 v)
{
	float3 result = (
		evn_sph0.xyz * Y0(v) +
		evn_sph1.xyz * Y1(v) +
		evn_sph2.xyz * Y2(v) +
		evn_sph3.xyz * Y3(v) +
		evn_sph4.xyz * Y4(v) +
		evn_sph5.xyz * Y5(v) +
		evn_sph6.xyz * Y6(v) +
		evn_sph7.xyz * Y7(v) +
		evn_sph8.xyz * Y8(v)
		);
	return max(result, float3(0, 0, 0));
}

#endif

uniform float4 FogInfo;
 
uniform float4 FogColor;
uniform float4 FogColor2;
uniform float4 HeightFogInfo;
uniform float fog_b;
 
uniform float height_fog_end_in_view;
uniform float height_fog_height_a;

uniform float4 FarSceneInfo;
uniform float4 FarSceneColor;

//uniform float back_dis_density ;
uniform float4 FogBackInfor;
float3 GetFog( in float4 PosWorld ,in float3 worldNormal){
 

float fog_b = FogInfo.x;
float fog_end_in_view = FogInfo.y;
float fog_dis_density = FogColor.w;


float env_b = FarSceneInfo.x;
float env_end_in_view = FarSceneInfo.y;
float env_dis_density = FarSceneColor.w;

//float back_b = BackLightInfo.x;
//float back_light_end_in_view = BackLightInfo.y;


float fog_height_density = HeightFogInfo.x;
float fog_hight_b = HeightFogInfo.z;

float fog_begin_in_height = FogInfo.w;
float fog_height = FogInfo.z;


float3 delta_pos = (PosWorld.xyz - _WorldSpaceCameraPos.xyz);

float fog_dis_height_val = length(delta_pos) / height_fog_end_in_view;



float begin = fog_begin_in_height + fog_height * fog_dis_height_val;
 
float world_height_val = smoothstep(begin, fog_begin_in_height, PosWorld.y);


float hdis = (fog_dis_height_val - 1)*height_fog_height_a + 1;


float _dis = length(delta_pos);
float2 dis_val = smoothstep(float2(0,0), float2(fog_end_in_view ,env_end_in_view), float2(_dis,_dis));
float2 dis_atten = pow(dis_val, float2(fog_b,env_b));


float fog_height_atten = pow(world_height_val, fog_hight_b)  * hdis;

 



float4 atten = 0;
#if _POW_FOG_ON
atten.z = dis_atten .x* fog_dis_density;
#endif

//back_dis_density
#if _HEIGHT_FOG_ON
atten.x = fog_height_atten* fog_height_density;
#endif
#if ENABLE_DISTANCE_ENV
atten.y = dis_atten.y * env_dis_density;


#endif

#if ENABLE_BACK_LIGHT

float nl0 = dot(worldNormal, -VirtualDirectSceneLight0.xyz);//[-1,1]

//float _power = dis_atten.z* back_dis_density*2;
float3 _power = FogBackInfor.xyz;
_power = _power*(nl0 - 1) + 1;
//_power = min(_power*(nl0 + _power), 2)*0.5;
atten.xyz *= _power;
//atten.y *= _power.y;
 
//atten.z *= _power.x;

#endif
return atten;

 
}

float4 global_fog_max;
 

float3 CustomFogBlend(in float3 vsFogFactor, in float3 screen_clr){
float3 fogFactor = vsFogFactor * vsFogFactor;
 
float3 blend_val = min(fogFactor, global_fog_max.xyz);

#if ENABLE_DISTANCE_ENV
screen_clr = lerp(screen_clr, FarSceneColor, blend_val.y); //lerp
#endif

#if _POW_FOG_ON
screen_clr = lerp(screen_clr, FogColor2.xyz, blend_val.z);
#endif

screen_clr = lerp(screen_clr, FogColor.xyz, blend_val.x); //lerp

return screen_clr;
}

uniform half color_density;

float globalEnvOffset;
 
 
#if ENABLE_NEW_FOG

	#define UNITY_FOG_COORDS_EX(idx) float3  fogCoord : TEXCOORD##idx; 
	#define UNITY_TRANSFER_FOG_EX(o,vertex,worldPos,worldNormal)\
		o.fogCoord = GetFog(worldPos,worldNormal);

	#define UNITY_APPLY_FOG_MOBILE(coord,col) \
	col.rgb = CustomFogBlend(coord,col.rgb);


	#if ENABLE_DISTANCE_ENV

	#if GLOBAL_ENV_SH9

	#define APPLY_HEIGHT_FOG(col,posWorld,normal,fogCoord)  ; \
		float3 __viewDir = -normalize(UnityWorldSpaceViewDir(posWorld));\
		__viewDir = lerp(__viewDir,float3(0,-1,0),globalEnvOffset);\
		FarSceneColor.xyz = envsh9(__viewDir)   ;

	#define APPLY_HEIGHT_FOG_EX(col,posWorld,env,fogCoord)  ; \
		FarSceneColor.xyz = env   ;

	#else

	#define APPLY_HEIGHT_FOG(col,posWorld,normal,fogCoord)  ; 
	#define APPLY_HEIGHT_FOG_EX(col,posWorld,env,fogCoord)  ; 
	#endif
	#else

	#define APPLY_HEIGHT_FOG(col,posWorld,normal,fogCoord)  ; 
	#define APPLY_HEIGHT_FOG_EX(col,posWorld,env,fogCoord)  ; 
	#endif

#else
	
	#define UNITY_FOG_COORDS_EX(idx) UNITY_FOG_COORDS(idx)
	#define UNITY_TRANSFER_FOG_EX(o,vertex,worldPos,worldNormal) UNITY_TRANSFER_FOG(o, vertex);


	#define APPLY_HEIGHT_FOG(col,posWorld,normal,fogCoord)  ; 
	#define APPLY_HEIGHT_FOG_EX(col,posWorld,env,fogCoord)  ;

#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
	#define UNITY_APPLY_FOG_MOBILE(coord,col)     ;
#else
	#define UNITY_APPLY_FOG_MOBILE(coord,col)     ;
#endif

	
#endif







 
