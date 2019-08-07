Shader "BNN/Scene/NoLight" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200


		Pass {
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On
			CGPROGRAM

            #include "UnityStandardShadow.cginc"
            #pragma vertex vertShadowCaster
			#pragma fragment frag
            #pragma multi_compile_shadowcaster
			fixed4 frag(): SV_Target
			{
				return 1;
			}
			ENDCG
		}

		Pass {
			CGPROGRAM

			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			sampler2D _MainTex;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(2)
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag(v2f i): SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				UNITY_APPLY_FOG(i.fogCoord, c);
				return c;
			}
			ENDCG
		}
	}
}
