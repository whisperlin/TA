Shader "Unlit/VerteTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"


			


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				float3 normal : NORMAL;
				half4 tangent   : TANGENT;
            };

			struct LCHVertexDATA
			{
				float4 pos;
				half3 eyeVec;
				half4 tangentToWorldAndParallax[3];    // [3x3:tangentToWorld | 1x3:viewDirForParallax]
				half4 ambientOrLightmapUV;    // SH or Lightmap UV
				float3 posWorld;
 

			};

			struct LCHFragmentCommonData
			{
				half3 diffColor, specColor;
				// Note: smoothness & oneMinusReflectivity for optimization purposes, mostly for DX9 SM2.0 level.
				// Most of the math is being done on these (1-x) values, and that saves a few precious ALU slots.
				half oneMinusReflectivity, smoothness;
				float3 normalWorld;
				float3 eyeVec;
				half alpha;
				float3 posWorld;

 
			#if UNITY_STANDARD_SIMPLE
					half3 tangentSpaceNormal;
			#endif
			};
			
			inline half4 VertexGIForward(float2 uv1,float2 uv2, float3 posWorld, half3 normalWorld)
			{
				half4 ambientOrLightmapUV = 0;
				// Static lightmaps
#ifdef LIGHTMAP_ON
				ambientOrLightmapUV.xy = uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				ambientOrLightmapUV.zw = 0;
#ifdef DYNAMICLIGHTMAP_ON
				ambientOrLightmapUV.zw = uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
 
#else
				ambientOrLightmapUV.rgb = ShadeSH9(half4(normalWorld, 1));  
				
#endif

				return ambientOrLightmapUV;
			}
			void  FillNormalData(float3 normal  ,float4 tangent,  inout half4 tangentToWorldAndParallax[3])
			{
					float3 normalWorld = UnityObjectToWorldNormal(normal);
#ifdef _TANGENT_TO_WORLD
					float4 tangentWorld = float4(UnityObjectToWorldDir(tangent.xyz), tangent.w);

					float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
					tangentToWorldAndParallax[0].xyz = tangentToWorld[0];
					tangentToWorldAndParallax[1].xyz = tangentToWorld[1];
					tangentToWorldAndParallax[2].xyz = tangentToWorld[2];
#else
					tangentToWorldAndParallax[0].xyz = 0;
				tangentToWorldAndParallax[1].xyz = 0;
				tangentToWorldAndParallax[2].xyz = normalWorld;
#endif
			}

			float3 PerPixelWorldNormal(sampler2D bumpTex , float2 i_tex, float4 tangentToWorld[3])
			{
#ifdef _NORMALMAP
				half3 tangent = tangentToWorld[0].xyz;
				half3 binormal = tangentToWorld[1].xyz;
				half3 normal = tangentToWorld[2].xyz;

#if UNITY_TANGENT_ORTHONORMALIZE
				normal = NormalizePerPixelNormal(normal);

				// ortho-normalize Tangent
				tangent = normalize(tangent - normal * dot(tangent, normal));

				// recalculate Binormal
				half3 newB = cross(normal, tangent);
				binormal = newB * sign(dot(newB, binormal));
#endif

				half3 normalTangent = UnpackScaleNormal(tex2D(bumpTex, i_tex), _BumpScale);
				float3 normalWorld = normalize(tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z); // @TODO: see if we can squeeze this normalize on SM2.0 as well
#else
				float3 normalWorld = normalize(tangentToWorld[2].xyz);
#endif
				return normalWorld;
			}
			LCHVertexDATA vertForwardBase( float4 vertex ,float3 normal,float4 tangent,float2 uv1,float2 uv2)
			{
				LCHVertexDATA o;
				float4 posWorld = mul(unity_ObjectToWorld, vertex);
				o.posWorld = posWorld.xyz;
				o.pos = UnityObjectToClipPos(vertex);

				o.eyeVec = normalize(posWorld.xyz - _WorldSpaceCameraPos);
				float3 normalWorld = UnityObjectToWorldNormal(normal);
		#ifdef _TANGENT_TO_WORLD
				float4 tangentWorld = float4(UnityObjectToWorldDir(tangent.xyz), tangent.w);

				float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
				o.tangentToWorldAndParallax[0].xyz = tangentToWorld[0];
				o.tangentToWorldAndParallax[1].xyz = tangentToWorld[1];
				o.tangentToWorldAndParallax[2].xyz = tangentToWorld[2];
		#else
				o.tangentToWorldAndParallax[0].xyz = 0;
				o.tangentToWorldAndParallax[1].xyz = 0;
				o.tangentToWorldAndParallax[2].xyz = normalWorld;
		#endif
				o.ambientOrLightmapUV = VertexGIForward(uv1,uv2, posWorld, normalWorld);
				return o;
			}

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			
            v2f vert (appdata v)
            {
                v2f o;
				LCHVertexDATA _data = vertForwardBase( v.vertex,  v.normal,  v.tangent,  v.uv1,  v.uv2);
                o.vertex = _data.pos;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
              
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
               
                return col;
            }


			
            ENDCG
        }
    }
}
