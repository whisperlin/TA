#include "LCHCommon.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"
#include "SceneWeather.inc" 
#include "SHGlobal.cginc"
#include "Shadow.cginc"
#include "virtuallight.cginc"
#include "height-fog.cginc"
#if _VIRTUAL_LIGHT_SHADOW2
#include "shadowmap.cginc"
#endif

	struct appdata
	{
		half4 vertex : POSITION;
		half2 uv : TEXCOORD0;
		half2 uv2 : TEXCOORD1;
		half3 normal : NORMAL;
		half4 tangent : TANGENT;
	};

	struct v2f
	{
		half4 pos : SV_POSITION;
		half2 uv : TEXCOORD0;
		UNITY_FOG_COORDS_EX(1)
		NORMAL_TANGENT_BITANGENT_COORDS(2,3,4)
		
		float4 posWorld : TEXCOORD5;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
		half2 uv2 : TEXCOORD6;
#endif
#if _VIRTUAL_LIGHT_SHADOW

	//	float2 lvuv : TEXCOORD7;
 
		LIGHTING_COORDS(7,8)
#endif

#if _VIRTUAL_LIGHT_SHADOW2

		float4 shadowCoord : TEXCOORD7;
#endif

 
		#if GLOBAL_SH9
		fixed3 ambient : TEXCOORD9;
		#else
			 
		#endif


	
//#ifdef SHADOW_ON
//		half2 shadow_uv : TEXCOORD9;
//#endif
	};

	
	

	//sampler2D unity_NHxRoughness;
	fixed _CullSepe;
	fixed4 _Color;
 
	fixed4 _BackColor;

	sampler2D _MainTex;
	half4 _MainTex_ST;
	sampler2D _Normal;
	//half _NormalPower;
	fixed3 _Spec;
	half _Gloss;
	half metallic_power;


	fixed _SnowPower;
	fixed _SnowNormalPower;
	fixed4 _SnowColor;
	fixed _SnowEdge;
	sampler2D _SnowNoise;
	half _SnowNoiseScale;
	half _SnowGloss;
	half _SnowLocalPower;
	half _SnowMeltPower;
	half _MetalShadow ;

	//fixed3 _IntensityColor;

	//#ifdef _ISEMISSIVE_ON
	//	sampler2D _Emissive;
	//	fixed3 _EmissiveColor;
	//#endif
	sampler2D _BRDFTex;
	half _S3SPower;
	half _DifSC;
	//#ifdef SHADOW_ON
	//	sampler2D _Shadow, _ShadowFade;
	//	float4x4 shadow_projector;
	//	fixed _ShadowStrength;
	//	float4 _Shadow_TexelSize;
	//#endif

	#ifdef BRIGHTNESS_ON
		fixed3 _Brightness;
	#endif
	uniform sampler2D _AO;
	//uniform sampler2D _NormalMark;
 
	sampler2D _CtrlTex;
	sampler2D _SpecMap;
	sampler2D _GlossMap;
	half4 _Emission;

	 
	sampler2D sam_environment_reflect;

	half _SpPower;

#if _CHARACTOR
	half _LightPower;
#endif

	half sss_scatter0;

#if ALPHA_CLIP
	half _AlphaClip;
#endif

	/*inline half3 calc_transmission_sss(half NdotLsat, half NdotL, half sss_warp0, half sss_scatter0, half cvSSS)
	{
		half NdotL2 = saturate((NdotL + sss_warp0) / (1.0 + sss_warp0));
		//half NdotL2 = lerp(sss_warp0, 1, NdotLsat);
		half NdotL3 = smoothstep(0.0f, sss_scatter0 + 0.001, NdotL2) * lerp(sss_scatter0 * 2.0f, sss_scatter0, NdotL2);
		half3 color0 =  lerp(_DifSC,1, NdotLsat)  ;
		half3 color1 = (_BackColor.xyz * NdotL3) + NdotL2;
		return lerp(color0, color1, cvSSS + 0.001);
	}*/

	inline half3 calc_transmission_sss(half NdotLsat, half NdotL,half BackNdotL ,half sss_warp0, half sss_scatter0, half cvSSS)
	{
		half NdotL2 = saturate((BackNdotL + sss_warp0) / (1.0 + sss_warp0));
		half NdotL3 = smoothstep(0.0f, sss_scatter0 + 0.001, NdotL2) * lerp(sss_scatter0 * 2.0f, sss_scatter0, NdotL2);
		half3 color0 = lerp(_DifSC, 1, NdotLsat);
		half3 color1 = (_BackColor.xyz * NdotL3) + color0;
		return lerp(color0, color1, cvSSS + 0.001);
	}

	v2f vert(appdata v)
	{
		v2f o;

		WPAttribute wp = ToProjectPos(v.vertex);

		o.pos = wp.pos;
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		o.posWorld = wp.wpos;

	 

		NTBYAttribute ntb = GetWorldNormalTangentBitangent(v.normal,v.tangent);
		o.normal = ntb. normal;
		o.tangent = ntb. tangent;
		o.bitangent = ntb. bitangent;

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
		o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
#endif
#if _VIRTUAL_LIGHT_SHADOW

 
		TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif


#if _VIRTUAL_LIGHT_SHADOW2
		o.shadowCoord = mul(_depthVPBias, mul(unity_ObjectToWorld, v.vertex));
		o.shadowCoord.z = -(mul(_depthV, mul(unity_ObjectToWorld, v.vertex)).z * _farplaneScale);
#endif
		

 
			 

#if S_BAKE
	
	float2 uv0 = v.uv;
 
	
	o.pos.xy = uv0 * 2 - float2(1, 1);
	o.pos.z = 0.5;
	o.pos.w = 1;
 

	o.pos.y =   o.pos.y;

	 
#endif
		#if GLOBAL_SH9
			o.ambient = g_sh(half4(o.normal, 1)) ;
		#else
		
		#endif
			
		UNITY_TRANSFER_FOG_EX(o, o.pos, o.posWorld, o.normal);

		#if _HEIGHT_FOG_ON
		#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
 
		
		 
		#endif
		#endif

 
		return o;
	}

	//inline half2 Pow4 (half2 x) { return x *x*x*x; }
	float ArmBRDF(float roughness, float NdotH, float LdotH)
	{
		float n4 = roughness*roughness*roughness*roughness;
		float c = NdotH*NdotH   *   (n4 - 1) + 1;
		float b = 4 * 3.14*       c*c  *     LdotH*LdotH     *(roughness + 0.5);
		return n4 / b;

	}

	//这个是网易的。
	inline half2 ToRadialCoordsNetEase(half3 envRefDir)
	{
 
		half k = envRefDir.x / (length(envRefDir.xz) + 1E-06f);
		half2 normalY = { k, envRefDir.y };
		half2 latitude = acos(normalY) * 0.3183099f;
		half s = step(envRefDir.z, 0.0f);
		half u = s - ((s * 2.0f - 1.0f) * (latitude.x * 0.5f));
		return half2(u, latitude.y);
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
 
	sampler2D environment_reflect;
	sampler2D metallic_ctrl_tex;
	half4 metallic_color;
	half _AmbientPower;
	fixed4 _ClothColor;
	fixed4 _ClothColor2;

	float ArmBRDFEnv(float roughness, float NdotV)
	{
		float a1 = (1 - max(roughness, NdotV));
		return a1*a1*a1;

	}

	 
	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 c_base = tex2D(_MainTex, i.uv);
		
		fixed4 c = c_base ;



		fixed4 nor_val = tex2D(_Normal, i.uv);

#if _CLOTH_ON || _ISMEMISSION_COL
	half gray = dot(c.rgb,half3(0.3,0.6,0.1));
#endif

#if _ISMEMISSION_COL
		c.rgb  = lerp(c.rgb,_ClothColor.rgb*gray,nor_val.b*_ClothColor.a*2.0);
#endif

#if _CLOTH_ON
		c.rgb  = lerp(c.rgb,_ClothColor2.rgb*gray,nor_val.a*_ClothColor2.a*2.0);

#endif
 
		half3 n = UnpackNormalRG(nor_val);
		//float4 nor_mark_val = tex2D(_NormalMark, i.uv);
		//_NormalPower = _NormalPower*( 1.0 - nor_mark_val );
		//n = lerp(float3(0,0,1),n,_NormalPower);

#if S_DEVELOP
		fixed4 _AO_varC = tex2D(_AO, i.uv);
		half _AO_var = _AO_varC.r  ;
#else
		
		fixed4 var_CtrlTex = tex2D(_CtrlTex, i.uv);
		half _AO_var = var_CtrlTex.b;
#endif

	

		#if  _AO_ON 
			fixed3 c0 = c*_AO_var;
		#else
			fixed3 c0 = c;
		#endif


		//half3 normal;

		 


		float3x3 tangentTransform = GetNormalTranform(i.normal, i.tangent, i.bitangent);

		half3 normal = normalize(mul(n, tangentTransform));
		 

	#if _ISWEATHER_ON
 
		#if SNOW_ENABLE 


			#if   defined(HARD_SNOW) || defined(MELT_SNOW) 
			half snoize = tex2D(_SnowNoise, i.uv*_SnowNoiseScale).r;

			#endif

			#if MELT_SNOW
				half snl  =  snoize * _SnowMeltPower;
				 
			#else
				half snl  =  dot(normal, half3(0,1,0))   ;
				snl = (1.0-_SnowLocalPower)*snl + _SnowLocalPower;
			#endif
	 
			fixed nt = smoothstep(_SnowPower,_SnowPower+_SnowEdge,snl);
	 

		 	 #if HARD_SNOW
			 nt = step(snoize,nt);
			 #endif
			 //float nt2 = step(snoize,snoize);
			 c0.rgb = lerp(c0.rgb,_SnowColor.rgb,nt *_SnowColor.a);
			 half3 up0 = half3(i.tspace0.z,i.tspace1.z,i.tspace2.z);

			 normal = lerp( up0,normal , _SnowNormalPower );
	 
		#endif

	 
	#endif

	#if _ISWEATHER_ON
		#if RAIN_ENABLE 
			calc_weather_info(i.posWorld.xyz, normal, n, c0, normal, c0.rgb);
			 

		#endif
	#endif
  
		half3 viewDir = normalize(UnityWorldSpaceViewDir(i.posWorld));

		#if _VIRTUAL_LIGHT_ON
			half3 lightDir = normalize(VirtualDirectLight0.xyz);
			 

		#else
			half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

		#endif


#if _VIRTUAL_LIGHT_ON
		fixed3 lightColor = VirtualDirectLightColor0.rgb*VirtualDirectLightColor0.a;
#else
		fixed3 lightColor = _LightColor0;
#endif

		
 
#if S_DEVELOP
		 
		half4 var_specMapC = tex2D(_SpecMap, i.uv);
		half var_specMap = var_specMapC.r * _SpPower;
		half4 var_glossMapC = tex2D(_GlossMap, i.uv);
		half var_glossMap = var_glossMapC.r ;
		
#else
		
		half var_specMap = var_CtrlTex.r * _SpPower;
		half var_glossMap = var_CtrlTex.g;
#endif
		 
		
		
	
	
	_Gloss *= 1.0 - var_glossMap;

	#if _ISWEATHER_ON
		#if RAIN_ENABLE  
		 
			_Gloss = saturate(_Gloss* get_smoothnessRate());

		#endif
		#if(SNOW_ENABLE)
		  
			 _Gloss = lerp(_Gloss,_SnowGloss,nt);
		#endif

	#endif
 
	fixed3 specColor = _Spec ;
 
//#endif
	
	half perceptualRoughness = 1.0 - _Gloss;
	
	half roughness = perceptualRoughness * perceptualRoughness;
	half3 reflDir = reflect(viewDir, normal);
	half _nl = dot(normal, lightDir);
	half b_nl = dot(normal, -lightDir);
	half nl = saturate(_nl);
	half nv = saturate(dot(normal, viewDir));
	//half2 rlPow4AndFresnelTerm = Pow4(half2(dot(reflDir, lightDir), 1 - nv));
	//half rlPow4 = rlPow4AndFresnelTerm.x;
	//half LUT_RANGE = 16.0 * step(0.001, nl);

	float3 halfDirection = normalize(viewDir + lightDir);
	float LdotH = saturate(dot(lightDir, halfDirection));
	float NdotH = saturate(dot(normal, halfDirection));

	float NdotV = abs(dot(normal, viewDir));

	float specular = ArmBRDF(roughness, NdotH, LdotH);
	#ifdef UNITY_COLORSPACE_GAMMA
		specular = sqrt(max(1e-4h, specular));
	#endif

	specular = max(0, specular * nl)*var_specMap;


 

#if GLOBAL_SH9
	
	fixed3 ambient = i.ambient * c.rgb ;
	//fixed3 ambient = g_sh(half4(normal, 1))* c.rgb ;
#else
	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * c0.rgb ;
#endif

	//half nl0 = saturate(dot(normal, -lightDir));

#if _VIRTUAL_LIGHT_SHADOW
	half attenuation = LIGHT_ATTENUATION(i);
	lightColor.rgb*=  attenuation;

#endif

#if _VIRTUAL_LIGHT_SHADOW2
	half attenuation = PCF4Samples(i.shadowCoord);
	lightColor.rgb *= attenuation;

#endif

#if _CHARACTOR
	lightColor.rgb *= _LightPower;
#endif
	c0.rgb *= _Color.rgb;
#if _ISS3_ON

	float deltaWorldNormal = length( fwidth( normal ) );
	float deltaWorldPosition = length( fwidth ( i.posWorld ) );
	//_CurvatureScale = 0.005
	float Curvature = saturate( deltaWorldNormal / deltaWorldPosition ) *  0.005;

	float2 brdfUV;
	//float NdotLBlur = dot( s.NormalBlur, lightDir );
	float NdotLBlur = nl;
	brdfUV.x = NdotLBlur * 0.5 + 0.5;
	brdfUV.y = Curvature * dot( _LightColor0.rgb, fixed3(0.22, 0.707, 0.071 ) );
	half3 brdf = tex2D( _BRDFTex, brdfUV ).rgb;
	//return float4(brdf,1);
	//c.rgb = (lerp(c0.rgb * nl , c0.rgb * brdf.rgb*_S3STR , _S3SPower   ) * _LightColor0.rgb
	fixed3 diffuse = ambient*_AmbientPower + lightColor * lerp(c0.rgb*  nl ,  c0.rgb*  brdf.rgb , _S3SPower *_AO_var )    ;

#else

	//return float4(calc_transmission_sss(nl, _nl, _DifSC, sss_scatter0, 1), 1);
	#if _CHARACTOR

#if _ISS3_BACK
	fixed3 diffuse = ambient*_AmbientPower + lightColor * lerp(_DifSC, 1, nl) * c0.rgb + _BackColor.rgb *saturate(b_nl)*sss_scatter0;
#else
	fixed3 diffuse = ambient*_AmbientPower + lightColor *c0.rgb* calc_transmission_sss(nl, _nl, b_nl, _DifSC, sss_scatter0, _AO_var);
#endif
		

	#else

		
		fixed3 diffuse = ambient*_AmbientPower + lightColor *c0.rgb* calc_transmission_sss(nl, _nl, b_nl, _DifSC, sss_scatter0, 1);
	#endif
 	
	//fixed3 diffuse = ambient + lightColor * lerp(_DifSC,1, nl) * c0.rgb + _BackColor.rgb *nl0  ;


#endif

	 
	 

	fixed3 spec = lightColor * specular * specColor;


	 

 
	
#if S_BAKE

#else
	half sp = 1;

#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
	fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
	diffuse *= lm;
	sp *= smoothstep(0.2+_CullSepe,0.35+_CullSepe, lm);
	//sp = ml;
#endif

#endif


#if defined(_ISMETALLIC_ON) 
	#if S_DEVELOP
	half4 metallic_ctrl_texC = tex2D(metallic_ctrl_tex, i.uv);
	half _e = metallic_ctrl_texC.r;
#else
	half _e = var_CtrlTex.a;
#endif
	half _m = _e  *  metallic_power;
#endif

	
#if S_BAKE

#else
	spec *= sp;
#endif
fixed3 InDirspec = 0;

#if _ISMETALLIC_ON
	//金属 .  
	half3 viewReflectDirection = reflect(-viewDir, normal);
	
	half4 skyUV = half4(ToRadialCoords(viewReflectDirection),0, roughness*6);
	fixed4 localskyColor = tex2Dlod(environment_reflect, skyUV) ;
 
	fixed3 baseSkyColor =  localskyColor.xyz ;

	


	#if _ISSUN_ON
		baseSkyColor *= max(0,exp2(localskyColor.w * 14.48538f - 3.621346f));
	#endif

	#if _ISMETADIFFUSECOLOR_ON
		fixed3 skyColor = baseSkyColor*c_base.rgb;
	#else
		fixed3 skyColor = baseSkyColor;
	#endif
	
	skyColor += ArmBRDFEnv(roughness, NdotV);

	skyColor *=  _m;
	skyColor *= metallic_color.rgb;
  
	diffuse *=   max((1 - _m),0);


	#if _VIRTUAL_LIGHT_SHADOW
		skyColor *= lerp(_MetalShadow,1,attenuation);
	#endif

	#if _VIRTUAL_LIGHT_SHADOW2
		skyColor *= lerp(_MetalShadow,1,attenuation);

	#endif
	//return attenuation;
	InDirspec  = skyColor;
	//return float4(baseSkyColor,1);
#else
	
	#if GLOBAL_ENV_SH9
	half3 viewReflectDirection = reflect(-viewDir, normal);
	 
	#endif
#endif 

	c.rgb = diffuse + spec + InDirspec ;

#ifdef _ISMEMISSION_ON
	c.rgb += c0.rgb*_Emission*nor_val.b;
#endif


#if ALPHA_CLIP
	clip(c.a - _AlphaClip);
#endif

#if _GOOD_HAIR
	clip(c.a - 0.5);
#endif

 
 

 
#if BRIGHTNESS_ON
	c.rgb = c.rgb * _Brightness * 2;
#endif
	 
 
#if GLOBAL_ENV_SH9
	float3 l__viewDir = lerp(-viewDir, float3(0, -1, 0), globalEnvOffset);
	//half __gray = dot(c.rgb,half3(0.3,0.6,0.1));
	APPLY_HEIGHT_FOG_EX(c, i.posWorld, envsh9(l__viewDir), i.fogCoord);
#else
	APPLY_HEIGHT_FOG(c, i.posWorld, normal, i.fogCoord);
#endif

 
	UNITY_APPLY_FOG_MOBILE(i.fogCoord,c);
	return c;
	}