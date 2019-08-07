Shader "TA/Diffuse"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

			#pragma   multi_compile  _  ENABLE_NEW_FOG
			#pragma   multi_compile  _  _POW_FOG_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#pragma   multi_compile  _  GLOBAL_ENV_SH9
			#include "UnityCG.cginc"
			#include "height-fog.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc" //µÚÈý²½// 
			#include "bake.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				LIGHTMAP_UVS(0,1,2)
				
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
				UNITY_FOG_COORDS_EX(3)
				float3 normalWorld : TEXCOORD4;
				
				float4 pos : SV_POSITION;
			};

			sampler2D _MainTex;

#ifdef BRIGHTNESS_ON
			fixed3 _Brightness;
#endif

			v2f vert (appdata v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				float4 wpos = mul(unity_ObjectToWorld, v.vertex); 
				o.wpos = wpos;
				o.uv0 = v.uv0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				o.uv1 = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
				TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif
				o.normalWorld = UnityObjectToWorldNormal(v.normal);
				
				UNITY_TRANSFER_FOG_EX(o, o.pos, o.wpos, o.normalWorld);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv0);

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1));
				c.rgb *= lm;
#else
				
				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				half nl = saturate(dot(i.normalWorld, lightDir));
				c.rgb = UNITY_LIGHTMODEL_AMBIENT * c.rgb + _LightColor0 * nl * c.rgb* LIGHT_ATTENUATION(i); 
		 
#endif

#ifdef BRIGHTNESS_ON
				c.rgb = c.rgb * _Brightness * 2;
#endif


				
	#if ENABLE_DISTANCE_ENV

		#if GLOBAL_ENV_SH9
			//return float4(0,1,0,1);

		#else
			//return float4(0,0,1,1);
		#endif

	#endif
				APPLY_HEIGHT_FOG(c,i.wpos,i.normalWorld, i.fogCoord);
				UNITY_APPLY_FOG_MOBILE(i.fogCoord, c);
				return c;
			}
			ENDCG
		}
	}

	FallBack "Mobile/Diffuse"
}