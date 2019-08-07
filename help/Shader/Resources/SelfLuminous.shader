Shader "YuLongZhi/SelfLuminous"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
	}

	SubShader
	{
		Pass
		{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{ 
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
			};

			struct v2f
			{
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};

			//sampler2D unity_NHxRoughness;

			fixed4 _Color;
			sampler2D _MainTex;
			half4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}  

			//inline half2 Pow4 (half2 x) { return x *x*x*x; }

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c_base = tex2D(_MainTex, i.uv);
				fixed4 c = c_base * _Color;
				return c;
			}
			ENDCG
		}
	}
} 
