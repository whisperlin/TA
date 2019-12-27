Shader "TA/Tools/CubeMapBox"
{
	Properties
	{
		_CubeMap("CubeMap", CUBE) = ""{}
	}
		SubShader
	{
		Pass
		{
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 vertexLocal : TEXCOORD1;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertexLocal = v.vertex;
				o.vertex = UnityObjectToClipPos(v.vertex);

				return o;
			}

			samplerCUBE _CubeMap;
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = texCUBE(_CubeMap, normalize(i.vertexLocal.xyz));
				return col;
			}
			ENDCG
		}
	}
}
 