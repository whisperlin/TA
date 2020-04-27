// Upgrade NOTE: replaced 'UNITY_INSTANCE_ID' with 'UNITY_VERTEX_INPUT_INSTANCE_ID'

 
Shader "Shader Forge/PhoneFullVirtualPointLight" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("MainTex", 2D) = "white" {}
		_SpecularColor("SpecularColor", Color) = (1,1,1,1)
		_Gloss("_Gloss", Range(0, 1)) = 0.5128205
		_Bumpc("Bumpc", 2D) = "bump" {}
		_Emission("Emission", Color) = (0,0,0,1)
		[HideInInspector]_Cutoff("Alpha cutoff", Range(0,1)) = 0.5
	}
		SubShader{
			Tags {
				"Queue" = "AlphaTest"
				"RenderType" = "TransparentCutout"
			}
			Pass {
				Name "FORWARD"
				Tags {
					"LightMode" = "ForwardBase"
				}
				Cull Off


				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#define UNITY_PASS_FORWARDBASE
				#include "UnityCG.cginc"
				#include "AutoLight.cginc"
				#include "virtualight.cginc"
				#pragma multi_compile_fwdbase_fullshadows
				#pragma multi_compile_instancing
				#pragma target 2.0
				uniform float4 _LightColor0;
				uniform float4 _Color;
				uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
				uniform float4 _SpecularColor;
				uniform float _Gloss;

				uniform sampler2D _Bumpc; uniform float4 _Bumpc_ST;
				uniform float4 _Emission;
				struct VertexInput {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float2 texcoord0 : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
				struct VertexOutput {
					float4 pos : SV_POSITION;
					float2 uv0 : TEXCOORD0;
					float4 posWorld : TEXCOORD1;
					float3 normalDir : TEXCOORD2;
					float3 tangentDir : TEXCOORD3;
					float3 bitangentDir : TEXCOORD4;
					LIGHTING_COORDS(5,6)
					UNITY_FOG_COORDS(7)
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
				VertexOutput vert(VertexInput v) {

					


					VertexOutput o = (VertexOutput)0;

					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_TRANSFER_INSTANCE_ID(v, o);

					o.uv0 = v.texcoord0;
					o.normalDir = UnityObjectToWorldNormal(v.normal);
					o.tangentDir = UnityObjectToWorldDir(v.tangent.xyz);
					half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
					o.bitangentDir = cross(o.normalDir, o.tangentDir) * tangentSign;
					o.posWorld = mul(unity_ObjectToWorld, v.vertex);
					float3 lightColor = _LightColor0.rgb;
					o.pos = UnityObjectToClipPos(v.vertex);
					UNITY_TRANSFER_FOG(o,o.pos);
					TRANSFER_VERTEX_TO_FRAGMENT(o)
					return o;
				}
				float3 BlinnPhone(float3 attenColor,float3 diffuseColor,float3 specularColor,float gloss, float3 viewDirection,float3 normalDirection ,float3 lightDirection, float3 indirectDiffuse)
				{
					float3 halfDirection = normalize(viewDirection + lightDirection);
					float specPow = exp2(gloss * 10.0 + 1.0);
					////// Specular:
					float NdotL = saturate(dot(normalDirection, lightDirection));
					float3 directSpecular = attenColor * pow(max(0, dot(halfDirection, normalDirection)), specPow)*specularColor;
					float3 specular = directSpecular;
					/////// Diffuse:
					float3 directDiffuse = NdotL * attenColor;
					float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
					////// Emissive:
					return diffuse + specular;
				}
				
				float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
					float isFrontFace = (facing >= 0 ? 1 : 0);
					float faceSign = (facing >= 0 ? 1 : -1);
					i.normalDir = normalize(i.normalDir);
					i.normalDir *= faceSign;
					float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
					float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
					float4 _Bumpc_var = tex2D(_Bumpc,TRANSFORM_TEX(i.uv0, _Bumpc));
					float3 normalLocal = _Bumpc_var.rgb;
					float3 normalDirection = normalize(mul(normalLocal, tangentTransform)); // Perturbed normals
					float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
					clip(_MainTex_var.a - 0.5);

					float3 lightDirection;
					float3 lightColor;


					
					GetVirtualPointLightData(UNITY_ACCESS_INSTANCED_PROP(_VirtualPointLightPos_arr, _VirtualPointLightPos), UNITY_ACCESS_INSTANCED_PROP(_VirtualPointLightColor_arr, _VirtualPointLightColor),   i.posWorld.xyz,   lightDirection,  lightColor);
 
					float attenuation = LIGHT_ATTENUATION(i);
					float3 attenColor = attenuation * lightColor.xyz;

					float3 diffuseColor = (_MainTex_var.rgb*_Color.rgb);
					float3 diffuseSP = BlinnPhone(attenColor, diffuseColor, _SpecularColor.rgb , _Gloss, viewDirection, normalDirection,  lightDirection, UNITY_LIGHTMODEL_AMBIENT.rgb);
 
					float3 emissive = (_MainTex_var.rgb*_Emission.rgb);
 
					float3 finalColor = diffuseSP + emissive;
					fixed4 finalRGBA = fixed4(finalColor,1);
					UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
					return finalRGBA;
				}
				ENDCG
			}
					
			Pass {
				Name "ShadowCaster"
				Tags {
					"LightMode" = "ShadowCaster"
				}
				Offset 1, 1
				Cull Off

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#define UNITY_PASS_SHADOWCASTER
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma multi_compile_shadowcaster
				#pragma multi_compile_fog
				#pragma only_renderers d3d9 d3d11 glcore gles gles3 
				#pragma target 2.0
				uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
				struct VertexInput {
					float4 vertex : POSITION;
					float2 texcoord0 : TEXCOORD0;
				};
				struct VertexOutput {
					V2F_SHADOW_CASTER;
					float2 uv0 : TEXCOORD1;
				};
				VertexOutput vert(VertexInput v) {
					VertexOutput o = (VertexOutput)0;
					o.uv0 = v.texcoord0;
					o.pos = UnityObjectToClipPos(v.vertex);
					TRANSFER_SHADOW_CASTER(o)
					return o;
				}
				float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
					float isFrontFace = (facing >= 0 ? 1 : 0);
					float faceSign = (facing >= 0 ? 1 : -1);
					float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
					clip(_MainTex_var.a - 0.5);
					SHADOW_CASTER_FRAGMENT(i)
				}
				ENDCG
			}
		}
		FallBack "Diffuse"
		CustomEditor "ShaderForgeMaterialInspector"
}
