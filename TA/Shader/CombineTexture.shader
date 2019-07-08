Shader "Hidden/CombineTexture"
{
	Properties
	{
		_TexR ("Texture", 2D) = "white" {}
		_TexG("Texture", 2D) = "white" {}
		_TexB("Texture", 2D) = "white" {}
		_TexA("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _TexR;
			sampler2D _TexG;
			sampler2D _TexB;
			sampler2D _TexA;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed r = tex2D(_TexR, i.uv);
				fixed g = tex2D(_TexG, i.uv);
				fixed b = tex2D(_TexB, i.uv);
				fixed a = tex2D(_TexA, i.uv);
		 
				return float4(r,g,b,a);
			}
			ENDCG
		}
	}
}
