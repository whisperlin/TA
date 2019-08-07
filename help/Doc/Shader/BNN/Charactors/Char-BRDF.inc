#define POINT_LIGHT_ENABLED			0
#define	LIGHT_ATTR_ITEM_NUM			5
#define LIGHT_NUM					4
#define SPECULAR_AA					1
#define SPECULAR_ENABLE				1

#include "UnityCG.cginc"

struct appdata
{
	fixed4 vertex : POSITION;
#ifdef COMBINE_MODE
	fixed4 color : COLOR;
#endif
	fixed2 uv : TEXCOORD0;
	float3 normal : NORMAL;
	fixed4 tangent : TANGENT;
};

struct PS_INPUT
{
	fixed4 final_position: SV_POSITION;
#ifdef COMBINE_MODE
	fixed4 color : COLOR;
#endif
	half2 uv0: TEXCOORD0;
	half4 v_world_position: TEXCOORD1;
	float3 v_world_normal: TEXCOORD2;
	half3 v_world_tangent: TEXCOORD3;
	float3 v_world_binormal: TEXCOORD4;
	UNITY_FOG_COORDS(5)
#if POINT_LIGHT_ENABLED
	half4 v_texture6: TEXCOORD7;
#endif
	half4 v_texture1: TEXCOORD8;
	half4 v_texture2: TEXCOORD9;
};


half4 _CC_LAPE;
half4 metallic_color;
half4 _CC_NMRB;
half4 _CC_WSAX;
half4 sss_scatter_color0;
half4x4 envSHR;
half4x4 envSHG;
half4x4 envSHB;
half4x4 envRot;
half4 ShadowLightAttr[LIGHT_ATTR_ITEM_NUM-1];
half4 shadow_light_newdir;
half4 shadow_light_new;
#if POINT_LIGHT_ENABLED
half4 PointLightAttrs[LIGHT_ATTR_ITEM_NUM*LIGHT_NUM];
#endif

sampler2D sam_diffuse;
sampler2D sam_environment_reflect;
sampler2D sam_normal;
#ifndef DEV_MODE_ON
sampler2D sam_control;
#else
sampler2D sam_normalCtrl;
sampler2D sam_metallicCtrl;
sampler2D sam_3sCtrl;
sampler2D sam_srCtrl;
#endif
#ifdef COMBINE_MODE
sampler2D sam_diffuse2;
sampler2D sam_normal2;
sampler2D sam_control2;
#endif

#if POINT_LIGHT_ENABLED
inline half4 calc_point_light_atten(half3 posWorld)
{
	const half local_450 = 1.0f;
	const half local_458 = 0.001f;
	half values[LIGHT_NUM];
	for (int i = 0; i < LIGHT_NUM; ++i)
	{
		half4 local_442 = PointLightAttrs[3 + i*LIGHT_ATTR_ITEM_NUM];
		half4 local_444 = PointLightAttrs[4 + i*LIGHT_ATTR_ITEM_NUM];
		half3 local_449 = (posWorld - local_442.xyz) / local_442.w;
		half local_453 = saturate(local_450 - dot(local_449, local_449));
		values[i] = pow(local_453, local_444.x + local_458);
	}
	return half4(values[0], values[1], values[2], values[3]);
}
#endif

PS_INPUT vert(appdata v)
{
	PS_INPUT o;
	o.final_position = UnityObjectToClipPos(v.vertex);
#ifdef COMBINE_MODE
	o.color = v.color;
#endif
	o.uv0 = v.uv;

	o.v_world_position = mul(unity_ObjectToWorld, v.vertex);

	float3 normal = UnityObjectToWorldNormal(v.normal);
	half3 tangent = UnityObjectToWorldDir(v.tangent.xyz);
	half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
	float3 bitangent = normalize(cross(normal, tangent) * tangentSign);

	o.v_world_normal = normal;
	o.v_world_tangent = tangent;
	o.v_world_binormal = bitangent;

#if POINT_LIGHT_ENABLED
	o.v_texture6 = calc_point_light_atten(o.v_world_position);
#endif
	half4 local_518 = ShadowLightAttr[3];
	half3 local_528 = lerp(local_518.xyz, shadow_light_newdir.xyz, shadow_light_newdir.w);
	o.v_texture1 = half4(normalize(local_528), local_518.w);
	o.v_texture2 = lerp(ShadowLightAttr[1], shadow_light_new, shadow_light_newdir.w);

	UNITY_TRANSFER_FOG(o, o.final_position);
	return o;
}


inline void sample_normal_map_with_roughness(in PS_INPUT psIN, in half normalCtrl, inout float3 normal, out half roughness)
{
	float3 local_35 = normal;
#if SPECULAR_AA
	const half local_37 = 1.0;
	half local_44 = clamp(local_37 - ((local_37 - length(local_35)) * 7.0), 0.0001f, local_37);
	half local_48 = (half)1.0f - saturate(normalCtrl);
	roughness = (half)1.0f - (local_48 / (local_37 + (local_48 * ((1.0f - local_44) / local_44))));
#else
	roughness = normalCtrl;
#endif
	half normalScale = _CC_NMRB.x;
	half3 local_58 = half3(local_35.x * normalScale, local_35.y * normalScale, local_35.z);
	float3 local_66 = (psIN.v_world_binormal * local_58.y) + (psIN.v_world_tangent * local_58.x) + (psIN.v_world_normal * local_58.z);
	normal = normalize(local_66);
}

inline void calc_world_info(in PS_INPUT psIN, in half normalCtrl, inout float3 normal, out half roughness)
{
	sample_normal_map_with_roughness(psIN, normalCtrl, normal, roughness);
}
			
inline half3 calc_brdf_env_diffuse(float3 normal)
{
	half3 local_80 = normalize(mul(normal, (half3x3)envRot));
	half4 local_82 = half4(local_80, 1.0);
	half3 envDiffuse = half3(
		dot(local_82, mul(local_82, envSHR)),
		dot(local_82, mul(local_82, envSHG)),
		dot(local_82, mul(local_82, envSHB))
		);
	return envDiffuse * _CC_LAPE.w/*env_exposure*/;
}

/*inline half3 calc_change_color(half3 color, half2 local_104)
{
	half3 local_111 = half3(0.299f, 0.587f, 0.114f);
	const half local_113 = 0.01f;
	const half local_119 = 3.0f;

	half local_121 = local_104.x;
	half local_117 = (dot(color, local_111) + local_113) / tint_color1.w;
	half3 local_124 = tint_color1.xyz * local_117 * local_119 * local_121;
	half3 local_125 = lerp(color, local_124, local_121);

	half local_122 = local_104.y;
	half local_130 = (dot(local_125, local_111) + local_113) / tint_color2.w;
	half3 local_133 = tint_color2.xyz * local_130 * local_119 * local_122;
	return lerp(local_125, local_133, local_122);
}*/
			
inline half3 calc_brdf_diffuse(half3 changeColor, half metallic)
{
	return mul(changeColor, 1.0 - metallic);
}

inline half3 calc_brdf_specular(half3 changeColor, half metallic)
{
	return lerp(0.04, changeColor, metallic);
}

inline half3 calc_transmission_sss(half3 light2PointNormal, float3 normal, half cvSSS)
{
	const half local_212 = 1.0f;
	const half local_217 = 0.001f;
	half sss_warp0 = _CC_WSAX.x;
	half sss_scatter0 = _CC_WSAX.y;
	half local_210 = dot(normal, light2PointNormal);
	half local_215 = saturate((local_210 + sss_warp0) / (local_212 + sss_warp0));
	half local_223 = smoothstep(0.0f, sss_scatter0 + local_217, local_215) * lerp(sss_scatter0 * 2.0f, sss_scatter0, local_215);
	half local_229 = saturate(local_210);
	half3 local_230 = { local_229, local_229, local_229 };
	half3 local_231 = (sss_scatter_color0.xyz * local_223) + local_215;
	return lerp(local_230, local_231, cvSSS + local_217);
}

inline half3 calc_brdf_specular_factor_char(half3 light2PointNormal, float3 normal, half3 camera2PointNormal, half roughness, half3 color)
{
	half3 local_250 = normalize(camera2PointNormal + light2PointNormal);
	half local_252 = saturate(dot(normal, light2PointNormal));
	half local_254 = saturate(dot(normal, local_250));
	half local_256 = saturate(dot(light2PointNormal, local_250));
	half local_259 = max(roughness * roughness, 0.002f);
	half local_260 = local_259 * local_259;
	const half local_264 = 1.0f;
	half local_265 = (local_254 * local_260 - local_254) * local_254 + local_264;
	half local_269 = local_260 / (3.141593f * local_265 * local_265);
	half local_275 = local_264 / (4.0f * local_256 * local_256 * (roughness + 0.5f));
	return color * local_275 * local_269 * local_252;
}

inline void shadow_light_player(in PS_INPUT psIN, in float3 normal, in half3 camera2PointNormal,
	in half cvSSS, in half roughness, in half3 brdfSpecularColor,
	out half3 diffuse, out half3 specular)
{
	half3 light2PointNormal = -psIN.v_texture1.xyz;
	half3 local_240 = psIN.v_texture2.xyz;
	half local_241 = saturate(dot(normal, light2PointNormal));
	diffuse = local_240 * (cvSSS > 0.0 ? calc_transmission_sss(light2PointNormal, normal, cvSSS) : half3(local_241,local_241,local_241));
#if SPECULAR_ENABLE
	specular = local_240 * calc_brdf_specular_factor_char(light2PointNormal, normal, camera2PointNormal, roughness, brdfSpecularColor);
#else
	specular = 0.0f;
#endif
}

inline void point_light_player(in half4 lightAttr1, in half4 lightAttr2, in half4 lightAttr3, half lightParam,
	in half4 brdfSpecularColor4, in half3 posWorld, in float3 normal, in half3 camera2PointNormal, 
	in half cvSSS, in half roughness,
	out half3 local_296, out half3 local_297)
{
	half4 local_303;
	half4 local_304;
	if (lightAttr2.x > 1.0)
	{
		half point_light_scale = _CC_LAPE.z;
		local_303 = lightAttr1 *  point_light_scale;
		local_304 = brdfSpecularColor4 * point_light_scale;
	}
	else
	{
		local_303 = lightAttr1;
		local_304 = brdfSpecularColor4;
	}
	half local_312 = local_303.x + local_303.y + local_303.z;
	if (local_312 == 0.0)
	{
		local_296 = 0;
		local_297 = 0;
	}
	else
	{
		half3 light2PointNormal = -normalize(posWorld - lightAttr3.xyz);
		half3 local_351 = local_303.rgb;
		local_296 = local_351 * calc_transmission_sss(light2PointNormal, normal, cvSSS) * lightParam;
#if SPECULAR_ENABLE
		local_297 = local_351 * calc_brdf_specular_factor_char(light2PointNormal, normal, camera2PointNormal, roughness, local_304.xyz) * lightParam;
#else
		local_297 = 0;
#endif
	}
}

inline void calc_lighting_player(in PS_INPUT psIN, in half3 brdfSpecularColor, in half cvSSS, 
	in float3 normal, in half3 camera2PointNormal, in half roughness, in half3 posWorld, 
	out half3 lightDiffuse, out half3 lightSpecular)
{
	half3 diffuse = 0;
	half3 specular = 0;
	half4 brdfSpecularColor4 = half4(brdfSpecularColor.x, brdfSpecularColor.y, brdfSpecularColor.z, 0.0f);
	shadow_light_player(psIN, normal, camera2PointNormal, cvSSS, roughness, brdfSpecularColor, diffuse, specular);
#if POINT_LIGHT_ENABLED
	half pparams[4] = { psIN.v_texture6.x, psIN.v_texture6.y, psIN.v_texture6.z, psIN.v_texture6.w };
	for (int i = 0; i < LIGHT_NUM; ++i)
	{
		half3 lightDiff;
		half3 lightSpec;
		point_light_player(PointLightAttrs[1+ i*LIGHT_ATTR_ITEM_NUM], PointLightAttrs[2 + i*LIGHT_ATTR_ITEM_NUM], PointLightAttrs[3 + i*LIGHT_ATTR_ITEM_NUM], 
			pparams[i], brdfSpecularColor4, posWorld, normal, camera2PointNormal, cvSSS, roughness, lightDiff, lightSpec);
		diffuse += lightDiff;
		specular += lightSpec;
	}
#endif
	lightDiffuse = diffuse;
	lightSpecular = specular;
}

inline half3 calc_brdf_env_sss(half3 envDiffuse)
{
	half sss_warp0 = _CC_WSAX.x;
	half sss_scatter0 = _CC_WSAX.y;
	half3 local_646 = (envDiffuse + sss_warp0) / (sss_warp0 + 1.0);
	half3 local_647 = sss_scatter0;
	half3 local_650 = lerp(0, local_647, local_646);
	half3 local_653 = lerp(local_647 * 2.0, local_647, local_646);
	half3 local_654 = local_650 * local_653;
	return local_646 + sss_scatter_color0.xyz * local_654;
}

inline half2 env_dir_to_uv(half3 envRefDir)
{
	half local_691 = envRefDir.x;
	half local_692 = envRefDir.y;
	half local_693 = envRefDir.z;
	half2 local_694 = { local_691, local_693 };
	half local_698 = local_691 / (length(local_694) + 1E-06f);
	half2 local_699 = { local_698, local_692 };
	half2 local_702 = acos(local_699) * 0.3183099f;
	half local_708 = step(local_693, 0.0f);
	half local_714 = local_708 - ((local_708 * 2.0f - 1.0f) * (local_702.x * 0.5f));
	return half2(local_714, local_702.y);
}

inline half3 env_sample_lod_sim(half3 envRefDir, half local_669)
{
	half2 local_689 = env_dir_to_uv(envRefDir);
	half local_719 = clamp(local_669, 0.0f, 9.0f);
	half4 local_720 = tex2Dlod(sam_environment_reflect, half4(local_689.x, local_689.y, 0.0f, local_719));
	return local_720.xyz * exp2(local_720.w * 14.48538f - 3.621346f);
}

inline half3 env_approx(half roughness, half3 brdfSpecularColor, half local_668)
{
	half4 local_739 = half4(-1.0f, -0.0275f, -0.572f, 0.022f);
	half4 local_744 = { 1.0f, 0.0425f, 1.04f, -0.04f };
	half2 local_746 = { -1.04f, 1.04f };
	half4 local_748 = local_739 * roughness + local_744;
	half local_758 = min(local_748.x * local_748.x, exp2(local_668 * -9.28f));
	half2 local_764 = local_746 * (local_758 * local_748.x + local_748.y) + local_748.zw;
	return brdfSpecularColor * local_764.x + local_764.y;
}

inline half3 calc_brdf_env_specular_sim(float3 normal, half3 camera2PointNormal, half roughness, half3 brdfSpecularColor)
{
	half3 local_663 = -reflect(camera2PointNormal, normal);
	half3x3 local_664 = (half3x3)envRot;
	half3 envRefDir = normalize(mul(local_663, local_664));
	half local_668 = saturate(dot(normal, camera2PointNormal));
	half local_669 = (roughness < 0.05) ? 0.0 : roughness * 9.0f;
	half3 local_687 = env_sample_lod_sim(envRefDir, local_669);
	half3 local_730 = env_approx(roughness, brdfSpecularColor, local_668);
	return local_687 * local_730;
}

inline void calc_brdf_env_player(half3 color, float3 normal, half3 camera2PointNormal, 
	half cvSSS, half roughness, half3 brdfSpecularColor,
	out half3 envDiffuse, out half3 envSpecular)
{
	envDiffuse = color;
	envSpecular = calc_brdf_env_specular_sim(normal, camera2PointNormal, roughness, brdfSpecularColor) * _CC_LAPE.w/*env_exposure*/;
}

inline half4 encode_rgbe(half3 local_791)
{
	const half local_851 = 128.0f;
	const half local_852 = 1.06f;
	const half local_853 = 1.0f;
	half3 local_854 = { local_853, local_853, local_853 };
	half local_855 = dot(local_791, local_854);
	half local_861 = (log(local_855) / log(local_852) + local_851) / 256.0f;
	half3 local_862 = { local_855, local_855, local_855 };
	half3 local_863 = local_791 / local_862;
	return half4(local_863, local_861);
}

half4 frag(PS_INPUT psIN) : COLOR
{
	half4 pxDiffuse;
	float3 normal;
	half4 pxControl;
#ifndef COMBINE_MODE
	pxDiffuse = tex2D(sam_diffuse, psIN.uv0);
#	if _TRANSPARENT_MODE
	clip(pxDiffuse.a - _CC_WSAX.z);
#	endif
	normal = tex2D(sam_normal, psIN.uv0).rgb * 2.0 - 1.0;
#	ifndef DEV_MODE_ON
	pxControl = tex2D(sam_control, psIN.uv0);
#	else
	pxControl = half4(tex2D(sam_normalCtrl, psIN.uv0).r, tex2D(sam_metallicCtrl, psIN.uv0).r, tex2D(sam_3sCtrl, psIN.uv0).r, tex2D(sam_srCtrl, psIN.uv0).r);
#	endif
#else
	int index = ceil(psIN.color.r * 255);
	if (index == 0) 
	{
		pxDiffuse = tex2D(sam_diffuse, psIN.uv0);
#	if _TRANSPARENT_MODE
		clip(pxDiffuse.a - _CC_WSAX.z);
#	endif
		normal = tex2D(sam_normal, psIN.uv0).rgb * 2.0 - 1.0;
		pxControl = tex2D(sam_control, psIN.uv0);
	}
	else
	{
		pxDiffuse = tex2D(sam_diffuse2, psIN.uv0);
#	if _TRANSPARENT_MODE
		clip(pxDiffuse.a - _CC_WSAX.z);
#	endif
		normal = tex2D(sam_normal2, psIN.uv0).rgb * 2.0 - 1.0;
		pxControl = tex2D(sam_control2, psIN.uv0);
	}
#endif
	//half3 diffuseColor = lerp(pxDiffuse.rgb, diffuse_color_tint.rgb, diffuse_color_tint.a);
	half3 diffuseColor = pxDiffuse.rgb;
	half roughness;
	calc_world_info(psIN, pxControl.r, normal, roughness);
	half3 posWorld = psIN.v_world_position.xyz;
	half3 camera2PointNormal = normalize(_WorldSpaceCameraPos.xyz - posWorld);
	half3 envDiffuse = calc_brdf_env_diffuse(normal);
	roughness = saturate(roughness + _CC_NMRB.z);//roughness_offset
	half metallic = saturate(pxControl.g + _CC_NMRB.y);//metallic_offset
	half cvSSS = pxControl.b;
	diffuseColor *= diffuseColor;//gamma correct
	half3 changeColor = diffuseColor;// calc_change_color(diffuseColor, pxOther0.rg);
	half3 brdfDiffuseColor = calc_brdf_diffuse(changeColor, metallic);
	half3 brdfSpecularColor = calc_brdf_specular(changeColor * metallic_color, metallic);

	half3 lightDiffuse;
	half3 lightSpecular;
	calc_lighting_player(psIN, brdfSpecularColor, cvSSS, normal, camera2PointNormal, roughness, posWorld, lightDiffuse, lightSpecular);
				
	half3 envSpecular;
	calc_brdf_env_player(envDiffuse, normal, camera2PointNormal, cvSSS, roughness, brdfSpecularColor, envDiffuse, envSpecular);


	half character_light_factor = _CC_LAPE.x;
	half change_color_bright_add = _CC_LAPE.y;
	half3 local_791 = envSpecular + lightSpecular;
	half3 local_794 = change_color_bright_add + (local_791 * pxControl.a) + (brdfDiffuseColor * max(lightDiffuse * character_light_factor, envDiffuse));
	half3 local_800 = sqrt(local_794);//gamma correct
	half4 envReflectColor = encode_rgbe(local_791);
			
	half4 local_867 = half4(local_800, pxDiffuse.a);
	half4 finalColor = lerp(local_867, envReflectColor, _CC_NMRB.w);
#ifdef ALPHA_CTRL_ON
	finalColor.a *= _CC_WSAX.a;
#endif
	UNITY_APPLY_FOG(psIN.fogCoord, finalColor);
	return finalColor;
}