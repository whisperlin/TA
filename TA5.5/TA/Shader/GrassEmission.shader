// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "TA/Scene/GrassEmission"
{
	Properties
	{
		_MainTex("主贴图", 2D) = "white" {}
		_Color("颜色",Color) = (1,1,1,1)
		_SPColor("高光颜色",Color) = (1,1,1,1)
		_AlphaCut("半透明剔除",Range(0,1)) = 0.2
		_Wind("风向",Vector) = (1,0.5,0,0)
		_Speed("速度",Range(0,5)) = 2
		_Ctrl("空间各向差异",Range(0,3.14)) = 0
		_Gloss("高光",Range(0,1))=0.5
		_SPPower("高光强度",Range(0,2))=1
		
			
		//[Toggle(_DOUBLE_NL)] _DOUBLE_NL("双面同亮度", Float) = 1
		//[Toggle(PHONE_SP)] PHONE_SP("phone高光", Float) = 0
		[Toggle(_ALPHA_CLIP)] _ALPHA_CLIP("_ALPHA_CLIP高光", Float) = 1
		[KeywordEnum(Off,On)] _fadePhy("是否开启碰撞交互", Float) = 0
		_HitPower("碰撞强度",Range(1,100)) = 5
		_Emission("自发光",Range(0,3)) = 0.5
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
			#pragma multi_compile_fog
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			////#pragma   multi_compile  _  ENABLE_NEW_FOG
 
			#define   _HEIGHT_FOG_ON 1  
			#define   ENABLE_DISTANCE_ENV 1  
 
			#pragma   multi_compile  _  GLOBAL_ENV_SH9
			#pragma multi_compile _FADEPHY_OFF _FADEPHY_ON
			//#pragma   multi_compile  _ _DOUBLE_NL
			#define PHONE_SP 1
			//#pragma   multi_compile  _ PHONE_SP
			#pragma   multi_compile  _ _ALPHA_CLIP
			

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "FogCommon.cginc"
			#include "grass.cginc"


			float _Gloss;
			float4 _SPColor;
			float _SPPower;
			inline half UnityGGXTerm(half NdotH, half roughness)
			{
				half a2 = roughness * roughness;
				half d = (NdotH * a2 - NdotH) * NdotH + 1.0f; // 2 mad
				return UNITY_INV_PI * a2 / (d * d + 1e-7f); // This function is not intended to be running on Mobile,
														// therefore epsilon is smaller than what can be represented by half
			}
	 
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				c.rgb *= _Color.rgb;
				//float specular = 1;
				half3 normalDirection = normalize(i.normalWorld);
				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
 
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
				float g = dot(lm, float3(0.3, 0.6, 0.1));
				c.rgb *= lm *g ;
#endif
				c.rgb = (0.5 + _Emission) * c.rgb;
 
#if _ALPHA_CLIP
				clip(c.a - _AlphaCut);
#endif
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.wpos.xyz);
				float3 halfDirection = normalize(viewDirection + lightDir);
				///////// Gloss:
				float gloss = _Gloss;
				float specPow = exp2(gloss * 10 + 1.0);
				////// Specular:
				float NdotL = saturate(dot(normalDirection, lightDir));

				float3 specularColor =  _SPColor  *_SPPower*c.a *_LightColor0;
				float NdotH = saturate(dot(normalDirection, halfDirection));

#if PHONE_SP
				float3 specular =   pow(max(0, NdotH), specPow)*specularColor ;
#else
				float roughness = 1 - _Gloss;
				roughness = roughness* roughness;
 
				float normTerm = UnityGGXTerm(NdotH, roughness);

				float3 specular = specularColor *normTerm;
#endif
				c.rgb += specular;
				UBPA_APPLY_FOG(i, c);
				return c;
			}
			ENDCG
		}
	}


}