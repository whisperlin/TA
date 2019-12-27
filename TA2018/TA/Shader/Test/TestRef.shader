// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "TA/Test/TestRef"
{
	Properties
	{
		_Cube("CubeMap", CUBE) = ""{}
		cubemapCenter("cubemapCenter", vector) = (0,0,0,1)
		boxMin("boxMin", vector) = (-5,-5,-5,1)
		boxMax("boxMax", vector) = (5,5,5,1)
		[NoScaleOffset] _BumpMap("NormalTexture", 2D) = "" { }
		_Sky("天空", 2D) = "white" {}
	}
		SubShader
		{


			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				#include "LCHCommon.cginc"
				struct v2f {
					half3 worldRefl : TEXCOORD0;
					float4 pos : SV_POSITION;
					float3 worldPos : TEXCOORD1;
					float2 uv : TEXCOORD2;
					float3 worldViewDir: TEXCOORD3;
					NORMAL_TANGENT_BITANGENT_COORDS(5, 6, 7)
					
				};

				sampler2D _BumpMap;
				samplerCUBE _Cube;
				float4 cubemapCenter;
				float4 boxMin;
				float4 boxMax;
				uniform sampler2D _Sky;
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
				v2f vert(float4 vertex : POSITION, float3 normal : NORMAL, float4 tangent : TANGENT, float2 uv : TEXCOORD0)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(vertex);
					// compute world space position of the vertex
					float3 worldPos = mul(unity_ObjectToWorld, vertex).xyz;
					// compute world space view direction
					float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
					o.worldViewDir = worldViewDir;
 
					o.worldPos = worldPos;


					NTBYAttribute ntb = GetWorldNormalTangentBitangent(normal, tangent);
					o.normal = ntb.normal;
					o.tangent = ntb.tangent;
					o.bitangent = ntb.bitangent;

					o.uv = uv;
					return o;
				}
				inline float2 ToRadialCoords(float3 coords)
				{
					float3 normalizedCoords = normalize(coords);
					float latitude = acos(normalizedCoords.y);
					float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
					float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
					return float2(0.5, 1.0) - sphereCoords;
				}
				fixed4 frag(v2f i) : SV_Target
				{
					
					


					half3 bump0 = UnpackNormal(tex2Dlod(_BumpMap, float4(i.uv, 0, 0))).rgb;
					float3x3 tangentTransform = GetNormalTranform(i.normal, i.tangent, i.bitangent);
					half3 worldNormal = normalize(mul(bump0, tangentTransform));

 

					fixed3 wref = i.worldRefl.xyz;

					wref = reflect(-i.worldViewDir, worldNormal);

					wref = BoxProjectedCubemapDirection(wref, i.worldPos, cubemapCenter, boxMin, boxMax);

					
					fixed4 col = texCUBE(_Cube, normalize(wref.xyz));
					half2 skyUV = half2(ToRadialCoords(wref));
					fixed4 localskyColor = tex2D(_Sky, skyUV);

					return localskyColor;
				}
				ENDCG
			}
		}
}