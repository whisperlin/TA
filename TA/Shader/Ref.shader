 
Shader "TA/Test/Ref" {
	Properties{
		_refMap("refMap", Cube) = "_Skybox" {}
		_Normal("Normal", 2D) = "bump" {}
		[KeywordEnum(On,Off)] _UNITY_HDR("unity hdr£¿", Float) = 0
		_Exposure("_Exposure",Range(0,8)) = 1
		_ExposureNetEase("_ExposureNetEase",Range(0,1)) = 0.25
		
	}
		SubShader{
			Tags {
				"RenderType" = "Opaque"
			}
			Pass {
				Name "FORWARD"
				Tags {
					"LightMode" = "ForwardBase"
				}


				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#define UNITY_PASS_FORWARDBASE
				#include "UnityCG.cginc"
				#pragma multi_compile_fwdbase_fullshadows

				#pragma multi_compile _UNITY_HDR_ON _UNITY_HDR_OFF 
				
 
				#pragma target 3.0
				uniform samplerCUBE _refMap;
				uniform float4 _refMap_HDR;
				uniform sampler2D _Normal; uniform float4 _Normal_ST;
				uniform float _Exposure;
				uniform float _ExposureNetEase;
				struct VertexInput {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float2 texcoord0 : TEXCOORD0;
				};
				struct VertexOutput {
					float4 pos : SV_POSITION;
					float2 uv0 : TEXCOORD0;
					float4 posWorld : TEXCOORD1;
					float3 normalDir : TEXCOORD2;
					float3 tangentDir : TEXCOORD3;
					float3 bitangentDir : TEXCOORD4;
				};
				VertexOutput vert(VertexInput v) {
					VertexOutput o = (VertexOutput)0;
					o.uv0 = v.texcoord0;
					o.normalDir = UnityObjectToWorldNormal(v.normal);
					o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
					o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
					o.posWorld = mul(unity_ObjectToWorld, v.vertex);
					o.pos = UnityObjectToClipPos(v.vertex);
					return o;
				}

				inline half3 DecodeHDRFun(half4 data, half4 decodeInstructions)
				{
					// Take into account texture alpha if decodeInstructions.w is true(the alpha value affects the RGB channels)
					half alpha = decodeInstructions.w * (data.a - 1.0) + 1.0;
					// If Linear mode is not supported we can skip exponent part
					#if defined(UNITY_COLORSPACE_GAMMA)
										return (decodeInstructions.x * alpha) * data.rgb;
					#else
					#   if defined(UNITY_USE_NATIVE_HDR)
										return decodeInstructions.x * data.rgb; // Multiplier for future HDRI relative to absolute conversion.
					#   else
										return (decodeInstructions.x * pow(alpha, decodeInstructions.y)) * data.rgb;
					#   endif
					#endif
				}
				float4 frag(VertexOutput i) : COLOR {
					i.normalDir = normalize(i.normalDir);
					float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
					float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
					float3 _Normal_var = UnpackNormal(tex2D(_Normal,TRANSFORM_TEX(i.uv0, _Normal)));
					float3 normalLocal = _Normal_var.rgb;
					float3 normalDirection = normalize(mul(normalLocal, tangentTransform)); // Perturbed normals
					float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
			////// Lighting:
			////// Emissive:
					float4 color = texCUBE(_refMap,viewReflectDirection);
					
#if _UNITY_HDR_ON
					color.rgb = DecodeHDR(color, _refMap_HDR);
					color.rgb *= _Exposure;
#else
					color.rgb *= max(0, exp2( color.w*_ExposureNetEase*4-2));
#endif
					
					
					float3 finalColor = color.rgb;
					//_Exposure
					return fixed4(finalColor,1);
				}
						ENDCG
			}
		}
	FallBack "Diffuse"
	//CustomEditor "ShaderForgeMaterialInspector"
}
