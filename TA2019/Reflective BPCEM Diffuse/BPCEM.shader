// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "TA/BoxProjectSkyReflection"
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
				struct appdata
				{
					float4 vertex : POSITION;
					float3 normal : NORMAl;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					fixed4 color : COLOR;
					half3 worldNormal : TEXCOORD0;
					half3 worldPos : TEXCOORD1;
				};
				samplerCUBE _Cube;
				float4 cubemapCenter;
				float4 boxMin;
				float4 boxMax;

				inline half3 BoxProjectedCubemapDirection(half3 worldRefl, float3 worldPos, float4 cubemapCenter, float4 boxMin, float4 boxMax)
				{

					if (cubemapCenter.w > 0.0)
					{
						half3 nrdir = normalize(worldRefl);

						half3 rbmax = (boxMax.xyz - worldPos) / nrdir;
						half3 rbmin = (boxMin.xyz - worldPos) / nrdir;

						half3 rbminmax = (nrdir > 0.0f) ? rbmax : rbmin;

						half fa = min(min(rbminmax.x, rbminmax.y), rbminmax.z);

						worldPos -= cubemapCenter.xyz;
						worldRefl = worldPos + nrdir * fa;

					}
					return worldRefl;
				}
				v2f vert(appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex);
					return o;
				}
				fixed4 frag(v2f i) : SV_TARGET
				{
					half3 worldView = UnityWorldSpaceViewDir(i.worldPos);
					half3 refDir = reflect(-worldView, i.worldNormal);
					refDir = BoxProjectedCubemapDirection(refDir, i.worldPos, cubemapCenter, boxMin, boxMax);
					fixed4 refCol = texCUBE(_Cube, refDir);
					return refCol;

				}

				ENDCG
			}
		}
}