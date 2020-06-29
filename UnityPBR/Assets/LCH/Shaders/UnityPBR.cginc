#ifndef UNITY_PBR_CGINC
#define UNITY_PBR_CGINC 1
#include "Lighting.cginc"
#include "UnityStandardBRDF.cginc"


inline half GlossToLod(float gloss)
{
	float roughness = 1.0 - gloss;
	half perceptualRoughness = roughness /* perceptualRoughness */;
	perceptualRoughness = perceptualRoughness * (1.7 - 0.7*perceptualRoughness);
	//UNITY_SPECCUBE_LOD_STEPS = 6
	return perceptualRoughness * UNITY_SPECCUBE_LOD_STEPS;
}


 

half4 BRDF1_Unity_PBS_MOD(half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
	half3 normal, half3 viewDir,
	UnityLight light, float3 sh9, float3 indirSp)
{
	half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness);
	half3 halfDir = Unity_SafeNormalize(light.dir + viewDir);

	// NdotV should not be negative for visible pixels, but it can happen due to perspective projection and normal mapping
	// In this case normal should be modified to become valid (i.e facing camera) and not cause weird artifacts.
	// but this operation adds few ALU and users may not want it. Alternative is to simply take the abs of NdotV (less correct but works too).
	// Following define allow to control this. Set it to 0 if ALU is critical on your platform.
	// This correction is interesting for GGX with SmithJoint visibility function because artifacts are more visible in this case due to highlight edge of rough surface
	// Edit: Disable this code by default for now as it is not compatible with two sided lighting used in SpeedTree.
#define UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV 0

#if UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV
	// The amount we shift the normal toward the view vector is defined by the dot product.
	half shiftAmount = dot(normal, viewDir);
	normal = shiftAmount < 0.0f ? normal + viewDir * (-shiftAmount + 1e-5f) : normal;
	// A re-normalization should be applied here but as the shift is small we don't do it to save ALU.
	//normal = normalize(normal);

	half nv = saturate(dot(normal, viewDir)); // TODO: this saturate should no be necessary here
#else
	half nv = abs(dot(normal, viewDir));    // This abs allow to limit artifact
#endif

	half nl = saturate(dot(normal, light.dir));
	half nh = saturate(dot(normal, halfDir));

	half lv = saturate(dot(light.dir, viewDir));
	half lh = saturate(dot(light.dir, halfDir));

	// Diffuse term
	half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;

	// Specular term
	// HACK: theoretically we should divide diffuseTerm by Pi and not multiply specularTerm!
	// BUT 1) that will make shader look significantly darker than Legacy ones
	// and 2) on engine side "Non-important" lights have to be divided by Pi too in cases when they are injected into ambient SH
	half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
#if UNITY_BRDF_GGX
	half V = SmithJointGGXVisibilityTerm(nl, nv, roughness);
	half D = GGXTerm(nh, roughness);
#else
	// Legacy
	half V = SmithBeckmannVisibilityTerm(nl, nv, roughness);
	half D = NDFBlinnPhongNormalizedTerm(nh, PerceptualRoughnessToSpecPower(perceptualRoughness));
#endif

	half specularTerm = V * D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later

#   ifdef UNITY_COLORSPACE_GAMMA
	specularTerm = sqrt(max(1e-4h, specularTerm));
#   endif

	// specularTerm * nl can be NaN on Metal in some cases, use max() to make sure it's a sane value
	specularTerm = max(0, specularTerm * nl);
#if defined(_SPECULARHIGHLIGHTS_OFF)
	specularTerm = 0.0;
#endif

	// surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
	half surfaceReduction;
#   ifdef UNITY_COLORSPACE_GAMMA
	surfaceReduction = 1.0 - 0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
#   else
	surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
#   endif

	// To provide true Lambert lighting, we need to be able to kill specular completely.
	specularTerm *= any(specColor) ? 1.0 : 0.0;

	half grazingTerm = saturate(smoothness + (1 - oneMinusReflectivity));
	half3 color = diffColor * (sh9 + light.color * diffuseTerm)
		+ specularTerm * light.color * FresnelTerm(specColor, lh)
		+ surfaceReduction * indirSp * FresnelLerp(specColor, grazingTerm, nv);

	return half4(color, 1);
}
 
half4 BRDF2_Unity_PBS_MOD(half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
	half3 normal, half3 viewDir,
	UnityLight light, float3 sh9, float3 indirSp)
{
	half3 halfDir = Unity_SafeNormalize(light.dir + viewDir);

	half nl = saturate(dot(normal, light.dir));
	half nh = saturate(dot(normal, halfDir));
	half nv = saturate(dot(normal, viewDir));
	half lh = saturate(dot(light.dir, halfDir));

	// Specular term
	half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness);
	half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

#if UNITY_BRDF_GGX

	// GGX Distribution multiplied by combined approximation of Visibility and Fresnel
	// See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
	// https://community.arm.com/events/1155
	half a = roughness;
	half a2 = a * a;

	half d = nh * nh * (a2 - 1.h) + 1.00001h;
#ifdef UNITY_COLORSPACE_GAMMA
	// Tighter approximation for Gamma only rendering mode!
	// DVF = sqrt(DVF);
	// DVF = (a * sqrt(.25)) / (max(sqrt(0.1), lh)*sqrt(roughness + .5) * d);
	half specularTerm = a / (max(0.32h, lh) * (1.5h + roughness) * d);
#else
	half specularTerm = a2 / (max(0.1h, lh*lh) * (roughness + 0.5h) * (d * d) * 4);
#endif

	// on mobiles (where half actually means something) denominator have risk of overflow
	// clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
	// sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
#if defined (SHADER_API_MOBILE)
	specularTerm = specularTerm - 1e-4h;
#endif

#else

	// Legacy
	half specularPower = PerceptualRoughnessToSpecPower(perceptualRoughness);
	// Modified with approximate Visibility function that takes roughness into account
	// Original ((n+1)*N.H^n) / (8*Pi * L.H^3) didn't take into account roughness
	// and produced extremely bright specular at grazing angles

	half invV = lh * lh * smoothness + perceptualRoughness * perceptualRoughness; // approx ModifiedKelemenVisibilityTerm(lh, perceptualRoughness);
	half invF = lh;

	half specularTerm = ((specularPower + 1) * pow(nh, specularPower)) / (8 * invV * invF + 1e-4h);

#ifdef UNITY_COLORSPACE_GAMMA
	specularTerm = sqrt(max(1e-4h, specularTerm));
#endif

#endif

#if defined (SHADER_API_MOBILE)
	specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
#endif
#if defined(_SPECULARHIGHLIGHTS_OFF)
	specularTerm = 0.0;
#endif

	// surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(realRoughness^2+1)

	// 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
	// 1-x^3*(0.6-0.08*x)   approximation for 1/(x^4+1)
#ifdef UNITY_COLORSPACE_GAMMA
	half surfaceReduction = 0.28;
#else
	half surfaceReduction = (0.6 - 0.08*perceptualRoughness);
#endif

	surfaceReduction = 1.0 - roughness * perceptualRoughness*surfaceReduction;

	half grazingTerm = saturate(smoothness + (1 - oneMinusReflectivity));
	half3 color = (diffColor + specularTerm * specColor) * light.color * nl
		+ sh9 * diffColor
		+ surfaceReduction * indirSp * FresnelLerpFast(specColor, grazingTerm, nv);

	return half4(color, 1);
}

half3 BRDF3_Direct_mod(half3 diffColor, half3 specColor, half rlPow4, half smoothness)
{
	half LUT_RANGE = 16.0; // must match range in NHxRoughness() function in GeneratedTextures.cpp
	// Lookup texture to save instructions
	half specular = tex2D(unity_NHxRoughness, half2(rlPow4, SmoothnessToPerceptualRoughness(smoothness))).UNITY_ATTEN_CHANNEL * LUT_RANGE;
#if defined(_SPECULARHIGHLIGHTS_OFF)
	specular = 0.0;
#endif

	
#ifdef UNITY_COLORSPACE_GAMMA
	specular = sqrt(max(1e-4h, specular));
#endif
	
	return diffColor + specular * specColor;
}
half3 BRDF3_Indirect(half3 diffColor, half3 specColor, float3 sh9, float3 indirSp, half grazingTerm, half fresnelTerm)
{
	half3 c = sh9 * diffColor;
	c += indirSp * lerp(specColor, grazingTerm, fresnelTerm);
	return c;
}
half4 BRDF3_Unity_PBS_MOD(half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
	half3 normal, half3 viewDir,
	UnityLight light, float3 sh9, float3 indirSp)
{
	half3 reflDir = reflect(viewDir, normal);

	half nl = saturate(dot(normal, light.dir));
	half nv = saturate(dot(normal, viewDir));
	// Vectorize Pow4 to save instructions
	half2 rlPow4AndFresnelTerm = Pow4(half2(dot(reflDir, light.dir), 1 - nv));  // use R.L instead of N.H to save couple of instructions
	half rlPow4 = rlPow4AndFresnelTerm.x; // power exponent must match kHorizontalWarpExp in NHxRoughness() function in GeneratedTextures.cpp
	half fresnelTerm = rlPow4AndFresnelTerm.y;



	half grazingTerm = saturate(smoothness + (1 - oneMinusReflectivity));

	half3 color = BRDF3_Direct_mod(diffColor, specColor, rlPow4, smoothness);
	color *= light.color * nl;
	color += BRDF3_Indirect(diffColor, specColor, sh9, indirSp, grazingTerm, fresnelTerm);

	return half4(color, 1);
}
 


	#if _PBR_TYPE1
		#define PBR_FUNCTION BRDF1_Unity_PBS_MOD
	#elif _PBR_TYPE2
		#define PBR_FUNCTION BRDF2_Unity_PBS_MOD
	#else
		#define PBR_FUNCTION BRDF3_Unity_PBS_MOD
	#endif






half Unity_PBR3(float smoothness, float reflectivity, float3 Normal, float3 lightDir, float3 viewDir)
{
	half roughness = 1 - smoothness;
	half oneMinusReflectivity = 1 - reflectivity;
	half3 reflDir = reflect(viewDir, Normal);
	half nl = saturate(dot(Normal, lightDir));
	half nv = saturate(dot(Normal, viewDir));

	half2 rlPow4AndFresnelTerm = Pow4(half2(dot(reflDir, lightDir), 1 - nv));
	half rlPow4 = rlPow4AndFresnelTerm.x;
	//half fresnelTerm = rlPow4AndFresnelTerm.y;
	//half grazingTerm = saturate(smoothness + reflectivity);

	half LUT_RANGE = 16.0;
	half specular = tex2D(unity_NHxRoughness, half2(rlPow4, roughness)).UNITY_ATTEN_CHANNEL * LUT_RANGE;
	return specular;
 
}
half4 Unity_PBS(half3 specColor, half oneMinusReflectivity, half smoothness,
	half3 normal, half3 viewDir,
	UnityLight light)
{
	half3 halfDir = Unity_SafeNormalize(light.dir + viewDir);

	half nl = saturate(dot(normal, light.dir));
	half nh = saturate(dot(normal, halfDir));
	half nv = saturate(dot(normal, viewDir));
	half lh = saturate(dot(light.dir, halfDir));

	// Specular term
	half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness);
	half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
#if UNITY_BRDF_GGX

	// GGX Distribution multiplied by combined approximation of Visibility and Fresnel
	// See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
	// https://community.arm.com/events/1155
	half a = roughness;
	half a2 = a * a;
	half d = nh * nh * (a2 - 1.h) + 1.00001h;
#ifdef UNITY_COLORSPACE_GAMMA
	// Tighter approximation for Gamma only rendering mode!
	// DVF = sqrt(DVF);
	// DVF = (a * sqrt(.25)) / (max(sqrt(0.1), lh)*sqrt(roughness + .5) * d);
	half specularTerm = a / (max(0.32h, lh) * (1.5h + roughness) * d);

	//b = fixHalf(b);
#else
	half specularTerm = a2 / (max(0.1h, lh*lh) * (roughness + 0.5h) * (d * d) * 4);
#endif
	// on mobiles (where half actually means something) denominator have risk of overflow
	// clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
	// sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
#if defined (SHADER_API_MOBILE)
	specularTerm = specularTerm - 1e-4h;
#endif

#else
	// Legacy
	half specularPower = PerceptualRoughnessToSpecPower(perceptualRoughness);
	// Modified with approximate Visibility function that takes roughness into account
	// Original ((n+1)*N.H^n) / (8*Pi * L.H^3) didn't take into account roughness
	// and produced extremely bright specular at grazing angles
	half invV = lh * lh * smoothness + perceptualRoughness * perceptualRoughness; // approx ModifiedKelemenVisibilityTerm(lh, perceptualRoughness);
	half invF = lh;
	half specularTerm = ((specularPower + 1) * pow(nh, specularPower)) / (8 * invV * invF + 1e-4h);
#ifdef UNITY_COLORSPACE_GAMMA
	specularTerm = sqrt(max(1e-4h, specularTerm));
#endif
#endif
#if defined (SHADER_API_MOBILE)
	specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
#endif
#if defined(_SPECULARHIGHLIGHTS_OFF)
	specularTerm = 0.0;
#endif
	half grazingTerm = saturate(smoothness + (1 - oneMinusReflectivity));
	half3 color = (specularTerm * specColor) * light.color * nl;

	return half4(color, 1);
}

#endif