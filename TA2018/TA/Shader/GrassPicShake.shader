
//#define _NEW_SHAKE 1

 
Shader "TA/Scene/草(不烘培，颜色采贴图)"
{
	Properties
	{
		_MainTex("主贴图", 2D) = "white" {}
		_Color("颜色",Color) = (1,1,1,1)
		_Power("亮度",Range(0,3)) = 1
		_AlphaCut("半透明剔除",Range(0,1)) = 0.2
		//_Wind("风向",Vector) = (1,0.5,0,0)
		//_Speed("速度",Range(0,5)) = 2
		//_Ctrl("空间各向差异",Range(0,3.14)) = 0

		 

		//_ColorVariation("ColorVariation", Range(0 , 0.2)) = 0.05
		//_AmbientOcclusion("AmbientOcclusion", Range(0 , 1)) = 0
		//_TransmissionSize("Transmission Size", Range(0 , 20)) = 1
		//_TransmissionAmount("Transmission Amount", Range(0 , 10)) = 2.696819
		_MaxWindStrength("Max Wind Strength", Range(0 , 1)) = 0.126967
		_WindSwinging("WindSwinging", Range(0 , 1)) = 0.25
		_WindAmplitudeMultiplier("WindAmplitudeMultiplier", Float) = 1
		_HeightmapInfluence("HeightmapInfluence", Range(0 , 1)) = 0
		_MinHeight("MinHeight", Range(-1 , 0)) = -0.5
		_MaxHeight("MaxHeight", Range(-1 , 1)) = 0
		_BendingInfluence("BendingInfluence", Range(0 , 1)) = 0
		_PigmentMapInfluence("PigmentMapInfluence", Range(0 , 1)) = 0
		_PigmentMapHeight("PigmentMapHeight", Range(0 , 1)) = 0
		_BendingTint("BendingTint", Range(-0.1 , 0.1)) = -0.05
		[KeywordEnum(Off,On)] _fadePhy("是否开启碰撞交互", Float) = 0
		[Toggle(_GRAY_COLOR)] _GRAY_COLOR("主纹理灰度", Float) = 1
		[Toggle(_GRAY_SCENE)] _GRAY_SCENE("场景图只读阴影", Float) = 0
		_MaxWindStrength("最大风强度",Range(0,2)) = 0.5
		ShakeSpeed("摇动速度",Range(0,2)) =1.5
		ShakeCtrl("摇动控制",Range(0,5)) = 0.2
			
 
	}

		SubShader
		{
			Tags{ "Queue" = "AlphaTest+40" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
			Cull  Off
			Pass
			{
				Tags{ "LightMode" = "ForwardBase" }


				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase

				#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
				#pragma   multi_compile  _  GLOBAL_SH9
				#pragma multi_compile _FADEPHY_OFF _FADEPHY_ON
				#pragma   multi_compile  _  GRASS_SHADOW GRASS_SHADOW2
				#pragma   multi_compile  _ _GRAY_COLOR
				#pragma   multi_compile  _ _GRAY_SCENE
				#define _NEW_SHAKE 1
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "FogCommon.cginc"
				#include "grass.cginc"

				 

			float4 LightMapInf;
		float _Power;

		fixed4 frag(v2f i) : SV_Target
		{
			
			fixed4 c = tex2D(_MainTex, i.uv);
			#if _GRAY_COLOR
				c.rgb = c.ggg;
			#endif


			c.rgb *= _Color.rgb;

			half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
#if GRASS_SHADOW
				half3 nl = PCFSamplesTexture(i.shadowCoord).r;
#elif GRASS_SHADOW2
			#if _GRAY_SCENE
				half3 nl = tex2D(grass_kkSceneColor, i.shadowCoord.xy).aaa;
 
			#else
				half3 nl = tex2D(grass_kkSceneColor, i.shadowCoord.xy).rgb*_Power;

			#endif

	#else
					half nl = 1;
	#endif
 
	 #if _GRAY_SCENE
				c.rgb = (i.SH + _LightColor0 * nl *0.5) * c.rgb  *_Power;
 #else
				 
				c.rgb = (i.SH + _LightColor0 /*+ _Emission*e.b*/) * c.rgb * nl;
				
				
 #endif
				 
#if _NEW_SHAKE
				//return float4(1, 0, 0, 1);
#endif
				clip(c.a - _AlphaCut);
				UBPA_APPLY_FOG(i, c);
				return c;
			}
			ENDCG
		}
		}
}
