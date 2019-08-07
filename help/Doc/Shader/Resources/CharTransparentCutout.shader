Shader "YuLongZhi/Char-Transparent-Cutout"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
	    _CutAlpha ("CutAlpha", Range(0, 1)) = 0.5
	}

	SubShader
	{
		Tags { "Queue"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct appdata
			{
				fixed4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};


			struct v2f
			{
				fixed4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			fixed4 _Color;
			float _CutAlpha;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv) * _Color;
				clip(c.a - _CutAlpha);
				return c;
			}
			ENDCG
		}
	}
}
