Shader "TA/Cutout"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	    _CutAlpha ("CutAlpha", Range(0, 1)) = 0.5
	}

	SubShader
	{
		Tags { "Queue" = "AlphaTest" }
		Cull Off
		 
		Pass
		{
			Name "FORWARD"
			Tags {
				"LightMode" = "ForwardBase"
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			//#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON
			
			#pragma   multi_compile  _  ENABLE_NEW_FOG
			#pragma   multi_compile  _  _POW_FOG_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc" 
			#include "height-fog.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				float2 uv2 : TEXCOORD1;
#else

#endif
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				float2 uv2 : TEXCOORD1;
#else
				LIGHTING_COORDS(5, 6)
#endif
				UNITY_FOG_COORDS_EX(2)
				float4 wpos:TEXCOORD3;
				float3 normalWorld : TEXCOORD4;
				float4 pos : SV_POSITION;
			};

			sampler2D _MainTex;
			float _CutAlpha;

#ifdef BRIGHTNESS_ON
			fixed3 _Brightness;
#endif

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				float4 wpos = mul(unity_ObjectToWorld, v.vertex);
				o.wpos = wpos;
				o.uv = v.uv;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
				TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif
				o.normalWorld = UnityObjectToWorldNormal(v.normal);
				UNITY_TRANSFER_FOG_EX(o, o.pos,o.wpos, o.normalWorld);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				clip(c.a - _CutAlpha);

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));


#if defined(DIRLIGHTMAP_COMBINED) || defined(DIRLIGHTMAP_SEPARATE)
 
				//fixed3 dir = UNITY_SAMPLE_TEX2D(unity_LightmapInd, i.uv2);
				//dir.xyz * 2 - 1;
#endif
 
				c.rgb = UNITY_LIGHTMODEL_AMBIENT * c.rgb + c.rgb * lm;
#else

				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				half nl = saturate(dot(i.normalWorld, lightDir));
				//c.rgb = UNITY_LIGHTMODEL_AMBIENT * c.rgb + _LightColor0 * nl * c.rgb* LIGHT_ATTENUATION(i);
				c.rgb = UNITY_LIGHTMODEL_AMBIENT * c.rgb + _LightColor0 * nl * c.rgb* LIGHT_ATTENUATION(i);

#endif

#ifdef BRIGHTNESS_ON
				c.rgb = c.rgb * _Brightness * 2;
#endif
				APPLY_HEIGHT_FOG(c,i.wpos,i.normalWorld,i.fogCoord);
				UNITY_APPLY_FOG_MOBILE(i.fogCoord, c);
				return c;
			}
			ENDCG
		}



		Pass
		{
			Name "FORWARD_DELTA"
			Tags {
				"LightMode" = "ForwardAdd"
			}
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			//#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON

			#pragma   multi_compile  _  ENABLE_NEW_FOG
			#pragma   multi_compile  _  _POW_FOG_ON
			#pragma   multi_compile  _  _HEIGHT_FOG_ON
			#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
			#pragma   multi_compile  _ ENABLE_BACK_LIGHT
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc" 
			#include "height-fog.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				float2 uv2 : TEXCOORD1;
#else

#endif
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				float2 uv2 : TEXCOORD1;
#else
				LIGHTING_COORDS(5, 6)
#endif
				UNITY_FOG_COORDS_EX(2)
				float4 wpos:TEXCOORD3;
				float3 normalWorld : TEXCOORD4;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float _CutAlpha;

#ifdef BRIGHTNESS_ON
			fixed3 _Brightness;
#endif

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				float4 wpos = mul(unity_ObjectToWorld, v.vertex);
				o.wpos = wpos;
				o.uv = v.uv;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
				TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif
				o.normalWorld = UnityObjectToWorldNormal(v.normal);
				UNITY_TRANSFER_FOG_EX(o, o.vertex, o.wpos, o.normalWorld);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				clip(c.a - _CutAlpha);

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
				//c.rgb *= lm;
				c.rgb = UNITY_LIGHTMODEL_AMBIENT * c.rgb + c.rgb * lm;
#else

				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				half nl = saturate(dot(i.normalWorld, lightDir));
				c.rgb =  _LightColor0 * nl * c.rgb* LIGHT_ATTENUATION(i);

#endif

#ifdef BRIGHTNESS_ON
				c.rgb = c.rgb * _Brightness * 2;
#endif
				APPLY_HEIGHT_FOG(c,i.wpos,i.normalWorld,i.fogCoord);
				UNITY_APPLY_FOG_MOBILE(i.fogCoord, c);
				return c;
			}
			ENDCG
		}
		
	}
}