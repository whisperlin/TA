Shader "Lch/BrdfLut"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_Tint("Tint", Color) = (1 ,1 ,1 ,1)
		[Gamma] _Metallic("Metallic", Range(0, 1)) = 0 //金属度要经过伽马校正
		_Smoothness("Smoothness", Range(0, 1)) = 0.5
		_LUT("LUT", 2D) = "white" {}
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

		 float3 fresnelSchlickRoughness(float cosTheta, float3 F0, float roughness)
			{
				return F0 + (max(float3(1 ,1, 1) * (1 - roughness), F0) - F0) * pow(1.0 - cosTheta, 5.0);
			}
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

				float roughness = perceptualRoughness * perceptualRoughness;
				float squareRoughness = roughness * roughness;

				float nl = max(saturate(dot(normal, lightDir)), 0.000001);//防止除0
				float nv = max(saturate(dot(normal, viewDir)), 0.000001);
				float vh = max(saturate(dot(viewDir, halfVector)), 0.000001);
				float lh = max(saturate(dot(lightDir, halfVector)), 0.000001);
				float nh = max(saturate(dot(normal, halfVector)), 0.000001);

				float3 Albedo = _Tint * tex2D(_MainTex, i.uv);

				float lerpSquareRoughness = pow(lerp(0.002, 1, roughness), 2);//Unity把roughness lerp到了0.002
				float D = lerpSquareRoughness / (pow((pow(nh, 2) * (lerpSquareRoughness - 1) + 1), 2) * UNITY_PI);

				float kInDirectLight = pow(squareRoughness + 1, 2) / 8;
				float kInIBL = pow(squareRoughness, 2) / 8;
				float GLeft = nl / lerp(nl, 1, kInDirectLight);
				float GRight = nv / lerp(nv, 1, kInDirectLight);
				float G = GLeft * GRight;

				float3 F0 = lerp(unity_ColorSpaceDielectricSpec.rgb, Albedo, _Metallic);
				float3 F = F0 + (1 - F0) * exp2((-5.55473 * vh - 6.98316) * vh);

				float3 SpecularResult = (D * G * F * 0.25) / (nv * nl);

				//漫反射系数
				float3 kd = (1 - F)*(1 - _Metallic);
			 

				//直接光照部分结果
				float3 specColor = SpecularResult * lightColor * nl * UNITY_PI;
				float3 diffColor = kd * Albedo * lightColor * nl * atten;
				float3 DirectLightResult = diffColor + specColor;

 


				#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
	 
				half2 lightmapUV = i.ambientOrLightmapUV.xy;

				// Baked lightmaps
				half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, lightmapUV.xy);
				half3 bakedColor = DecodeLightmap(bakedColorTex);
				half3 iblDiffuse = bakedColor;

				#else
				half3 iblDiffuse = i.ambientOrLightmapUV.rgb;
 
				#endif 

 

				 
			 

				float mip_roughness = perceptualRoughness * (1.7 - 0.7 * perceptualRoughness);
				float3 reflectVec = reflect(-viewDir, normal);

				half mip = mip_roughness * UNITY_SPECCUBE_LOD_STEPS;
				half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectVec, mip);
			 
				float3 iblSpecular = DecodeHDR(rgbm, unity_SpecCube0_HDR);

				float2 envBDRF = tex2D(_LUT, float2(nv, roughness )).rg; // LUT采样

				float3 Flast = fresnelSchlickRoughness(max(nv, 0.0), F0, roughness);
				float kdLast = (1 - Flast) * (1 - _Metallic);

				float3 iblDiffuseResult = iblDiffuse * kdLast * Albedo;
 
				float3 iblSpecularResult = iblSpecular * (Flast * envBDRF.r + envBDRF.g) ;

			
				float3 IndirectResult = iblDiffuseResult + iblSpecularResult;

				

				float4 result = float4(DirectLightResult + IndirectResult, 1);

				return result;

			// apply fog
			//UNITY_APPLY_FOG(i.fogCoord, c);
			//return c;
		}
		ENDCG
	}
	UsePass "Mobile/VertexLit/ShadowCaster"

								 

	}
	 
}

			 

		
