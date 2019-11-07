// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TA/SurfacePbr EX"
{
	Properties
	{
		[HideInInspector] __dirty("", Int) = 1
		_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_Metallic("Metallic", 2D) = "white" {}
		_SmoothnessPower("SmoothnessPower", Range(0 , 1)) = 1
		_MetallicPower("MetallicPower", Range(0 , 1)) = 1
	 
		[HideInInspector] _texcoord("", 2D) = "white" {}
	}

		SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma only_renderers d3d11 glcore gles gles3 metal d3d11_9x 


		#pragma   multi_compile  _  ENABLE_NEW_FOG
		#define   _HEIGHT_FOG_ON 1 // #pragma   multi_compile  _  _HEIGHT_FOG_ON
		#define   ENABLE_DISTANCE_ENV 1 // #pragma   multi_compile  _ ENABLE_DISTANCE_ENV

		#define _ISWEATHER_ON 1
		#pragma   multi_compile  _  GLOBAL_ENV_SH9
		#pragma multi_compile __ SNOW_ENABLE
		#pragma shader_feature HARD_SNOW
		#pragma shader_feature MELT_SNOW
		#pragma multi_compile __ RAIN_ENABLE

		//#include "surface-height-fog.cginc"
		#include "height-fog.cginc"
		#include "snow.cginc"
		#include "SceneWeather.inc" 
 
		//SurfaceOutputStandardSpecular ,StandardSpecular
		#pragma surface surf Standard  keepalpha addshadow fullforwardshadows  vertex:vertexDataFunc  nofog finalcolor:finalEffect
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 worldPos;
			float3 viewDir; 
			
			SURFACE_UNITY_FOG_PARAM
			INTERNAL_DATA
		
		};


		/*
		float3 viewDir - 视图方向 （view direction）。为了计算视差效果(Parallax effects)，边缘光照等
		float4 with COLOR semantic -每个顶点插值后的颜色
		float4 screenPos - 屏幕空间中的位置。 为了反射效果，需要包含屏幕空间中的位置信息。
		float3 worldPos - 世界空间中的位置。
		float3 worldRefl - 世界空间中的反射向量。 如果surface shader没有赋值o.Normal，将会包含世界反射向量。参见例子：Reflect-Diffuse shader。
		float3 worldNormal - 世界空间中的法线向量。如果surface shader没有赋值o.Normal，将会包含世界法向量
		float3 worldRefl; INTERNAL_DATA - 世界空间中的反射向量。如果surface shader没有赋值o.Normal，将会包含这个参数。为了获得逐像素法线贴图的反射向量，请使用WorldReflectionVector (IN, o.Normal)。参见例子： Reflect-Bumped shader。
		float3 worldNormal; INTERNAL_DATA -世界空间中的法线向量。如果surfac shader没有赋值o.Normal，将会包含世界法向量。为了获得逐像素法线贴图的法向量，请使用WorldNormalVector(IN, o.Normal)
		*/

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _Metallic;
		uniform float4 _Metallic_ST;
		uniform float _MetallicPower;
		uniform float _SmoothnessPower;
		uniform float3 _TestOffset;
		float snowT;
		void vertexDataFunc(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			float4 worldPos = float4(mul(unity_ObjectToWorld, v.vertex).xyz,1);
			float3 worldNormal = UnityObjectToWorldNormal(v.normal);
			o.fogCoord = GetFog(worldPos, worldNormal);
		 
			//o.fogCoord = GetFog(worldPos, worldNormal);
			//o.posWorld = worldPos;

		}


		void finalEffect(Input i, SurfaceOutputStandard o, inout fixed4 color) {
			//color = color;
			
#if _ISWEATHER_ON
#if SNOW_ENABLE
			color.rgb = lerp(color.rgb, _SnowColor.rgb, snowT);
 
#endif
#endif
		 
#if GLOBAL_ENV_SH9
			float3 l__viewDir = lerp(-i.viewDir, float3(0, -1, 0), globalEnvOffset);
			APPLY_HEIGHT_FOG_EX(color, i.worldPos, envsh9(l__viewDir), i.fogCoord);
#else
			APPLY_HEIGHT_FOG(color, i.worldPos, worldNormal, i.fogCoord);
#endif

			UNITY_APPLY_FOG_MOBILE(i.fogCoord, color);
	 
		}
		void surf(Input i , inout SurfaceOutputStandard o)
		{


			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 LocalNormal = UnpackNormal(tex2D(_Normal, uv_Normal));



			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			o.Albedo = tex2D(_Albedo, uv_Albedo).rgb;
			float2 uv_Metallic = i.uv_texcoord * _Metallic_ST.xy + _Metallic_ST.zw;
			float4 tex2DNode4 = tex2D(_Metallic, uv_Metallic);
			o.Emission = (o.Albedo * tex2DNode4.g);
			o.Metallic = (tex2DNode4.r * _MetallicPower);
			o.Smoothness = (tex2DNode4.a * _SmoothnessPower);

#if _ISWEATHER_ON

#if SNOW_ENABLE 
			fixed nt;
			float3 normalDirection = WorldNormalVector(i, LocalNormal);
			CmpSnowNormalAndPowerSurface(i.uv_texcoord, normalDirection, nt, LocalNormal);
			//o.Albedo = nt;
#endif
#endif
			

#if _ISWEATHER_ON
#if RAIN_ENABLE 
			float3 _BumpMap_var = LocalNormal;
			calc_weather_info_surface(i.worldPos.xyz, LocalNormal, _BumpMap_var, o.Albedo, LocalNormal, o.Albedo.rgb);
#endif
#endif
			o.Normal = LocalNormal;

#if _ISWEATHER_ON
#if RAIN_ENABLE
			o.Smoothness = saturate(o.Smoothness* get_smoothnessRate());
#endif
#if(SNOW_ENABLE)
			snowT = nt;
			o.Smoothness = lerp(o.Smoothness, _SnowGloss, nt);
#endif
#endif
			o.Occlusion = tex2DNode4.b;
			o.Alpha = 1;


		}

		ENDCG
	}
		Fallback "Diffuse"
			CustomEditor "ASEMaterialInspector"
}
 
 