// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:3,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:True,hqlp:False,rprd:True,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,billboard:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:2865,x:33213,y:32800,varname:node_2865,prsc:2|diff-6343-OUT,spec-3345-OUT,gloss-6256-OUT,normal-5964-RGB,emission-152-OUT;n:type:ShaderForge.SFN_Multiply,id:6343,x:32302,y:32548,varname:node_6343,prsc:2|A-7736-RGB,B-6665-RGB;n:type:ShaderForge.SFN_Color,id:6665,x:32022,y:32613,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Tex2d,id:7736,x:32055,y:32382,ptovrint:True,ptlb:Albedo,ptin:_MainTex,varname:_MainTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:5964,x:32425,y:33140,ptovrint:True,ptlb:Normal Map,ptin:_BumpMap,varname:_BumpMap,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Slider,id:358,x:32250,y:32780,ptovrint:False,ptlb:MetallicPower,ptin:_MetallicPower,varname:node_358,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Slider,id:1813,x:32125,y:33024,ptovrint:False,ptlb:GlossPower,ptin:_GlossPower,varname:_Metallic_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Tex2d,id:8912,x:32343,y:32236,ptovrint:False,ptlb:Metallic,ptin:_Metallic,varname:node_8912,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:3345,x:32848,y:32295,varname:node_3345,prsc:2|A-8912-R,B-358-OUT;n:type:ShaderForge.SFN_Multiply,id:6256,x:32619,y:32793,varname:node_6256,prsc:2|A-8912-G,B-1813-OUT;n:type:ShaderForge.SFN_Multiply,id:152,x:32912,y:32569,varname:node_152,prsc:2|A-6343-OUT,B-8912-A;proporder:5964-6665-7736-358-1813-8912;pass:END;sub:END;*/

Shader "Shader Forge/SubstancePBR" {
	Properties{
		_MainTex("Albedo", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_Color("Color", Color) = (1,1,1,1)

		_MetallicPower("MetallicPower", Range(0, 1)) = 1
		_GlossPower("GlossPower", Range(0, 1)) = 1
		_EmissivePower("EmissivePower", Range(0, 1)) = 0
		_Metallic("Metallic", 2D) = "white" {}
		_Cube("Reflection Cubemap", Cube) = "_Skybox" {}
		[KeywordEnum(TYPE1,TYPE2,TYPE3)] _PBR("_PBR", Float) = 0





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
				#define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
				#define _GLOSSYENV 1
				#include "UnityCG.cginc"
				#include "AutoLight.cginc"
				#include "Lighting.cginc"
				#include "UnityPBR.cginc"
				#pragma multi_compile_fwdbase_fullshadows
				#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
				#pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
				#pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
				#pragma multi_compile_fog

				#pragma multi_compile  _PBR_TYPE1  _PBR_TYPE2  _PBR_TYPE3



				#pragma target 3.0
				uniform float4 _Color;
				uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
				uniform sampler2D _BumpMap; uniform float4 _BumpMap_ST;
				uniform float _MetallicPower;
				uniform float _GlossPower;
				uniform sampler2D _Metallic; uniform float4 _Metallic_ST;
				half _EmissivePower;
				samplerCUBE _Cube;
				struct VertexInput {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float2 texcoord0 : TEXCOORD0;
					float2 texcoord1 : TEXCOORD1;
					float2 texcoord2 : TEXCOORD2;
				};
				struct VertexOutput {
					float4 pos : SV_POSITION;
					float2 uv0 : TEXCOORD0;
					float2 uv1 : TEXCOORD1;
					float2 uv2 : TEXCOORD2;
					float4 posWorld : TEXCOORD3;
					float3 normalDir : TEXCOORD4;
					float3 tangentDir : TEXCOORD5;
					float3 bitangentDir : TEXCOORD6;
					
					LIGHTING_COORDS(7, 8)

					float3 sh : TEXCOORD9;
				};

 
				VertexOutput vert(VertexInput v) {
					VertexOutput o = (VertexOutput)0;
					o.uv0 = v.texcoord0;
					o.uv1 = v.texcoord1;
					o.uv2 = v.texcoord2;
					#ifdef LIGHTMAP_ON
						o.ambientOrLightmapUV.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
						o.ambientOrLightmapUV.zw = 0;
					#elif UNITY_SHOULD_SAMPLE_SH
					#endif
					#ifdef DYNAMICLIGHTMAP_ON
						o.ambientOrLightmapUV.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
					#endif
					o.normalDir = UnityObjectToWorldNormal(v.normal);
					o.tangentDir = UnityObjectToWorldDir(v.tangent.xyz);
					half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
					o.bitangentDir = cross(o.normalDir, o.tangentDir) * tangentSign;
					o.posWorld = mul(unity_ObjectToWorld, v.vertex);
					float3 lightColor = _LightColor0.rgb;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.sh = ShadeSH9(half4(o.normalDir, 1));
					TRANSFER_VERTEX_TO_FRAGMENT(o)
					return o;
				}











				float4 frag(VertexOutput i) : COLOR {
					i.normalDir = normalize(i.normalDir);
					float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
					float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
					float3 _BumpMap_var = UnpackNormal(tex2D(_BumpMap,TRANSFORM_TEX(i.uv0, _BumpMap)));
					float3 normalLocal = _BumpMap_var.rgb;
					float3 normalDirection = normalize(mul(normalLocal, tangentTransform)); // Perturbed normals
					float3 viewReflectDirection = reflect(-viewDirection, normalDirection);
					float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
					float3 lightColor = _LightColor0.rgb;
					float3 halfDirection = normalize(viewDirection + lightDirection);
					////// Lighting:
					float attenuation = 1;
					float3 attenColor = attenuation * _LightColor0.xyz;
				 
					float4 _Metallic_var = tex2D(_Metallic,TRANSFORM_TEX(i.uv0, _Metallic));
					float gloss = (_Metallic_var.g*_GlossPower);
					float perceptualRoughness = 1.0 - (_Metallic_var.g*_GlossPower);
					float roughness = perceptualRoughness * perceptualRoughness;
					float specPow = exp2(gloss * 10.0 + 1.0);
					/////// GI Data:
					UnityLight light;
					light.color = lightColor;
					light.dir = lightDirection;
					float NdotL = saturate(dot(normalDirection, lightDirection));
					light.ndotl = NdotL;
					//light.ndotl = LambertTerm(normalDirection, light.dir);
				 
					////// Specular:
				
 
					float3 specularColor = (_Metallic_var.r*_MetallicPower);
					float specularMonochrome;
					float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
					float3 diffuseColor = (_MainTex_var.rgb*_Color.rgb);
					diffuseColor = DiffuseAndSpecularFromMetallic(diffuseColor, specularColor, specularColor, specularMonochrome);
			 

					half smoothness = gloss;
					half oneMinusReflectivity = 1.0 - specularMonochrome;
					//light
					float3 indirectSpecular = texCUBElod(_Cube, float4(viewReflectDirection, GlossToLod(gloss)));
					return PBR_FUNCTION(diffuseColor, specularColor, oneMinusReflectivity, smoothness,
						normalDirection, viewDirection,
						light, i.sh, indirectSpecular);
					//return NdotL;


				
				}
					ENDCG
				}

		}
			FallBack "Diffuse"
																																	CustomEditor "ShaderForgeMaterialInspector"
}
