

//#define ENABLE_DISTANCE_ENV 1

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

 fixed4 farSceneColor;
 #if _HEIGHT_FOG_ON
 half heightFogHeight;
 half heightFogHeight2;

 #endif

 uniform half env_density;
 uniform half height_density;
 uniform half color_density;

 ///float unityFogFactor = unity_FogParams.x * (coord); unityFogFactor = exp2(-unityFogFactor*unityFogFactor)
 //距离衰减.
#define UNITY_CALC_ENV_FACTOR_RAW(coord) half4 unityEnvFactor = half4(unity_FogParams.x,color_density,height_density,env_density) * (coord); unityEnvFactor = exp2(-unityEnvFactor*unityEnvFactor)
 

 
#define UNITY_FOG_COORDS_EX(idx) float4  fogCoord : TEXCOORD##idx; 


#define UNITY_TRANSFER_FOG_EX(o,outpos) \
	float ta_lineNear01 =  UNITY_Z_0_FAR_FROM_CLIPSPACE((outpos).z);\
	UNITY_CALC_ENV_FACTOR_RAW(ta_lineNear01);\
	o.fogCoord.xyzw = unityEnvFactor.xyzw;

 

float globalEnvOffset;
#if ENABLE_DISTANCE_ENV
	//return float4(1,0,0,1);\
	//half __gray = dot(c.rgb,half3(0.3,0.6,0.1));\

	#if GLOBAL_ENV_SH9
		#define APPLY_ENV_DISTANCE(c,posWorld,normal,fogCoord)\
		float3 __viewDir = -normalize(UnityWorldSpaceViewDir(posWorld));\
		__viewDir = lerp(__viewDir,float3(0,-1,0),globalEnvOffset);\
		fixed3 __baseSkyColor = envsh9(__viewDir)   ;\
		c.rgb = lerp(c.rgb , __baseSkyColor  ,(1-saturate(fogCoord.w))*farSceneColor.a) ; 

		#define APPLY_ENV_DISTANCE_EX(c,posWorld,env,fogCoord)\
		c.rgb = lerp(c.rgb ,env,(1-saturate(fogCoord.w))*farSceneColor.a) ; 

	#else
		#define APPLY_ENV_DISTANCE(c,posWorld,normal,fogCoord)\
		c.rgb = lerp(c.rgb ,farSceneColor.rgb,(1-saturate(fogCoord.w))*farSceneColor.a) ;

		#define APPLY_ENV_DISTANCE_EX(c,posWorld,env,fogCoord)  APPLY_ENV_DISTANCE(c,posWorld,normal,fogCoord)
	#endif
	
#else
	#define APPLY_ENV_DISTANCE(c,posWorld,normal,fogCoord)
	#define APPLY_ENV_DISTANCE_EX(c,posWorld,env,fogCoord)

	
#endif

#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
    #define UNITY_APPLY_FOG_COLOR_MOBILE(coord,col,fogCol) UNITY_FOG_LERP_COLOR(col,fogCol,(coord).x)
#else
    #define UNITY_APPLY_FOG_COLOR_MOBILE(coord,col,fogCol)
#endif

#ifdef UNITY_PASS_FORWARDADD
    #define UNITY_APPLY_FOG_MOBILE(coord,col) UNITY_APPLY_FOG_COLOR_MOBILE(coord,col,fixed4(0,0,0,0))
#else
    #define UNITY_APPLY_FOG_MOBILE(coord,col) UNITY_APPLY_FOG_COLOR_MOBILE(coord,col,unity_FogColor)
#endif

half fog_height_power;
#ifdef _HEIGHT_FOG_ON
	#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
		#define APPLY_HEIGHT_FOG_COL(c,posWorld,fogCoord)\
			float fogCoord0 =   smoothstep(heightFogHeight,heightFogHeight+heightFogHeight2*(1-fogCoord.z), posWorld.y/posWorld.w);\
			fogCoord0 = pow(fogCoord0,fog_height_power );\
			unity_FogColor.rgb = lerp(unity_FogColor.rgb,c.rgb,fogCoord0  );
		#define APPLY_HEIGHT_FOG(c,posWorld,normal,fogCoord)\
			APPLY_ENV_DISTANCE(c,posWorld,normal,fogCoord)\
			APPLY_HEIGHT_FOG_COL(c,posWorld,fogCoord)

		#define APPLY_HEIGHT_FOG_EX(c,posWorld,env,fogCoord) \
			APPLY_ENV_DISTANCE_EX(c,posWorld,env,fogCoord)\
			APPLY_HEIGHT_FOG_COL(c,posWorld,fogCoord)
	#else
 
		#define APPLY_HEIGHT_FOG(c,posWorld,normal,fogCoord) APPLY_ENV_DISTANCE(c,posWorld,normal,fogCoord) 
		#define APPLY_HEIGHT_FOG_EX(c,posWorld,env,fogCoord)  APPLY_ENV_DISTANCE_EX(c,posWorld,env,fogCoord)
	#endif

#else

 
	#define APPLY_HEIGHT_FOG(c,posWorld,normal,fogCoord) APPLY_ENV_DISTANCE(c,posWorld,normal,fogCoord) 
	#define APPLY_HEIGHT_FOG_EX(c,posWorld,env,fogCoord)  APPLY_ENV_DISTANCE_EX(c,posWorld,env,fogCoord)
		 
	
		
#endif


