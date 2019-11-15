#include "height-fog.cginc"
#include "SceneWeather.inc" 
#include "snow.cginc"
#include "SHGlobal.cginc"
#if SSS_EFFECT
#include "sss.cginc"
#endif
#if defined(_SCENE_SHADOW2)  
#include "shadowmap.cginc"
#endif

uniform float4 _Color;
uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
uniform sampler2D _BumpMap; uniform float4 _BumpMap_ST;
uniform float _MetallicPower;
uniform float _GlossPower;
uniform sampler2D _Metallic; uniform float4 _Metallic_ST;
uniform sampler2D GlobalSBL;

#if ALPHA_CLIP
half _AlphaClip;
#endif
float4 AmbientColor;

struct VertexInput {
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float2 texcoord0 : TEXCOORD0;
	float2 texcoord1 : TEXCOORD1;
 
};
struct VertexOutput {
	float4 pos : SV_POSITION;
	float2 uv0 : TEXCOORD0;
	float2 uv2 : TEXCOORD1;
 
	float4 posWorld : TEXCOORD3;
	float3 normalDir : TEXCOORD4;
	float3 tangentDir : TEXCOORD5;
	float3 bitangentDir : TEXCOORD6;

	LIGHTING_COORDS(7, 8)
 
	UNITY_FOG_COORDS_EX(9)
#if defined(_SCENE_SHADOW2) 
	float4 shadowCoord : TEXCOORD10;
#endif
	float3 ambient :TEXCOORD11;
};
VertexOutput vert(VertexInput v) {
	VertexOutput o = (VertexOutput)0;
	o.uv0 = v.texcoord0;

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	o.uv2 = v.texcoord1 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
	o.uv2 = v.texcoord1;
#endif
 
	o.normalDir = UnityObjectToWorldNormal(v.normal);
	o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
	o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
	o.posWorld = mul(unity_ObjectToWorld, v.vertex);
	float3 lightColor = _LightColor0.rgb;
	o.pos = UnityObjectToClipPos(v.vertex);
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	o.ambient = 0;

#else

	#if GLOBAL_SH9
		o.ambient = g_sh(half4(o.normalDir, 1));
		 
	#else
		o.ambient = ShadeSH9(half4(o.normalDir, 1));
	#endif
		//o.ambient = ShadeSH9(half4(o.normalDir, 1));
#endif
		o.ambient *= AmbientColor.rgb*AmbientColor.a;
	
	//UNITY_TRANSFER_FOG(o, o.pos);
	TRANSFER_VERTEX_TO_FRAGMENT(o)
		UNITY_TRANSFER_FOG_EX(o, o.pos, o.posWorld, o.normalDir);

#if defined(_SCENE_SHADOW2) 
	o.shadowCoord = mul(_depthVPBias, mul(unity_ObjectToWorld, v.vertex));
	o.shadowCoord.z = -(mul(_depthV, mul(unity_ObjectToWorld, v.vertex)).z * _farplaneScale);
#endif
		return o;
}


inline half UnitySmithJointGGXVisibilityTerm(half NdotL, half NdotV, half roughness)
{
	// Approximation of the above formulation (simplify the sqrt, not mathematically correct but close enough)
	half a = roughness;
	half lambdaV = NdotL * (NdotV * (1 - a) + a);
	half lambdaL = NdotV * (NdotL * (1 - a) + a);
	return 0.5f / (lambdaV + lambdaL + 1e-5f);
 
}

inline half UnityGGXTerm(half NdotH, half roughness)
{
	half a2 = roughness * roughness;
	half d = (NdotH * a2 - NdotH) * NdotH + 1.0f; // 2 mad
	return UNITY_INV_PI * a2 / (d * d + 1e-7f); // This function is not intended to be running on Mobile,
											// therefore epsilon is smaller than what can be represented by half
}
inline half3 UnityFresnelTerm(half3 F0, half cosA)
{
	half t = Pow5(1 - cosA);   // ala Schlick interpoliation
	return F0 + (1 - F0) * t;
}
float computeSpecularAO(float NoV, float ao, float roughness) {
	return clamp(pow(NoV + ao, exp2(-16.0 * roughness - 1.0)) - 1.0 + ao, 0.0, 1.0);
}

//这个是unity。
inline float2 ToRadialCoords(float3 coords)
{
	float3 normalizedCoords = normalize(coords);
	float latitude = acos(normalizedCoords.y);
	float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
	float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
	return float2(0.5, 1.0) - sphereCoords;
}

inline half3 UnityDiffuseAndSpecularFromMetallic(half3 albedo, half metallic, out half3 specColor, out half oneMinusReflectivity)
{
	specColor = lerp(unity_ColorSpaceDielectricSpec.rgb, albedo, metallic);
	oneMinusReflectivity = OneMinusReflectivityFromMetallic(metallic);
	return albedo * oneMinusReflectivity;
}
inline half GlossToLod(float gloss )
{
	float roughness = 1.0 - gloss;
	half perceptualRoughness = roughness /* perceptualRoughness */;
	perceptualRoughness = perceptualRoughness * (1.7 - 0.7*perceptualRoughness);
	//UNITY_SPECCUBE_LOD_STEPS = 6
	return perceptualRoughness * UNITY_SPECCUBE_LOD_STEPS;
}
#if ANISOTROPIC_NORMAL
float sqr(float x)
{
	return x * x;
}
float TrowbridgeReitzAnisotropicNormalDistribution(float _Glossiness, float anisotropic, float NdotH, float HdotT, float HdotB) {
	float aspect = sqrt(1.0h - anisotropic * 0.9h);
	float X = max(.001, sqr(1.0 - _Glossiness) / aspect) * 5;
	float Y = max(.001, sqr(1.0 - _Glossiness)*aspect) * 5;
	return 1.0 / (3.1415926535 * X*Y * sqr(sqr(HdotT / X) + sqr(HdotB / Y) + NdotH * NdotH));
}
float anisotropy;
#endif
float4 frag(VertexOutput i) : COLOR{
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


#if _ISWEATHER_ON
	
	#if SNOW_ENABLE 
		fixed nt;
		CmpSnowNormalAndPower (i.uv0, i.normalDir.xyz, nt, normalDirection);
	#endif
#endif

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
		fixed3 lightmap = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
#if defined (SHADOWS_SHADOWMASK)
		float3 attenuation = UNITY_SAMPLE_TEX2D(unity_ShadowMask, i.uv2).rrr;
#else
	//float3 attenuation = min(min(lightmap.r, lightmap.g),lightmap.b);
	float3 attenuation = saturate( dot(lightmap,float3(0.3,0.6,0.1)) );
	 
		//
#endif
#else

	 float3 attenuation = LIGHT_ATTENUATION(i);
#endif

#if defined(_SCENE_SHADOW2)  
	 half3 attenuation2 = PCF4SamplesSafe(i.shadowCoord).xxx;
	 attenuation = min(attenuation, attenuation2);
	 //return float4(lightColor.rgb,1);
	 //return float4(attenuation2, attenuation2, attenuation2, 1);
#endif

	float3 attenColor = attenuation * _LightColor0.xyz;

 
 
	float Pi = 3.141592654;
	float InvPi = 0.31830988618;
	///////// Gloss:
#if NO_CTRL_TEXTURE
	float4 _Metallic_var = float4(1,0,0,1);
#else
	float4 _Metallic_var = tex2D(_Metallic, TRANSFORM_TEX(i.uv0, _Metallic));
#endif
	
	float gloss = (_Metallic_var.a*_GlossPower);


#if _ISWEATHER_ON
	#if RAIN_ENABLE  
		gloss = saturate(gloss* get_smoothnessRate());
	#endif
	#if(SNOW_ENABLE)
		gloss = lerp(gloss, _SnowGloss, nt);
	#endif
#endif

	float perceptualRoughness = 1.0 - (_Metallic_var.a*_GlossPower);
	float roughness = perceptualRoughness * perceptualRoughness;
	 
	float _Meta = (_Metallic_var.r*_MetallicPower);

#if _ISMETALLIC_OFF
	float3 specularColor = 0;
#else
	float3 specularColor = _Meta;
#endif
	
	

	
	float specularMonochrome;
	float4 _MainTex_var = tex2D(_MainTex, TRANSFORM_TEX(i.uv0, _MainTex));

	float3 baseDiffuseColor = (_MainTex_var.rgb*_Color.rgb); // Need this for specular when using metallic


#if ALPHA_CLIP
	clip(_MainTex_var.a*_Color.a - _AlphaClip);
#endif
	float3 diffuseColor = UnityDiffuseAndSpecularFromMetallic(baseDiffuseColor, specularColor, specularColor, specularMonochrome);
#if _ISWEATHER_ON
#if RAIN_ENABLE 

	calc_weather_info(i.posWorld.xyz, normalDirection, _BumpMap_var, diffuseColor, normalDirection, diffuseColor.rgb);
#endif
#endif

	float NdL = dot(normalDirection, lightDirection);
	 
#if BACK_LIGHT_DIFFUSE
	float s = (2 * step(-0.001f, NdL) - 1);
	normalDirection *= s;
	NdL *= s;
#endif

	////// Specular:
	float NdotL = saturate(NdL);
	float LdotH = saturate(dot(lightDirection, halfDirection));
	

#if _ISWEATHER_ON
	#if SNOW_ENABLE 
		diffuseColor.rgb = lerp(diffuseColor.rgb, _SnowColor.rgb, nt *_SnowColor.a);
	#endif
#endif
	float NdotV = abs(dot(normalDirection, viewDirection));
	specularMonochrome = 1.0 - specularMonochrome;
	
	float NdotH = saturate(dot(normalDirection, halfDirection));
 

#if ANISOTROPIC_NORMAL
	
#if 1
	float3 bitangentDir = normalize(cross(normalDirection, i.tangentDir.xyz));
	float3 tangentDir = normalize(cross(normalDirection, bitangentDir.xyz));
	float HdotT = dot(tangentDir.xyz, halfDirection);
	float HdotB = dot(bitangentDir.xyz, halfDirection);
#else
	float HdotT = dot(i.tangentDir.xyz, halfDirection);
	float HdotB = dot(i.bitangentDir.xyz, halfDirection);
#endif
		//float3 directSpecular = attenColor * specularPBL*specularColor;
	float normTerm = TrowbridgeReitzAnisotropicNormalDistribution(gloss, anisotropy, NdotH, HdotT, HdotB);
	//float normTerm = UnityGGXTerm(NdotH, roughness);
#else
	float normTerm = UnityGGXTerm(NdotH, roughness);
#endif
	

	
#if NORM_TERM_ONLY
	//float visTerm = UnitySmithJointGGXVisibilityTerm(NdotL, NdotV, roughness);
	float visTerm = roughness ;
#else
	float visTerm = UnitySmithJointGGXVisibilityTerm(NdotL, NdotV, roughness);
#endif
	 
	float specularPBL = (visTerm*normTerm) * UNITY_PI;
 
	#ifdef UNITY_COLORSPACE_GAMMA
		specularPBL = sqrt(max(1e-4h, specularPBL));
	#endif
	specularPBL = max(0, specularPBL * NdotL);
 
	specularPBL *= any(specularColor) ? 1.0 : 0.0;
#if NORM_TERM_ONLY
	float3 directSpecular = attenColor * specularPBL*specularColor;
 
	//float3 directSpecular = attenColor * specularPBL*UnityFresnelTerm(specularColor, LdotH);
#else
	float3 directSpecular = attenColor * specularPBL*UnityFresnelTerm(specularColor, LdotH);
	
#endif
	//return directSpecular.rrrr;
	half grazingTerm = saturate(gloss + specularMonochrome);
	
#if _ISMETALLIC_OFF
	float3 indirectSpecular = 0;
 
#else
	//half GlossToLod(float gloss )
	half4 skyUV = half4(ToRadialCoords(viewReflectDirection), 0, GlossToLod(gloss));
	//half4 skyUV = half4(ToRadialCoords(viewReflectDirection), 0,  perceptualRoughness * 8);
	float3 indirectSpecular = tex2Dlod(GlobalSBL, skyUV).rgb;
	#if _ISWEATHER_ON
		#if SNOW_ENABLE 
			indirectSpecular.rgb = lerp(indirectSpecular.rgb, _SnowColor.rgb, nt *_SnowColor.a);
		#endif
	#endif
#endif

	
	indirectSpecular *= FresnelLerp(specularColor, grazingTerm, NdotV);
	
#if CHARACTER_ON
	half surfaceReduction;
	#ifdef UNITY_COLORSPACE_GAMMA
		surfaceReduction = 1.0 - 0.28*roughness*perceptualRoughness;
	#else
		surfaceReduction = 1.0 / (roughness*roughness + 1.0);
	#endif

	indirectSpecular *= surfaceReduction;
#else
	indirectSpecular *= _Meta;
#endif
	
	//return float4(indirectSpecular, 1);
	_Metallic_var.b = 1;
	float3 specular = (directSpecular + indirectSpecular) *_Metallic_var.b;
	
	/////// Diffuse:
	
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	 
	#if defined (SHADOWS_SHADOWMASK)
		float3 directDiffuse = NdotL * attenColor + lightmap;
	#else
		float3 directDiffuse =  lightmap;
		//return float4(lightmap, 1);
	
	#endif
 
#else

	#if SSS_EFFECT
		half3 brdf = sss_from_lut(NdotL, normalDirection, i.posWorld, _LightColor0.rgb);
		float3 directDiffuse = lerp(NdotL, brdf, _Metallic_var.b*_S3SPower) * attenColor;
		//float3 directDiffuse = NdotL * attenColor;
	#else
		float3 directDiffuse = NdotL * attenColor;
	#endif
#endif
	 
	float3 indirectDiffuse  = i.ambient;
 
	//return float4(indirectDiffuse, 1);
#if SSS_EFFECT
	float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
#else
	float3 diffuse = (directDiffuse*_Metallic_var.b + indirectDiffuse) * diffuseColor;
#endif
	
	////// Emissive:
	float3 emissive = baseDiffuseColor * _Metallic_var.g;
 
	/// Final Color:
	float3 finalColor = diffuse + specular + emissive;
 
 
	fixed4 c = fixed4(finalColor,1);

#if GLOBAL_ENV_SH9
	float3 l__viewDir = lerp(-viewDirection, float3(0, -1, 0), globalEnvOffset);
	APPLY_HEIGHT_FOG_EX(c, i.posWorld, envsh9(l__viewDir), i.fogCoord);
#else
	
	APPLY_HEIGHT_FOG(c, i.posWorld, normalDirection, i.fogCoord);
#endif

	UNITY_APPLY_FOG_MOBILE(i.fogCoord, c);
 

	c.a = _MainTex_var.a;
	//return c.aaaa;
	return c;
}