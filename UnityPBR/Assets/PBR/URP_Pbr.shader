Shader "Lch/URPBrdf"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_Tint("Tint", Color) = (1 ,1 ,1 ,1)
		[Gamma] _Metallic("Metallic", Range(0, 1)) = 0 //金属度要经过伽马校正
		_Smoothness("Smoothness", Range(0, 1)) = 0.5
		_LUT("LUT", 2D) = "white" {}
		[Toggle(OLD_PBR)] OLD_PBR("老pbr", Int) = 0
	}


		SubShader
	{
		Pass
		{
			Tags { "LightMode"="ForwardBase"} //第一步//

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#define FORWARD_BASE_PASS
			#pragma multi_compile  LIGHTPROBE_SH
			#pragma multi_compile  DIRECTIONAL
			#pragma multi_compile  SHADOWS_SHADOWMASK
			#pragma multi_compile LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SCREEN 
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile  _  OLD_PBR

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc" //第三步// 
			//#include "UnityStandardCore.cginc"
			#include "shadows.cginc"
			#include "UnityImageBasedLighting.cginc" 
			#include "UnityStandardBRDF.cginc" 

			struct appdata
			{
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				half2 uv1 : TEXCOORD1;
				half3 normal : NORMAL;
				half4 tangent : TANGENT;
			};

			struct v2f
			{
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				half3 tspace0 : TEXCOORD2;
				half3 tspace1 : TEXCOORD3;
				half3 tspace2 : TEXCOORD4;
				float3 worldPos : TEXCOORD5;

 
				half4 ambientOrLightmapUV           : TEXCOORD6;
				SHADOW_COORDS(7)
 
			};
			//sampler2D unity_NHxRoughness;
			float4 _Tint;
			sampler2D _MainTex;
			half4 _MainTex_ST;
			sampler2D _Normal;

			sampler2D _LUT;
			float _Metallic;
			float _Smoothness;
			sampler2D _SpecMap;
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldPos = worldPos;

				half3 normal = UnityObjectToWorldNormal(v.normal);
				half3 tangent = UnityObjectToWorldDir(v.tangent.xyz);
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 bitangent = cross(normal, tangent) * tangentSign;

				o.tspace0 = half3(tangent.x, bitangent.x, normal.x);
				o.tspace1 = half3(tangent.y, bitangent.y, normal.y);
				o.tspace2 = half3(tangent.z, bitangent.z, normal.z);
				o.ambientOrLightmapUV = VertexGIForward(v.uv1, worldPos, normal);
		 
				TRANSFER_SHADOW(o);
				TRANSFER_VERTEX_TO_FRAGMENT(o); //第5步// 

				UNITY_TRANSFER_FOG(o, o.pos);
				return o;
			}

			float3 fresnelSchlickRoughness(float cosTheta, float3 reflectSpecular, float roughness)
			{
				return reflectSpecular + (max(float3(1 ,1, 1) * (1 - roughness), reflectSpecular) - reflectSpecular) * pow(1.0 - cosTheta, 5.0);
			}
			#define HALF_MIN 6.103515625e-5  // 2^-14, the same value for 10, 11 and 16-bit: https://www.khronos.org/opengl/wiki/Small_Float_Formats

			fixed4 frag(v2f i) : SV_Target
			{
 
				half3 n = UnpackNormal(tex2D(_Normal, i.uv));
				half3 normal;
				normal.x = dot(i.tspace0, n);
				normal.y = dot(i.tspace1, n);
				normal.z = dot(i.tspace2, n);
				normal = normalize(normal);

				half shadowMaskAttenuation = UnitySampleBakedOcclusion(i.ambientOrLightmapUV, 0);
				half realtimeShadowAttenuation = SHADOW_ATTENUATION(i);
				float zDist = dot(_WorldSpaceCameraPos - i.worldPos, UNITY_MATRIX_V[2].xyz);
				float fadeDist = UnityComputeShadowFadeDistance(i.worldPos, zDist);
				half atten = UnityMixRealtimeAndBakedShadows(realtimeShadowAttenuation, shadowMaskAttenuation, UnityComputeShadowFade(fadeDist));
			
			
			
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				float3 lightColor = _LightColor0.rgb;
				float3 halfVector = normalize(lightDir + viewDir);  //半角向量

				float perceptualRoughness = 1 - _Smoothness;

				float roughness = max(perceptualRoughness * perceptualRoughness ,HALF_MIN);
				float squareRoughness = roughness * roughness;

				float NDotL = max(saturate(dot(normal, lightDir)), HALF_MIN);//防止除0
				float NDotV = max(saturate(dot(normal, viewDir)), HALF_MIN);
				float VDotH = max(saturate(dot(viewDir, halfVector)), HALF_MIN);
				float LDotH = max(saturate(dot(lightDir, halfVector)), HALF_MIN);
				float nDotH = max(saturate(dot(normal, halfVector)), HALF_MIN);

				float3 Albedo = _Tint * tex2D(_MainTex, i.uv);
				float3 reflectSpecular = lerp(unity_ColorSpaceDielectricSpec.rgb, Albedo, _Metallic);

				#if  OLD_PBR
					float lerpSquareRoughness = pow(lerp(0.002, 1, roughness), 2);
					float D = lerpSquareRoughness / (pow((pow(nDotH, 2) * (lerpSquareRoughness - 1) + 1), 2) * UNITY_PI);
					float kInDirectLight = pow(squareRoughness + 1, 2) / 8;
					float kInIBL = pow(squareRoughness, 2) / 8;
					float GLeft = NDotL / lerp(NDotL, 1, kInDirectLight);
					float GRight = NDotV / lerp(NDotV, 1, kInDirectLight);
					float G = GLeft * GRight;
					float3 F = reflectSpecular + (1 - reflectSpecular) * exp2((-5.55473 * VDotH - 6.98316) * VDotH);
					float3 SpecularResult = (D * G * F * 0.25) / (NDotV * NDotL);
			
					#if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
						specularTerm = specularTerm - HALF_MIN;
						specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
					#endif
					SpecularResult *=UNITY_PI;
	  
				#else
					half LoH2 = LDotH * LDotH;
					half roughness2MinusOne = squareRoughness - 1.0h;
					half d = nDotH * nDotH * roughness2MinusOne + 1.00001f;
					// https://community.arm.com/events/1155
					// D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
					//D = squareRoughness / (d*d);
					// V * F = 1.0 / ( LoH^2 * (roughness + 0.5) )
					//VF = 1.0/  ( max(0.1h, LoH2)  * (roughness +0.5 )  );  
					// BRDFspec = (D * V * F) / 4.0
					//BRDFspec =  squareRoughness /   ( (d*d)  *   ( max(0.1h, LoH2)  * (roughness*4 +2)  )   );
					half normalizationTerm = roughness * 4.0h + 2.0h;			 
					half specularTerm = squareRoughness / ((d * d) * max(0.1h, LoH2) *  normalizationTerm);

					#if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
						specularTerm = specularTerm - HALF_MIN;
						specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
					#endif

					float3 SpecularResult = specularTerm * reflectSpecular  ;
				#endif
 
				#if  OLD_PBR
					half3 oneMinusReflectivity = (1 - F)*(1 - _Metallic);
					//half oneMinusDielectricSpec = unity_ColorSpaceDielectricSpec.a;
					//half3 oneMinusReflectivity =  oneMinusDielectricSpec - _Metallic * oneMinusDielectricSpec;

				#else
					half oneMinusDielectricSpec = unity_ColorSpaceDielectricSpec.a;
					half3 oneMinusReflectivity =  oneMinusDielectricSpec - _Metallic * oneMinusDielectricSpec;
				#endif
				
				half3 _Diffuse = oneMinusReflectivity * Albedo;
				half3 DirectLightResult = SpecularResult + _Diffuse*lightColor * NDotL  *atten;
 
				#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
					half2 lightmapUV = i.ambientOrLightmapUV.xy;
					half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, lightmapUV.xy);
					half3 bakedColor = DecodeLightmap(bakedColorTex);
					half3 iblDiffuse = bakedColor;
				#else
					half3 iblDiffuse = i.ambientOrLightmapUV.rgb;
				#endif 

 
				float3 reflectVec = reflect(-viewDir, normal);
				float mip_roughness = perceptualRoughness * (1.7 - 0.7 * perceptualRoughness);
				half mip = mip_roughness * UNITY_SPECCUBE_LOD_STEPS;
				half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectVec, mip);
				float3 iblSpecular = DecodeHDR(rgbm, unity_SpecCube0_HDR);

				#if  OLD_PBR
					 //间接高光.
					float2 envBDRF = tex2D(_LUT, float2(NDotV, roughness )).rg; // LUT采样
					float3 Flast = fresnelSchlickRoughness(max(NDotV, 0.0), reflectSpecular, roughness);
					float3 iblSpecularResult = iblSpecular * (Flast * envBDRF.r + envBDRF.g) ;
					//间接漫射.
					//float kdLast = (1 - Flast) * (1 - _Metallic);
					//float3 iblDiffuseResult = iblDiffuse * kdLast * Albedo;
					float3 iblDiffuseResult = iblDiffuse * _Diffuse;
				#else
					half fresnelTerm = 1.0 - NDotV;
					fresnelTerm = fresnelTerm*fresnelTerm*fresnelTerm*fresnelTerm;
					float surfaceReduction = 1.0 / (squareRoughness + 1.0);
					float reflectivity = 1.0 - oneMinusReflectivity;
					float  grazingTerm = saturate(_Smoothness + reflectivity);
					float3  iblSpecularResult = iblSpecular*surfaceReduction * lerp(reflectSpecular, grazingTerm, fresnelTerm);
					float3 iblDiffuseResult = iblDiffuse * _Diffuse;
				#endif

				float3 IndirectResult =  iblDiffuseResult  +    iblSpecularResult ;
				float4 result = float4(DirectLightResult + IndirectResult, 1);
				return result;
			}
			ENDCG
	}
	UsePass "Mobile/VertexLit/ShadowCaster"
	}
}
