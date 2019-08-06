// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "TA/Scene/TreeSoft"
{
	Properties
	{
		_MainTex ("主贴图", 2D) = "white" {}
		_Color("颜色",Color) = (1,1,1,1)
		_AlphaCut("半透明剔除",Range(0,1))=0.2
		_Wind("风向",Vector) = (1,0.5,0,0)
		_Speed("速度",Range(0,5)) = 2
		_Ctrl("空间各向差异",Range(0,3.14)) = 0

		_Emission("自发光",Range(0,3)) = 0.5 
		_EmissionTex("自发光控制图",2D)  = "white" {}
	}

	SubShader
	{
		Tags{ "Queue" = "AlphaTest" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
		Cull  Off
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
		#pragma   multi_compile  _  ENABLE_NEW_FOG
			#pragma   multi_compile  _  _POW_FOG_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#pragma   multi_compile  _  GLOBAL_ENV_SH9
			#pragma multi_compile _FADEPHY_OFF _FADEPHY_ON

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "height-fog.cginc"
			#include "grass.cginc"
			
			 

			
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				c.rgb *= _Color.rgb;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				fixed4 e = tex2D(_EmissionTex, i.uv);
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
				c.rgb *= lm  + _Emission*e.r;
#else
				fixed4 e = tex2D(_EmissionTex, i.uv);
				
				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
			 
				half nl = saturate(dot(i.normalWorld, lightDir)) + saturate(dot(i.normalWorld, -lightDir)) ;
				c.rgb = ( UNITY_LIGHTMODEL_AMBIENT + _LightColor0 * nl + _Emission*e.r) * c.rgb;
#endif
				//return i.color;
				clip(c.a - _AlphaCut);
				APPLY_HEIGHT_FOG(c,i.wpos,i.normalWorld,i.fogCoord);
				
				UNITY_APPLY_FOG_MOBILE(i.fogCoord, c);
				return c;
			}
			ENDCG
		}
	}
}