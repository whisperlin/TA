Shader "BNN/Scene/NoLightAlphaTree"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_Frequency ("Frequency", float) = 1
		_Wind ("Wind", Vector) = (0, 0, 0.1, 0)
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" }
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off

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
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(2)
				float4 vertex : SV_POSITION;
			};

			float4 _Color;
			sampler2D _MainTex;
			float _Frequency;
			float4 _Wind;

			v2f vert (appdata v)
			{
				float wave_offset = v.color.r;
				float wave_weight = v.color.g;

				v.vertex.xyz += _Wind.xyz * cos(_Time.y * _Frequency + wave_offset * 3.14159) * wave_weight;

				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv) * _Color;
				UNITY_APPLY_FOG(i.fogCoord, c);
				return c;
			}
			ENDCG
		}
	}
}
