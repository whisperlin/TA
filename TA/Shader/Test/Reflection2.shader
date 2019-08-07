// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "TA/Test/Reflection2"
{
	Properties
	{
		_Cube("CubeMap", CUBE) = ""{}
		cubemapCenter("cubemapCenter", vector) = (0,0,0,1)
		boxMin("boxMin", vector) = (-5,-5,-5,1)
		boxMax("boxMax", vector) = (5,5,5,1)
	}
		SubShader
		{


			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				struct v2f {
				 
					float4 pos : SV_POSITION;
					float3 worldPos : TEXCOORD1;
					float3 worldNormal : TEXCOORD2;
				};
				samplerCUBE _Cube;
				float4 cubemapCenter;
				float4 boxMin;
				float4 boxMax;

				 
				v2f vert(float4 vertex : POSITION, float3 normal : NORMAL)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(vertex);
					// compute world space position of the vertex
					float3 worldPos = mul(unity_ObjectToWorld, vertex).xyz;
					// compute world space view direction
					
					// world space normal
					o.worldNormal = UnityObjectToWorldNormal(normal);
					// world space reflection vector
					
					o.worldPos = worldPos;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
 
					float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
					float3 worldRefl = reflect(-worldViewDir, normalize(i.worldNormal) );
					fixed4 col = texCUBE(_Cube, normalize(worldRefl));

					return col;
				}
				ENDCG
			}
		}
}