Shader "TA/Hidden/Average"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
				//float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			 
			};


			sampler2D _MainTex;
		 
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = 1.0/32;
				//o.uv = v.uv;
				 
				return o;
			}
			
			//把所有颜色算成一个像素的平均值.
			fixed4 frag (v2f i) : SV_Target
			{

				fixed4 col = 0;
				for(int k = 0 ; k < 32;k++)
				{
					for(int j = 0 ; j < 32;j++)
					{
						col += tex2D(_MainTex, i.uv*float2(k,j));
					}
				}
				col /= 1024.0;
			 
				return col;
			}
			ENDCG
		}
	}
}
