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
		
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			////#pragma   multi_compile  _  ENABLE_NEW_FOG

 
 
			#define   _HEIGHT_FOG_ON 1  
			#define   ENABLE_DISTANCE_ENV 1  
 
			#pragma   multi_compile  _  GLOBAL_ENV_SH9
			#pragma multi_compile _FADEPHY_OFF _FADEPHY_ON
			#pragma   multi_compile  _ _DOUBLE_NL
			#define PHONE_SP 1
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
			float4 GlobalTotalColor;
			float _LightMapPower;
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				c.rgb *= _Color.rgb;
				//float specular = 1;
				half3 normalDirection = normalize(i.normalWorld);
				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				clip(c.a - _AlphaCut);
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON) 
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));

				c.rgb *= lm * _LightMapPower;
 
#else 
				fixed3 lm = 1;
#if _DOUBLE_NL
				half nl = abs(dot(normalDirection, lightDir));
#else
				half nl = saturate(dot(normalDirection, lightDir));
#endif
				c.rgb = (i.SH.rgb + _LightColor0 * nl  ) * c.rgb;
#endif
				//return float4(i.SH,1);
				//return i.color;
#if _ALPHA_CLIP
				
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
				float lm0 = min(min(lm.r, lm.g), lm.b);
				lm0 = lm0 * lm0*lm0;
				c.rgb += specular* lm0;
				c.rgb *= GlobalTotalColor.rgb;

				UBPA_APPLY_FOG(i, c);
				//return float4(1, 0, 0, 1);
				return c;
			}
			ENDCG
		}

		/*Pass{
			Name "Meta"
			Tags {
				"LightMode" = "Meta"
			}
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define UNITY_PASS_META 1
			#define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
			#define _GLOSSYENV 1
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			#include "UnityStandardBRDF.cginc"
			#include "UnityMetaPass.cginc"
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile_shadowcaster
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
			#pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fog
			#pragma only_renderers d3d9 d3d11 glcore gles 
			#pragma target 3.0
			uniform float4 _Color;
			uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
			uniform float _MetallicPower;
			uniform float _GlossPower;
			uniform sampler2D _Metallic; uniform float4 _Metallic_ST;
			struct VertexInput {
				float4 vertex : POSITION;
				float2 texcoord0 : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float2 texcoord2 : TEXCOORD2;
			};
			struct VertexOutput {
				float4 pos : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				float4 posWorld : TEXCOORD3;
			};
			VertexOutput vert(VertexInput v) {
				VertexOutput o = (VertexOutput)0;
				o.uv0 = v.texcoord0;
				o.uv1 = v.texcoord1;
				o.uv2 = v.texcoord2;
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST);
				return o;
			}
			float4 frag(VertexOutput i) : SV_Target {
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				UnityMetaInput o;
				UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);
				fixed4 c = tex2D(_MainTex, i.uv0);
				float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
				float3 node_6343 = (_MainTex_var.rgb*_Color.rgb);
				float4 _Metallic_var = tex2D(_Metallic,TRANSFORM_TEX(i.uv0, _Metallic));
				o.Emission = (node_6343*_Metallic_var.g);

				float3 diffColor = node_6343;
				float specularMonochrome;
				float3 specColor;
				diffColor = DiffuseAndSpecularFromMetallic(diffColor, (_Metallic_var.r*_MetallicPower), specColor, specularMonochrome);
				float roughness = 1.0 - (_Metallic_var.a*_GlossPower);
				//o.Albedo = float4(0,0,1,1);
				o.Albedo = diffColor;
				o.Emission = float4(0.5, 0.5, 0.5, 1);
				return UnityMetaFragment(o);
			}
			ENDCG
		}*/
	}


}