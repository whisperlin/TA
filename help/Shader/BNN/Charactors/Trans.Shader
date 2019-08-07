Shader "BNN/Charactors/Trans"
{
	Properties
	{
		_TransColor("Transparent Color", Color) = (1, 1, 1, 1)
	}

	SubShader
		{
			Tags
			{
				"RenderType" = "Opaque"
				"Queue" = "AlphaTest+1"
			}

			Pass 
			{
				    Name "Trans"
					Cull Front
					ZTest Greater
					ZWrite Off
					Blend SrcAlpha One

					CGPROGRAM
#pragma vertex vert
#pragma fragment frag


#include "UnityCG.cginc"

					fixed4 _TransColor;

					struct appdata {
						fixed4 vertex : POSITION;
						fixed3 normal : NORMAL;
					};

					struct v2f {
						fixed4 vertex : SV_POSITION;
						fixed3 normal : TEXCOORD0;
						fixed3 viewDir : TEXCOORD1;
					};

					v2f vert(appdata v) {
						v2f o;
						o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
						o.normal = UnityObjectToWorldNormal(v.normal);

						fixed3 posWorld = mul(unity_ObjectToWorld, v.vertex);
						o.viewDir = normalize(posWorld - _WorldSpaceCameraPos.xyz);
						return o;
					}

					fixed4 frag(v2f i) : SV_Target{
						half rim = 1.0 - saturate(dot(normalize(i.viewDir), i.normal));
						return _TransColor * rim;
					}
					ENDCG
				}


		}
}