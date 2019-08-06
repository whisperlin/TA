Shader "Hidden/CubemapToMatcap"
{
	Properties
	{
		_MainTex("Cubemap (RGB)", CUBE) = "" {}
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
			
			samplerCUBE _MainTex;


			/*inline fixed3 UnpackNormalDXT5nm(fixed4 packednormal)
			{
				fixed3 normal;
				normal.xy = packednormal.wy * 2 - 1;
				normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
				return normal;
			}*/

			// (normal.xz*0.5 + 1) = uv;
			half3 MatCapUVToNormal(half2 uv)
			{
				half3 normal;
				normal.xz = uv * 2 - 1;
				normal.y = sqrt(1 - saturate(dot(normal.xz, normal.xz)));
				return normal;
			}
			// normal.x = sign(normal.x)*normal.x*normal.x;
			// normal.y = sign(normal.y)*normal.y*normal.y;
			//  normal.xz *0.5 + 1  = uv;
			half3 MatCapUVToNormalNew(half2 uv)
			{
				//uv.x = sqrt(uv.x);
				//uv.y = sqrt(uv.y);
				half3 normal;
				normal.xz = uv * 2 - 1;
				normal.y = sqrt(1 - (abs(normal.x) + abs(normal.z) )) ;
				normal.x = sign(normal.x)*sqrt(normal.x);
				normal.z = sign(normal.z)*sqrt(normal.z);
				
				return normal;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				half3 normal = MatCapUVToNormal(i.uv);
				
				return texCUBE(_MainTex, normal);
				 
			}
			ENDCG
		}
	}
}
