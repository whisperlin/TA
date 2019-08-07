Shader "YuLongZhi/ShadowTransparent"
{
	Properties
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Shadow ("Shadow", 2D) = "black" {}
		_ShadowFade ("ShadowFade", 2D) = "black" {}
		_ShadowStrength ("ShadowStrength", Range(0, 1)) = 1
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" }
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		Offset -1, -1

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				UNITY_FOG_COORDS(2)
				float4 vertex : SV_POSITION;
				float2 shadow_uv : TEXCOORD3;
			};

			sampler2D _MainTex;
			sampler2D _Shadow, _ShadowFade;
			float4x4 shadow_projector;
			float _ShadowStrength;
			float4 _Shadow_TexelSize;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
				float4 shadow_uv = mul(shadow_projector, mul(unity_ObjectToWorld, v.vertex));
				o.shadow_uv = (shadow_uv.xy / shadow_uv.w + float2(1, 1)) * 0.5;
				UNITY_TRANSFER_FOG(o, o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
				col.rgb *= lm;

				fixed shadow = 0;
				for(fixed j = -0.5; j <= 0.5; j += 1)
				{
					for(fixed k = -0.5; k <= 0.5; k += 1)
					{
						shadow += tex2D(_Shadow, i.shadow_uv + _Shadow_TexelSize.xy * float2(j, k)).r;
					}
				}
				shadow /= 4;

				fixed fade = tex2D(_ShadowFade, i.shadow_uv).r;
				shadow *= fade * _ShadowStrength;
				col.rgb = fixed3(0, 0, 0) * shadow + col.rgb * (1 - shadow);

				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
