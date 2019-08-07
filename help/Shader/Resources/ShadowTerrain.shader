Shader "YuLongZhi/ShadowTerrain" {
	Properties {
		_Splat0 ("Layer 1", 2D) = "white" {}
		_Splat1 ("Layer 2", 2D) = "white" {}
		_Splat2 ("Layer 3", 2D) = "white" {}
		_Splat3 ("Layer 4", 2D) = "white" {}
		_Tiling3 ("_Tiling4 x/y", Vector) = (1, 1, 0, 0)
		_Control ("Control (RGBA)", 2D) = "white" {}
		_Shadow ("Shadow", 2D) = "black" {}
		_ShadowFade ("ShadowFade", 2D) = "black" {}
		_ShadowStrength ("ShadowStrength", Range(0, 1)) = 1
	}

	SubShader {
		Tags {
		   "RenderType" = "Opaque"
		}

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma multi_compile __ SHADOW_ON
			#pragma multi_compile __ BRIGHTNESS_ON

			#include "UnityCG.cginc"

			struct v2f {
				float4 pos : SV_POSITION;
				float4 pack0 : TEXCOORD0; // _Control _Splat0
				float4 pack1 : TEXCOORD1; // _Splat1 _Splat2
				float4 pack2 : TEXCOORD2;
				UNITY_FOG_COORDS(3)
			};

			sampler2D _Control;
			sampler2D _Splat0, _Splat1, _Splat2, _Splat3;
			float4 _Control_ST;
			float4 _Splat0_ST;
			float4 _Splat1_ST;
			float4 _Splat2_ST;
			float4 _Tiling3;

#ifdef SHADOW_ON
			sampler2D _Shadow, _ShadowFade;
			float4x4 shadow_projector;
			float _ShadowStrength;
			float4 _Shadow_TexelSize;
#endif

#ifdef BRIGHTNESS_ON
			fixed3 _Brightness;
#endif

			v2f vert (appdata_full v) {
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pack0.xy = TRANSFORM_TEX(v.texcoord, _Control);
				o.pack0.zw = TRANSFORM_TEX(v.texcoord, _Splat0);
				o.pack1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
				o.pack1.zw = TRANSFORM_TEX(v.texcoord, _Splat2);
				o.pack2.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				UNITY_TRANSFER_FOG(o,o.pos);

#ifdef SHADOW_ON
				float4 shadow_uv = mul(shadow_projector, mul(unity_ObjectToWorld, v.vertex));
				o.pack2.zw = (shadow_uv.xy / shadow_uv.w + float2(1, 1)) * 0.5;
#endif

				return o;
			}

			fixed4 frag (v2f IN) : SV_Target {
				float2 uv_Control = IN.pack0.xy;
				float2 uv_Splat0 = IN.pack0.zw;
				float2 uv_Splat1 = IN.pack1.xy;
				float2 uv_Splat2 = IN.pack1.zw;

				fixed4 c = 0;
				fixed4 splat_control = tex2D(_Control, uv_Control).rgba;

				fixed3 lay1 = tex2D(_Splat0, uv_Splat0);
				fixed3 lay2 = tex2D(_Splat1, uv_Splat1);
				fixed3 lay3 = tex2D(_Splat2, uv_Splat2);
				fixed3 lay4 = tex2D(_Splat3, uv_Control * _Tiling3.xy);
				c.a = 1.0;
				c.rgb = (lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a);

				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.pack2.xy));
				c.rgb *= lm;

#ifdef SHADOW_ON
				fixed shadow = 0;
				for(fixed i = -0.5; i <= 0.5; i += 1) {
					for(fixed j = -0.5; j <= 0.5; j += 1) {
						shadow += tex2D(_Shadow, IN.pack2.zw + _Shadow_TexelSize.xy * float2(i, j)).r;
					}
				}
				shadow /= 4;

				fixed fade = tex2D(_ShadowFade, IN.pack2.zw).r;
				shadow *= fade * _ShadowStrength;
				c.rgb = fixed3(0, 0, 0) * shadow + c.rgb * (1 - shadow);
#endif

#ifdef BRIGHTNESS_ON
				c.rgb = c.rgb * _Brightness * 2;
#endif

				// apply fog
				UNITY_APPLY_FOG(IN.fogCoord, c);
				return c;
			}
			ENDCG 
		}
	}
}
