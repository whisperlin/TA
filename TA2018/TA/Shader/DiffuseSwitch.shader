
Shader "TA/Scene/DiffuseSwitch"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MainTex2("Texture", 2D) = "white" {}
		_T("T",Range(0,1)) = 0
		[MaterialToggle(EMISSSION)] EMISSSION("自发光", Float) = 0
		[HDR]_EmissionColor("自发光色",Color) = (0,0,0,0)
		_EmissionMark("Texture", 2D) = "white" {}
	}

		SubShader
		{
			Pass
			{
				Tags{ "LightMode" = "ForwardBase" }

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
 
				#pragma multi_compile __ BRIGHTNESS_ON
				#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
				#pragma   multi_compile  _  EMISSSION
				#pragma   multi_compile  _  COMBINE_SHADOWMARK
				#include "UnityCG.cginc"
				#include "FogCommon.cginc"
				#include "Lighting.cginc"
				#include "AutoLight.cginc" //第三步// 
				#include "bake.cginc"
				#pragma multi_compile_instancing
				#include "shadowmarkex.cginc"


			half4 _EmissionColor;
 

			struct appdata
			{
				float4 vertex : POSITION;
				LIGHTMAP_UVS(0,1,2)
				
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv0 : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				float2 uv1 : TEXCOORD1;
#else
				UNITY_LIGHTING_COORDS(5,6)
#endif
				
				float4 wpos:TEXCOORD2;
				UBPA_FOG_COORDS(3)
				float3 normalWorld : TEXCOORD4;
				float3 sh : TEXCOORD10;
				float4 pos : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			sampler2D _MainTex;
			sampler2D _MainTex2;
			float _T;
			sampler2D _EmissionMark;
 
#ifdef BRIGHTNESS_ON
			fixed3 _Brightness;
#endif

			#define UNITY_SAMPLE_TEX2D(tex,coord) tex.Sample (sampler##tex,coord)

			#include "UnityGlobalIllumination.cginc"
			fixed UnitySampleBakedOcclusion2(float2 lightmapUV, float3 worldPos )
			{

				half bakedAtten = UnitySampleBakedOcclusion(lightmapUV.xy, worldPos);
				//return bakedAtten;
				float zDist = dot(_WorldSpaceCameraPos - worldPos, UNITY_MATRIX_V[2].xyz);
				float fadeDist = UnityComputeShadowFadeDistance(worldPos, zDist);
				float shadowFade = UnityComputeShadowFade(fadeDist);
			 
				return bakedAtten;
 
			}
			v2f vert (appdata v)
			{


				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);


#if COMBINE_SHADOWMARK
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
#endif
				o.pos = UnityObjectToClipPos(v.vertex);
				float4 wpos = mul(unity_ObjectToWorld, v.vertex); 
				o.wpos = wpos;
				o.uv0 = v.uv0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				o.uv1 = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
				TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif
				o.normalWorld = UnityObjectToWorldNormal(v.normal);
				
				o.sh = ShadeSH9(half4(o.normalWorld, 1));
				UBPA_TRANSFER_FOG(o, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 baseColor = tex2D(_MainTex, i.uv0);
				fixed4 baseColor1 = tex2D(_MainTex2, i.uv0);
				
				fixed4 c = lerp(baseColor , baseColor1,_T) ;

 
#if COMBINE_SHADOWMARK
				UNITY_SETUP_INSTANCE_ID(i);
#endif

 
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
			GETLIGHTMAP(i.uv1);
			lightmap.rgb *= LightMapInf.rgb *(1 + LightMapInf.a);//
	#if    SHADOWS_SHADOWMASK 
			
			half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
			half nl = saturate(dot(i.normalWorld, lightDir));
			_LightColor0.rgb *= attenuation;
			//_LightColor0.rgb *= attenuation;
		
			c.rgb =   _LightColor0 * nl * c.rgb + lightmap * c.rgb;
	#else
			c.rgb *= lightmap;
			 
	#endif
#else
				
				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				half nl = saturate(dot(i.normalWorld, lightDir));
				UNITY_LIGHT_ATTENUATION(attenuation, i, i.wpos);
				c.rgb = (i.sh  + _LightColor0 * nl  * attenuation)* c.rgb;
		 
#if EMISSSION
				fixed4 _emark = tex2D(_EmissionMark, i.uv0);
				
				c.rgb += _EmissionColor.rgb * baseColor.rgb*_emark.rgb;
#endif
				
#endif

#ifdef BRIGHTNESS_ON
				c.rgb = c.rgb * _Brightness * 2;
#endif

 
				UBPA_APPLY_FOG(i, c);
				return c;
			}
			ENDCG
		}


		 
	}

	 
}