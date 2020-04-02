// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TA/T4M/4Texture Standard SF"
{
	Properties
	{
		[HideInInspector] __dirty("", Int) = 1
		_Color("Color", Color) = (0.5019608,0.5019608,0.5019608,0.003921569)
		_Splat0("Splat0", 2D) = "white" {}
		_Splat1("Splat1", 2D) = "white" {}
		_Splat2("Splat2", 2D) = "white" {}
		_Splat3("Splat3", 2D) = "white" {}
		_BumpSplat0("BumpSplat0", 2D) = "bump" {}
		_BumpSplat1("BumpSplat1", 2D) = "bump" {}
		_BumpSplat2("BumpSplat2", 2D) = "bump" {}
		_BumpSplat3("BumpSplat3", 2D) = "bump" {}
		_Glossiness("Glossiness", Range(0 , 1)) = 0.8
		_Control("Control", 2D) = "white" {}
		[HideInInspector] _texcoord("", 2D) = "white" {}

		[Toggle]_snow_options("----------雪选项-----------",int) = 0
		_SnowNormalPower("  雪法线强度", Range(0.3, 1)) = 1
		//_SnowColor("雪颜色", Color) = (0.784, 0.843, 1, 1)
		_SnowEdge("  雪边缘过渡", Range(0.01, 0.3)) = 0.2
		//_SnowNoise("雪噪点", 2D) = "white" {}
		_SnowNoiseScale("  雪噪点缩放", Range(0.1, 20)) = 1.28
		//_SnowGloss("雪高光", Range(0, 1)) = 1
		//_SnowMeltPower("  雪_消融影响调节", Range(1, 2)) =  1
		_SnowLocalPower("  雪_法线影响调节", Range(-5, 0.3)) = 0
		[MaterialToggle] HARD_SNOW("硬边雪", Float) = 0
		[MaterialToggle] MELT_SNOW("消融雪", Float) = 0
	}

		SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#pragma target 3.0
		#define _ISWEATHER_ON 1
		#pragma multi_compile __ SNOW_ENABLE
		#pragma multi_compile __ RAIN_ENABLE
		#define USER_DATA 
 

		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"

		
		#include "common_vf.cginc"
		#include "UnityStandardBRDFMod.cginc"

			
		#pragma skip_variants   FOG_LINEAR FOG_EXP FOG_EXP2  VERTEXLIGHT_ON
		#pragma skip_variants   FVERTEXLIGHT_ON

		

		

		uniform sampler2D _BumpSplat0;
		uniform float4 _BumpSplat0_ST;
		uniform sampler2D _Control;
		uniform float4 _Control_ST;
		uniform sampler2D _BumpSplat1;
		uniform float4 _BumpSplat1_ST;
		uniform sampler2D _BumpSplat2;
		uniform float4 _BumpSplat2_ST;
		uniform sampler2D _BumpSplat3;
		uniform float4 _BumpSplat3_ST;
		uniform sampler2D _Splat0;
		uniform float4 _Splat0_ST;
		uniform sampler2D _Splat1;
		uniform float4 _Splat1_ST;
		uniform sampler2D _Splat2;
		uniform float4 _Splat2_ST;
		uniform sampler2D _Splat3;
		uniform float4 _Splat3_ST;
		uniform float4 _Color;
		uniform float _Glossiness;
		
		
		void vert_fun(inout appdata_full v, out Input data)
		{
			UNITY_INITIALIZE_OUTPUT(Input, data);
			common_vert(  v,   data);
			//data.mycolor = float4(1, 0, 0, 1);
		}
		void fogex(Input data, SurfaceOutputStandard o, inout fixed4 color)
		{
			common_final(data, o, color);
			//color *= data.mycolor;
		}
		void surf(Input i , inout SurfaceOutputStandard o)
		{
			float2 uv_BumpSplat0 = i.uv_texcoord * _BumpSplat0_ST.xy + _BumpSplat0_ST.zw;
			float2 uv_Control = i.uv_texcoord * _Control_ST.xy + _Control_ST.zw;
			float4 _ctrlVal = tex2D(_Control, uv_Control);
			float2 uv_BumpSplat1 = i.uv_texcoord * _BumpSplat1_ST.xy + _BumpSplat1_ST.zw;
			float2 uv_BumpSplat2 = i.uv_texcoord * _BumpSplat2_ST.xy + _BumpSplat2_ST.zw;
			float2 uv_BumpSplat3 = i.uv_texcoord * _BumpSplat3_ST.xy + _BumpSplat3_ST.zw;
			float3 normalizeResult31 = normalize(((UnpackNormal(tex2D(_BumpSplat0, uv_BumpSplat0)) * _ctrlVal.r) + (UnpackNormal(tex2D(_BumpSplat1, uv_BumpSplat1)) * _ctrlVal.g) + (UnpackNormal(tex2D(_BumpSplat2, uv_BumpSplat2)) * _ctrlVal.b) + (UnpackNormal(tex2D(_BumpSplat3, uv_BumpSplat3)) * _ctrlVal.a)));



			o.Normal = normalizeResult31;
			float2 uv_Splat0 = i.uv_texcoord * _Splat0_ST.xy + _Splat0_ST.zw;
			float4 _Splat0Var = tex2D(_Splat0, uv_Splat0);
			float2 uv_Splat1 = i.uv_texcoord * _Splat1_ST.xy + _Splat1_ST.zw;
			float4 _Splat1Var = tex2D(_Splat1, uv_Splat1);
			float2 uv_Splat2 = i.uv_texcoord * _Splat2_ST.xy + _Splat2_ST.zw;
			float4 _Splat2Var = tex2D(_Splat2, uv_Splat2);
			float2 uv_Splat3 = i.uv_texcoord * _Splat3_ST.xy + _Splat3_ST.zw;
			float4 _Splat3Var = tex2D(_Splat3, uv_Splat3);
			o.Albedo = (((_Splat0Var * _ctrlVal.r) + (_Splat1Var * _ctrlVal.g) + (_Splat2Var * _ctrlVal.b) + (_Splat3Var * _ctrlVal.a)) * _Color).rgb;
			o.Metallic = 0.0;
			o.Smoothness = (((_Splat0Var.a * _ctrlVal.r) + (_Splat1Var.a * _ctrlVal.g) + (_Splat2Var.a * _ctrlVal.b) + (_Splat3Var.a * _ctrlVal.a)) * _Glossiness);

			common_surf(i, o);

		 
			o.Metallic = 0.0;
			o.Alpha = 1;
		}

		 
		ENDCG
		CGPROGRAM
		#pragma surface surf StandardExGI keepalpha fullforwardshadows  nodirlightmap  nofog nodynlightmap novertexlights finalcolor:fogex vertex:vert_fun

		ENDCG

	}
		Fallback "Diffuse"
			CustomEditor "ASEMaterialInspector"
}
