// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "TA/Scene/GrassSp"
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
		
			
		[Toggle(_DOUBLE_NL)] _DOUBLE_NL("双面同亮度", Float) = 1
		//[Toggle(PHONE_SP)] PHONE_SP("phone高光", Float) = 0
		[Toggle(_ALPHA_CLIP)] _ALPHA_CLIP("_ALPHA_CLIP高光", Float) = 1
		
		[KeywordEnum(Off,On)] _fadePhy("是否开启碰撞交互", Float) = 0
		_HitPower("碰撞强度",Range(1,100)) = 5
		[Toggle(_BAKEDARM)] _BAKEDARM("烘培时是否包含环境色", Float) = 0
		_LightMapPower("光照贴图亮度调整",Range(0,2)) = 1
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
			#pragma   multi_compile  _  FOG_LIGHT
			#pragma multi_compile _FADEPHY_OFF _FADEPHY_ON

			#pragma shader_feature  _BAKEDARM

			#pragma shader_feature _DOUBLE_NL
 
			#define PHONE_SP 1
			//#pragma shader_feature PHONE_SP
			#pragma shader_feature _ALPHA_CLIP
			

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "height-fog.cginc"
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
			float _LightMapPower;
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				c.rgb *= _Color.rgb;
				//float specular = 1;
				half3 normalDirection = normalize(i.normalWorld);
				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
 
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));

#if _BAKEDARM
				c.rgb *= lm * _LightMapPower;
#else
				c.rgb *= (lm*_LightMapPower + i.SH.rgb);
				//return float4(1, 1, 1, 1);
#endif
				
#else 

#if _DOUBLE_NL
				half nl = abs(dot(normalDirection, lightDir));
#else
				half nl = saturate(dot(normalDirection, lightDir));
#endif
				c.rgb = (i.SH.rgb + _LightColor0 * nl  ) * c.rgb;
#endif
				//return i.color;
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
				APPLY_HEIGHT_FOG(c,i.wpos, normalDirection,i.fogCoord);

				UNITY_APPLY_FOG_MOBILE(i.fogCoord, c);
				return c;
			}
			ENDCG
		}
	}

	Fallback 		"Legacy Shaders/Transparent/Cutout/Diffuse"
}