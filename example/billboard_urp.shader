Shader "Lin/URP/billboard" //[#index]
{
	Properties
	{
		_Color("Color(RGB)",Color) = (1,1,1,1)
		_BaseMap("MainTex",2D) = "gary"{}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Scale", Range(0,2)) = 1.0
	}
	SubShader
	{
		Tags
		{
			"RenderPipeline"="UniversalPipeline"
			"RenderType"="Opaque"
			"Queue"="Geometry+0"
		}
		
		Pass
		{
			Name "ForwardLit"
			Tags { "LightMode" = "UniversalForward" }

			Blend One Zero, One Zero
			Cull Back
			ZTest LEqual
			ZWrite On
			HLSLPROGRAM
			
			// Required to compile gles 2.0 with standard SRP library
            // All shaders must be compiled with HLSLcc and currently only gles is not using HLSLcc by default
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

			//#define _NORMALMAP 1
            // -------------------------------------
            // Material Keywords
            //#pragma shader_feature _NORMALMAP
            //#pragma shader_feature _ALPHATEST_ON
            //#pragma shader_feature _ALPHAPREMULTIPLY_ON
            //#pragma shader_feature _EMISSION
            //#pragma shader_feature _METALLICSPECGLOSSMAP
            //#pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            //#pragma shader_feature _OCCLUSIONMAP

            //#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
            //#pragma shader_feature _ENVIRONMENTREFLECTIONS_OFF
            //#pragma shader_feature _SPECULAR_SETUP

            #pragma shader_feature _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            //#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

            // -------------------------------------
            // Unity defined keywords
            //#pragma multi_compile _ DIRLIGHTMAP_COMBINED*/
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
 
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
 
			#define _NORMALMAP 1
			#pragma vertex vert
			#pragma fragment frag
 

			CBUFFER_START(UnityPerMaterial)
			half4 _Color;
			half _BumpScale;
			CBUFFER_END


			TEXTURE2D(_BaseMap);SAMPLER(sampler_BaseMap);
			float4 _BaseMap_ST;
			TEXTURE2D(_BumpMap);SAMPLER(sampler_BumpMap);
			float4 _BumpMap_ST;
			

			#define smp SamplerState_Point_Repeat
			SAMPLER(smp);
			struct Attributes
			{
					float3 positionOS : POSITION;
					float3 normalOS  : NORMAL;
					float4 tangentOS : TANGENT;
					float2 uv :TEXCOORD0;
					float2 lightmapUV: TEXCOORD1;
			};

			struct Varyings
			{
					float4 positionCS : SV_POSITION;
					float2 uv :TEXCOORD0;
					DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
					float3 normalWS :TEXCOORD2;
					float3 positionWS:TEXCOORD3;
					#ifdef _NORMALMAP
						float3 tangentWS:TEXCOORD4;
						float3 bitangentWS:TEXCOORD5;
					#endif
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						float4 shadowCoord              : TEXCOORD7;
					#endif
					float4 col:TEXCOORD8;

			};
			
			void Billboard(inout float3 vertex,inout float3 normal)
			{
				float3  viewDir = normalize( GetCameraPositionWS() -  TransformObjectToWorld(float3(0,0,0)));
				float3 upCamVec = float3( 0, 1, 0 );
				float3 forwardCamVec = -viewDir;
				float3 rightCamVec = normalize( cross(forwardCamVec,upCamVec) );
				upCamVec = normalize( cross(rightCamVec,forwardCamVec) );
				float3x3 rotationCamMatrix = float3x3( rightCamVec,   upCamVec,   forwardCamVec  );
				normal = normalize( mul( normal, rotationCamMatrix ));
				vertex.x *= length( unity_ObjectToWorld._m00_m10_m20 );
				vertex.y *= length( unity_ObjectToWorld._m01_m11_m21 );
				vertex.z *= length( unity_ObjectToWorld._m02_m12_m22 );
				vertex = mul( vertex, rotationCamMatrix );
				vertex = mul( (float3x3) unity_WorldToObject, vertex );
			}
			void BillboardY(inout float3 vertex,inout float3 normal  )
			{
				float3  viewDir = normalize( GetCameraPositionWS() -  TransformObjectToWorld(float3(0,0,0)));
				float3 upCamVec = float3( 0, 1, 0 );
				float3 forwardCamVec = -viewDir;
				float3 rightCamVec = normalize( cross(forwardCamVec,upCamVec) );
				float3x3 rotationCamMatrix = float3x3( rightCamVec,   upCamVec,   forwardCamVec  );
				normal = normalize( mul( normal, rotationCamMatrix ));
				vertex.x *= length( unity_ObjectToWorld._m00_m10_m20 );
				vertex.y *= length( unity_ObjectToWorld._m01_m11_m21 );
				vertex.z *= length( unity_ObjectToWorld._m02_m12_m22 );
				vertex = mul( vertex, rotationCamMatrix );
				vertex = mul( (float3x3) unity_WorldToObject, vertex );
			}
			Varyings vert(Attributes i)
			{
				Varyings o = (Varyings)0;
				o.uv =  i.uv ;
				o.col = i.positionOS.z >0 ? float4(1,0,0,1):float4(1,1,1,1);
				
 
				BillboardY(i.positionOS,i.normalOS);
 
				o.positionCS = TransformObjectToHClip(i.positionOS);
				
				o.positionWS = TransformObjectToWorld(i.positionOS.xyz);
				
				//float3 normalWS = TransformObjectToWorldNormal(i.normalOS);
				VertexNormalInputs normalInput = GetVertexNormalInputs(i.normalOS, i.tangentOS);
			#ifdef _NORMALMAP
				o.normalWS = half3(normalInput.normalWS);
				o.tangentWS = half3(normalInput.tangentWS);
				o.bitangentWS = half3(normalInput.bitangentWS);
				
			#else
				o.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
			#endif
				OUTPUT_LIGHTMAP_UV(i.lightmapUV, unity_LightmapST, o.lightmapUV);
				OUTPUT_SH(o.normalWS.xyz, o.vertexSH);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					o.shadowCoord = GetShadowCoord(i);
				#endif

	
				return o;
			}

			half4 frag(Varyings i) : SV_TARGET 
			{ 
				
			/*#if !LIGHTMAP_ON
 
				return float4(i.vertexSH.xyz,1);
			#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					return half4(1,0,0,1);
				#endif*/
		
			#ifdef _NORMALMAP
				half4 _n = SAMPLE_TEXTURE2D(_BumpMap,sampler_BumpMap,TRANSFORM_TEX(i.uv,_BumpMap)  );
				half3 normalTS = UnpackNormalScale(_n, _BumpScale);
				half3 normalWorld = TransformTangentToWorld(normalTS, half3x3(i.tangentWS.xyz, i.bitangentWS.xyz, i.normalWS.xyz));
				normalWorld = NormalizeNormalPerPixel(normalWorld);
			#else
				half3 normalWorld = NormalizeNormalPerPixel(i.normalWS);
			#endif


			half3 lightColor = _MainLightColor.rgb;
			half3 lightDirection = normalize(_MainLightPosition.xyz);

			#if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
			half4 shadowCoord = TransformWorldToShadowCoord(i.positionWS);
			half shadowAttenuation = MainLightRealtimeShadow(shadowCoord);
			lightColor.xyz*=shadowAttenuation;
			//return float4(shadowAttenuation,0,0,1);
			#endif

			
			half ndotl = saturate(dot(lightDirection,normalWorld));
			half4 mainTex = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,TRANSFORM_TEX(i.uv,_BaseMap)  );
			half4 c = _Color * mainTex  * i.col;
			c.rgb=c.rgb*( lightColor.rgb*ndotl    + i.vertexSH.xyz);
			return c;
		}

ENDHLSL
		}
	}
	FallBack "Hidden/Shader Graph/FallbackError"
}