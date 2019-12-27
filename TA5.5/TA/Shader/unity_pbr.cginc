#include "height-fog.cginc"
#include "SceneWeather.inc" 
#include "snow.cginc"
uniform float4 _Color;
uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
uniform sampler2D _BumpMap; uniform float4 _BumpMap_ST;
uniform float _MetallicPower;
uniform float _GlossPower;
uniform sampler2D _Metallic; uniform float4 _Metallic_ST;

#if ALPHA_CLIP
half _AlphaClip;
#endif


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
		//UNITY_FOG_COORDS(9)
		UNITY_FOG_COORDS_EX(9)
#if defined(LIGHTMAP_ON) || defined(UNITY_SHOULD_SAMPLE_SH)
		float4 ambientOrLightmapUV : TEXCOORD10;
#endif
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
	o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
	o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
	o.posWorld = mul(unity_ObjectToWorld, v.vertex);
	float3 lightColor = _LightColor0.rgb;
	o.pos = UnityObjectToClipPos(v.vertex);

	
	//UNITY_TRANSFER_FOG(o, o.pos);
	TRANSFER_VERTEX_TO_FRAGMENT(o)
		UNITY_TRANSFER_FOG_EX(o, o.pos, o.posWorld, o.normalDir);
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
	////// Lighting:
	float attenuation = LIGHT_ATTENUATION(i);
	float3 attenColor = attenuation * _LightColor0.xyz;
	float Pi = 3.141592654;
	float InvPi = 0.31830988618;
	///////// Gloss:
	float4 _Metallic_var = tex2D(_Metallic,TRANSFORM_TEX(i.uv0, _Metallic));
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
	float specPow = exp2(gloss * 10.0 + 1.0);

	float3 specularColor = (_Metallic_var.r*_MetallicPower);
#if _ISMETALLIC_OFF
	specularColor = 0;
#endif
	
	float specularMonochrome;
	float4 _MainTex_var = tex2D(_MainTex, TRANSFORM_TEX(i.uv0, _MainTex));


	float3 baseDiffuseColor = (_MainTex_var.rgb*_Color.rgb); // Need this for specular when using metallic
#if ALPHA_CLIP
	clip(_MainTex_var.a*_Color.a - _AlphaClip);
#endif
	float3 diffuseColor = DiffuseAndSpecularFromMetallic(baseDiffuseColor, specularColor, specularColor, specularMonochrome);

	/////// GI Data:
	UnityLight light;
	//#ifdef LIGHTMAP_OFF
		light.color = lightColor;
		light.dir = lightDirection;
		light.ndotl = LambertTerm(normalDirection, light.dir);
	//#else
	//	light.color = lightColor;
	//	light.dir = lightDirection;
	//	light.ndotl = LambertTerm(normalDirection, light.dir);
	//#endif

#if _ISWEATHER_ON
#if RAIN_ENABLE 
 
		calc_weather_info(i.posWorld.xyz, normalDirection, _BumpMap_var, diffuseColor, normalDirection, diffuseColor.rgb);
#endif
#endif
	UnityGIInput d;
	d.light = light;
	d.worldPos = i.posWorld.xyz;
	d.worldViewDir = viewDirection;
 
	 
	d.atten = attenuation;
	#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
		d.ambient = 0;
		d.lightmapUV = i.ambientOrLightmapUV;
	#else
		d.ambient = i.ambientOrLightmapUV;
	#endif
	#if UNITY_SPECCUBE_BLENDING || UNITY_SPECCUBE_BOX_PROJECTION
		d.boxMin[0] = unity_SpecCube0_BoxMin;
		d.boxMin[1] = unity_SpecCube1_BoxMin;
	#endif
	#if UNITY_SPECCUBE_BOX_PROJECTION
		d.boxMax[0] = unity_SpecCube0_BoxMax;
		d.boxMax[1] = unity_SpecCube1_BoxMax;
		d.probePosition[0] = unity_SpecCube0_ProbePosition;
		d.probePosition[1] = unity_SpecCube1_ProbePosition;
	#endif
	d.probeHDR[0] = unity_SpecCube0_HDR;
	d.probeHDR[1] = unity_SpecCube1_HDR;
	Unity_GlossyEnvironmentData ugls_en_data;
	ugls_en_data.roughness = 1.0 - gloss;
	ugls_en_data.reflUVW = viewReflectDirection;
	UnityGI gi = UnityGlobalIllumination(d, 1, normalDirection, ugls_en_data);
	lightDirection = gi.light.dir;
	lightColor = gi.light.color;
	////// Specular:
	float NdotL = saturate(dot(normalDirection, lightDirection));
	float LdotH = saturate(dot(lightDirection, halfDirection));
	


#if _ISWEATHER_ON
	#if SNOW_ENABLE 
		diffuseColor.rgb = lerp(diffuseColor.rgb, _SnowColor.rgb, nt *_SnowColor.a);
	#endif
#endif
	specularMonochrome = 1.0 - specularMonochrome;
	float NdotV = abs(dot(normalDirection, viewDirection));
	float NdotH = saturate(dot(normalDirection, halfDirection));
	float VdotH = saturate(dot(viewDirection, halfDirection));
	float visTerm = UnitySmithJointGGXVisibilityTerm(NdotL, NdotV, roughness);
	float normTerm = UnityGGXTerm(NdotH, roughness);
	float specularPBL = (visTerm*normTerm) * UNITY_PI;
	#ifdef UNITY_COLORSPACE_GAMMA
		specularPBL = sqrt(max(1e-4h, specularPBL));
	#endif
	specularPBL = max(0, specularPBL * NdotL);
	#if defined(_SPECULARHIGHLIGHTS_OFF)
		specularPBL = 0.0;
	#endif
	half surfaceReduction;
	#ifdef UNITY_COLORSPACE_GAMMA
		surfaceReduction = 1.0 - 0.28*roughness*perceptualRoughness;
	#else
		surfaceReduction = 1.0 / (roughness*roughness + 1.0);
	#endif
	specularPBL *= any(specularColor) ? 1.0 : 0.0;
	float3 directSpecular = attenColor * specularPBL*UnityFresnelTerm(specularColor, LdotH);
	half grazingTerm = saturate(gloss + specularMonochrome);
	
#if _ISMETALLIC_OFF
	float3 indirectSpecular = 0;
 
#else
	float3 indirectSpecular = (gi.indirect.specular);


	#if _ISWEATHER_ON
		#if SNOW_ENABLE 
			indirectSpecular.rgb = lerp(indirectSpecular.rgb, _SnowColor.rgb, nt *_SnowColor.a);
		#endif
	#endif
#endif
 
	indirectSpecular *= FresnelLerp(specularColor, grazingTerm, NdotV);
	indirectSpecular *= surfaceReduction;
	float3 specular = (directSpecular + indirectSpecular) *_Metallic_var.b;
	/////// Diffuse:
	NdotL = max(0.0,dot(normalDirection, lightDirection));
	half fd90 = 0.5 + 2 * LdotH * LdotH * (1 - gloss);
	float nlPow5 = Pow5(1 - NdotL);
	float nvPow5 = Pow5(1 - NdotV);
	float3 directDiffuse = ((1 + (fd90 - 1)*nlPow5) * (1 + (fd90 - 1)*nvPow5) * NdotL) * attenColor;
	float3 indirectDiffuse = float3(0,0,0);
	indirectDiffuse += gi.indirect.diffuse;
	float3 diffuse = (directDiffuse*_Metallic_var.b + indirectDiffuse) * diffuseColor;
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
 
 
	//UNITY_APPLY_FOG(i.fogCoord, c);
	return c;
}