// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "TA/BoxProjectSkyReflection"
{
	Properties
    {
        _Cube("CubeMap", CUBE) = ""{}
		cubemapCenter("cubemapCenter", vector) = (0,0,0,1)
		boxMin("boxMin", vector) =  (-5,-5,-5,1)
		boxMax("boxMax", vector) =  (5,5,5,1)
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
                half3 worldRefl : TEXCOORD0;
                float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD1;
            };
			samplerCUBE _Cube;
			float4 cubemapCenter;
			float4 boxMin;
			float4 boxMax;

			inline half3 BoxProjectedCubemapDirection (half3 worldRefl, float3 worldPos, float4 cubemapCenter, float4 boxMin, float4 boxMax)
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
            v2f vert (float4 vertex : POSITION, float3 normal : NORMAL)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vertex);
                // compute world space position of the vertex
                float3 worldPos = mul(unity_ObjectToWorld, vertex).xyz;
                // compute world space view direction
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                // world space normal
                float3 worldNormal = UnityObjectToWorldNormal(normal);
                // world space reflection vector
                o.worldRefl = reflect(-worldViewDir, worldNormal);
				o.worldPos = worldPos;
                return o;
            }
        
            fixed4 frag (v2f i) : SV_Target
            {
				fixed3 wref = BoxProjectedCubemapDirection (i.worldRefl.xyz, i.worldPos,  cubemapCenter,  boxMin,  boxMax);
				fixed4 col = texCUBE(_Cube, normalize(wref.xyz));
               
                return col;
            }
            ENDCG
        }
    }
}