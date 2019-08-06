Shader "TA/T4MShaders/ShaderModel3/Diffuse/T4M 3 Textures" 
{
	Properties
	{
		_Splat0 ("Layer 1 (R)", 2D) = "white" {}
		_Splat1 ("Layer 2 (G)", 2D) = "white" {}
		_Splat2 ("Layer 3 (B)", 2D) = "white" {}
		_Control ("Control (RGBA)", 2D) = "white" {}
		_MainTex ("Never Used", 2D) = "white" {}
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
			#include "../height-fog.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc" //µÚÈý²½// 

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
				LIGHTING_COORDS(5,6)
#endif
				
				float4 wpos:TEXCOORD2;
				UNITY_FOG_COORDS_EX(3)
				float3 normalWorld : TEXCOORD4;
				
				float4 pos : SV_POSITION;
			};

			sampler2D _Control;
			sampler2D _Splat0,_Splat1,_Splat2;
			float4 _Splat0_ST,_Splat1_ST,_Splat2_ST;
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
				o.uv = v.uv;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
				TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif
				o.normalWorld = UnityObjectToWorldNormal(v.normal);
				
				UNITY_TRANSFER_FOG_EX(o, o.pos, o.wpos, o.normalWorld);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half3 splat_control = tex2D (_Control, i.uv);
				half3 col;

 
				half4 splat0 = tex2D (_Splat0, TRANSFORM_TEX(i.uv, _Splat0));
				half4 splat1 = tex2D (_Splat1, TRANSFORM_TEX(i.uv, _Splat1));
				half4 splat2 = tex2D (_Splat2, TRANSFORM_TEX(i.uv, _Splat2));
	
				col = splat_control.r * splat0.rgb;

				col += splat_control.g * splat1.rgb;
	
				col += splat_control.b * splat2.rgb;
				half4 c = half4(col.rgb,1);
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
				c.rgb *= lm;
#else
				
				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				half nl = saturate(dot(i.normalWorld, lightDir));
				c.rgb = UNITY_LIGHTMODEL_AMBIENT * c.rgb + _LightColor0 * nl * c.rgb* LIGHT_ATTENUATION(i); 
		 
#endif

#ifdef BRIGHTNESS_ON
				c.rgb = c.rgb * _Brightness * 2;
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