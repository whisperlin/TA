 
Shader "Editor/RenderShadowMap"
{
	Properties
	{
 
	}

		SubShader
	{
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma   multi_compile  _  COMBINE_SHADOWMARK

			#include "UnityCG.cginc"
 
			#include "Lighting.cginc"
			#include "AutoLight.cginc" //第三步// 
 

 

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv0 : TEXCOORD0; 
			float2 uv1 : TEXCOORD1;
			float3 normal : NORMAL;
 
		};

		struct v2f
		{
			float2 uv0 : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				float2 uv1 : TEXCOORD1;
#else
				LIGHTING_COORDS(5,6)
#endif

				float4 wpos:TEXCOORD2;
 
				float3 normalWorld : TEXCOORD4;
				float3 sh : TEXCOORD10;
				float4 pos : SV_POSITION;
			};
 

#ifdef BRIGHTNESS_ON
			fixed3 _Brightness;
#endif

			#define UNITY_SAMPLE_TEX2D(tex,coord) tex.Sample (sampler##tex,coord)

			#include "UnityGlobalIllumination.cginc"
			fixed UnitySampleBakedOcclusion2(float2 lightmapUV, float3 worldPos)
			{

				half bakedAtten = UnitySampleBakedOcclusion(lightmapUV.xy, worldPos);
				//return bakedAtten;
				float zDist = dot(_WorldSpaceCameraPos - worldPos, UNITY_MATRIX_V[2].xyz);
				float fadeDist = UnityComputeShadowFadeDistance(worldPos, zDist);
				float shadowFade = UnityComputeShadowFade(fadeDist);

				return bakedAtten;

			}
			v2f vert(appdata v)
			{


				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);

 
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
 
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
 

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)

			fixed3 lightmap = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1)); 
		 
			#if    SHADOWS_SHADOWMASK 
				float attenuation = UNITY_SAMPLE_TEX2D(unity_ShadowMask, i.uv1).r;
				return attenuation.rrrr;
			#else
				float attenuation = saturate(dot(lightmap, float3(0.3, 0.6, 0.1))); attenuation = attenuation * attenuation; attenuation = attenuation * attenuation;
				return attenuation.rrrr;
			#endif
#else
			return float4(LIGHT_ATTENUATION(i).rrr,1);
#endif
  
			}
			ENDCG
		}


		 
	}

		FallBack "Mobile/Diffuse"
}