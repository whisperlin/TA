Shader "TA/T4MShaders/BumpSpec/T4M 3 Textures Bump Spec Water" {
	Properties{
		//_SpecColor("高光颜色", Color) = (1, 1, 1, 1)
		//_ShininessL0("Layer1Shininess", Range(0.03, 1)) = 0.078125
		_Splat0("Layer 1 (R)", 2D) = "white" {}
		_SpecColor0("第一层", Color) = (1, 1, 1, 1)
		[Toggle(SL1_BOOL)] _S_BOOL1("第一层地表开启高光", Int) = 0
		//_ShininessL1("Layer2Shininess", Range(0.03, 1)) = 0.078125
		_Splat1("Layer 2 (G)", 2D) = "white" {}
		_SpecColor1("第二层", Color) = (1, 1, 1, 1)
		[Toggle(SL2_BOOL)] _S_BOOL2("第二层地表开启高光", Int) = 0
		_Splat2("Layer 3 (B)", 2D) = "white" {}
		_BumpSplat0("Layer1Normalmap", 2D) = "bump" {}
		_BumpSplat1("Layer2Normalmap", 2D) = "bump" {}
		_BumpSplat2("Layer3Normalmap", 2D) = "bump" {}
		_Control("Control (RGBA)", 2D) = "white" {}
		_MainTex("Never Used", 2D) = "white" {}



		//_ShininessL2("水光照调节", Range(0.03, 1)) = 0.078125
		_TopColor("浅水色", Color) = (0.619, 0.759, 1, 1)
		_ButtonColor("深水色", Color) = (0.35, 0.35, 0.35, 1)
		_Gloss("水高光亮度", Range(0,1)) = 0.5
		_WaveNormalPower("水法线强度",Range(0,1)) = 1
		_WaveScale("水波纹缩放", Range(0.02,0.15)) = .07
		_WaveSpeed("水流动速度", Vector) = (19,9,-16,-7)
		_SpecColor2("水高光色", Color) = (1, 1, 1, 1)
		
		[KeywordEnum(Off, On)] _IsMetallic("是否开启金属度", Float) = 0
 
		metallic_power("天空强度", Range(0,1)) = 1
		metallic_color("天空颜色", Color) = (1, 1, 1, 0)
		_Shininess("三层高光锐度", Vector) = (0.078125,0.078125,0.078125,0.078125)
	}

		SubShader{
		Tags{
		"SplatCount" = "3"
		"Queue" = "Geometry-100"
		"RenderType" = "Opaque"
	}
		
	// ------------------------------------------------------------
	// Surface shader code generated out of a CGPROGRAM block:
	

	// ---- forward rendering base pass:
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma target 3.0
#pragma multi_compile_fog
#pragma multi_compile_fwdbase
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
 
#define UNITY_PASS_FORWARDBASE
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
#pragma multi_compile _ISMETALLIC_OFF _ISMETALLIC_ON  

#pragma shader_feature SL1_BOOL
#pragma shader_feature SL2_BOOL

#pragma   multi_compile  _  _HEIGHT_FOG_ON
		#pragma   multi_compile  _  GLOBAL_ENV_SH9
		#pragma   multi_compile  _ ENABLE_DISTANCE_ENV
		#pragma   multi_compile  _ ENABLE_BACK_LIGHT

 
#include "UnityCG.cginc"
#include "height-fog.cginc"
	struct Input {
		float3 worldPos;
		float2 uv_Control : TEXCOORD0;
		float2 uv_Splat0 : TEXCOORD1;
		float2 uv_Splat1 : TEXCOORD2;
		float2 uv_Splat2 : TEXCOORD3;
	};



	 

	void vert(inout appdata_full v) {

		float3 T1 = float3(1, 0, 1);
		float3 Bi = cross(T1, v.normal);
		float3 newTangent = cross(v.normal, Bi);

		normalize(newTangent);

		v.tangent.xyz = newTangent.xyz;

		if (dot(cross(v.normal,newTangent),Bi) < 0)
			v.tangent.w = -1.0f;
		else
			v.tangent.w = 1.0f;
	}

	sampler2D _Control;
	sampler2D _BumpSplat0, _BumpSplat1, _BumpSplat2;
	sampler2D _Splat0,_Splat1,_Splat2;
	//fixed _ShininessL0;
	//fixed _ShininessL1;
	//fixed _ShininessL2;
	fixed4 _Shininess;
	uniform float4 _WaveSpeed;
	uniform float _WaveScale;
	uniform float _WaveNormalPower;

	float4 _TopColor;
	float4	_ButtonColor;
	float _Gloss;

 
	float metallic_power;
	float3 metallic_color;

	half4 _SpecColor0;
	half4 _SpecColor1;
	half4 _SpecColor2;

	void surf(Input IN, inout SurfaceOutput o , out half3 waterNormal,out half inWater, out half3 specColor) {


		half4 temp = IN.worldPos.xzxz * _WaveScale + _WaveSpeed * _WaveScale * _Time.y;
		temp.xy *= float2(.4, .45);

		half3 splat_control = tex2D(_Control, IN.uv_Control);
		half3 col;
		half4 splat0 = tex2D(_Splat0, IN.uv_Splat0);
		half4 splat1 = tex2D(_Splat1, IN.uv_Splat1);
		//half4 splat2 = tex2D(_Splat2, IN.uv_Splat2);

		col = splat_control.r * splat0.rgb;
		o.Normal = splat_control.r * UnpackNormal(tex2D(_BumpSplat0, IN.uv_Splat0));
		 

#if SL1_BOOL
		o.Gloss = splat0.a * splat_control.r;
#endif
		o.Specular = _Shininess.r * splat_control.r;

		col += splat_control.g * splat1.rgb;
		o.Normal += splat_control.g * UnpackNormal(tex2D(_BumpSplat1, IN.uv_Splat1));

#if SL2_BOOL
		o.Gloss += splat1.a * splat_control.g;
#endif
		o.Specular += _Shininess.g * splat_control.g;


		col += splat_control.b * lerp(_TopColor,_ButtonColor, splat_control.b);// splat2.rgb;

		specColor = _SpecColor0.rgb*splat_control.r + _SpecColor1.rgb*splat_control.g + _SpecColor2.rgb*splat_control.b;
		half3 bump1 = UnpackNormal(tex2D(_BumpSplat2, temp.xy)).rgb;
		half3 bump2 = UnpackNormal(tex2D(_BumpSplat2, temp.zw)).rgb;
		half3 bump = (bump1 + bump2) * 0.5;
		half3 baseNormal = half3(0, 0, 1);
		waterNormal = o.Normal;
		waterNormal = o.Normal + splat_control.b * lerp(baseNormal,bump ,  _WaveNormalPower)  ;
		inWater = splat_control.b;
		o.Normal += splat_control.b * baseNormal;
		o.Gloss += _Gloss* splat_control.b;
		o.Specular += _Shininess.b * splat_control.b;

		o.Albedo = col;
		o.Alpha = 0.0;
	}
	

 
#ifndef LIGHTMAP_ON
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0; // _Control _Splat0
  float2 pack1 : TEXCOORD1; // _Splat1
  float4 tSpace0 : TEXCOORD2;
  float4 tSpace1 : TEXCOORD3;
  float4 tSpace2 : TEXCOORD4;
  #if UNITY_SHOULD_SAMPLE_SH
  half3 sh : TEXCOORD5; // SH
  #endif
  SHADOW_COORDS(6)
  UNITY_FOG_COORDS_EX(7)
  #if SHADER_TARGET >= 30
  float4 lmap : TEXCOORD8;
  #endif
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO
};
#endif
// with lightmaps:
#ifdef LIGHTMAP_ON
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0; // _Control _Splat0
  float2 pack1 : TEXCOORD1; // _Splat1
  float4 tSpace0 : TEXCOORD2;
  float4 tSpace1 : TEXCOORD3;
  float4 tSpace2 : TEXCOORD4;
  float4 lmap : TEXCOORD5;
  SHADOW_COORDS(6)

  UNITY_FOG_COORDS_EX(7)
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO
};
#endif
float4 _Control_ST;
float4 _Splat0_ST;
float4 _Splat1_ST;



 

// vertex shader
v2f_surf vert_surf (appdata_full v) {
	  UNITY_SETUP_INSTANCE_ID(v);
	  v2f_surf o;
	  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
	  UNITY_TRANSFER_INSTANCE_ID(v,o);
	  UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
	  vert (v);
	  o.pos = UnityObjectToClipPos(v.vertex);
	  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _Control);
	  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _Splat0);
	  o.pack1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
	  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	  fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
	  fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
	  fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
	  fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
	  o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
	  o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
	  o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
	  #ifdef DYNAMICLIGHTMAP_ON
	  o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
	  #endif
	  #ifdef LIGHTMAP_ON
	  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
	  #endif

  // SH/ambient and vertex lights
  #ifndef LIGHTMAP_ON
    #if UNITY_SHOULD_SAMPLE_SH
      o.sh = 0;
      // Approximated illumination from non-important point lights
      #ifdef VERTEXLIGHT_ON
        o.sh += Shade4PointLights (
          unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
          unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
          unity_4LightAtten0, worldPos, worldNormal);
      #endif
      o.sh = ShadeSHPerVertex (worldNormal, o.sh);
    #endif
  #endif // !LIGHTMAP_ON

	  TRANSFER_SHADOW(o); // pass shadow coordinates to pixel shader
	  //UNITY_CALC_FOG_FACTOR((o.pos).z); o.fogCoord.x = unityFogFactor;
	  // o.fogCoord.x = (o.pos).z;
	  UNITY_TRANSFER_FOG_EX(o, o.vertex,o.pos, worldNormal); // pass fog coordinates to pixel shader
	  return o;
}
 
inline float2 ToRadialCoords(float3 coords)
{
	float3 normalizedCoords = normalize(coords);
	float latitude = acos(normalizedCoords.y);
	float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
	float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
	return float2(0.5, 1.0) - sphereCoords;
}
inline fixed4 UnityBlinnPhongLightWater(SurfaceOutput s, half3 viewDir, UnityLight light, half3 waterNormal,half inWater,half3 _SpecColor0)
{
	half3 h = normalize(light.dir + viewDir);

	fixed diff = max(0, dot(s.Normal, light.dir));

	float nh = max(0, dot(waterNormal, h));
	 
	float spec = pow(nh, s.Specular*128.0) * s.Gloss;
 

	half3 viewReflectDirection = reflect(-viewDir, waterNormal);

	half2 skyUV = half2(ToRadialCoords(viewReflectDirection) );
	fixed4 localskyColor = tex2D(_Splat2, skyUV);
	//localskyColor.rgb *= exp2(localskyColor.w * 14.48538f - 3.621346f);
	metallic_power = metallic_power*inWater;

	fixed4 c;
	c.rgb = ( diff* light.color *(1.0- metallic_power) + metallic_power*localskyColor.rgb )*s.Albedo + light.color * _SpecColor0.rgb * spec ;
	//c.rgb = localskyColor.rgb;
 
	c.a = s.Alpha;
	//c = localskyColor;
	return c;
}

inline fixed4 LightingBlinnPhongWater(SurfaceOutput s, half3 viewDir, UnityGI gi,half3 waterNormal,half inWater, half3 _SpecColor0)
{
	fixed4 c;
	c = UnityBlinnPhongLightWater(s, viewDir, gi.light, waterNormal, inWater, _SpecColor0);
	
#if defined(DIRLIGHTMAP_SEPARATE)
#ifdef LIGHTMAP_ON
	c += UnityBlinnPhongLight(s, viewDir, gi.light2);
#endif
#ifdef DYNAMICLIGHTMAP_ON
	c += UnityBlinnPhongLight(s, viewDir, gi.light3);
#endif
#endif

#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
	c.rgb += s.Albedo * gi.indirect.diffuse;
#endif

	return c;
}


	fixed4 frag_surf (v2f_surf IN) : SV_Target {
	  UNITY_SETUP_INSTANCE_ID(IN);
	  // prepare and unpack data
	  Input surfIN;
	  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
	  surfIN.worldPos.x = 1.0;
	  surfIN.uv_Control.x = 1.0;
	  surfIN.uv_Splat0.x = 1.0;
	  surfIN.uv_Splat1.x = 1.0;
	  surfIN.uv_Splat2.x = 1.0;
	  surfIN.uv_Control = IN.pack0.xy;
	  surfIN.uv_Splat0 = IN.pack0.zw;
	  surfIN.uv_Splat1 = IN.pack1.xy;
	  float3 worldPos = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
	  #ifndef USING_DIRECTIONAL_LIGHT
		fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
	  #else
		fixed3 lightDir = _WorldSpaceLightPos0.xyz;
	  #endif
	  fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
	  surfIN.worldPos = worldPos;
	  #ifdef UNITY_COMPILER_HLSL
	  SurfaceOutput o = (SurfaceOutput)0;
	  #else
	  SurfaceOutput o;
	  #endif
	  o.Albedo = 0.0;
	  o.Emission = 0.0;
	  o.Specular = 0.0;
	  o.Alpha = 0.0;
	  o.Gloss = 0.0;
	  fixed3 normalWorldVertex = fixed3(0,0,1);
	  half3 waterNormal  ;
	  // call surface function
	  half inWater  ;
	  half3 _SpecColor0;
	  surf (surfIN, o, waterNormal,inWater, _SpecColor0);
	  
	  // compute lighting & shadowing factor
	  UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
	  fixed4 c = 0;

	  fixed3 worldN;
	  worldN.x = dot(IN.tSpace0.xyz, o.Normal);
	  worldN.y = dot(IN.tSpace1.xyz, o.Normal);
	  worldN.z = dot(IN.tSpace2.xyz, o.Normal);
	  o.Normal = worldN;


	  worldN.x = dot(IN.tSpace0.xyz, waterNormal);
	  worldN.y = dot(IN.tSpace1.xyz, waterNormal);
	  worldN.z = dot(IN.tSpace2.xyz, waterNormal);
 
	  waterNormal = worldN;


	  // Setup lighting environment
	  UnityGI gi;
	  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
	  gi.indirect.diffuse = 0;
	  gi.indirect.specular = 0;
	  #if !defined(LIGHTMAP_ON)
		  gi.light.color = _LightColor0.rgb;
		  gi.light.dir = lightDir;
	  #endif
	  // Call GI (lightmaps/SH/reflections) lighting function
	  UnityGIInput giInput;
	  UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
	  giInput.light = gi.light;
	  giInput.worldPos = worldPos;
	  giInput.worldViewDir = worldViewDir;
	  giInput.atten = atten;
	  #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
		giInput.lightmapUV = IN.lmap;
	  #else
		giInput.lightmapUV = 0.0;
	  #endif
	  #if UNITY_SHOULD_SAMPLE_SH
		giInput.ambient = IN.sh;
	  #else
		giInput.ambient.rgb = 0.0;
	  #endif
	  giInput.probeHDR[0] = unity_SpecCube0_HDR;
	  giInput.probeHDR[1] = unity_SpecCube1_HDR;
	  #if UNITY_SPECCUBE_BLENDING || UNITY_SPECCUBE_BOX_PROJECTION
		giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
	  #endif
	  #if UNITY_SPECCUBE_BOX_PROJECTION
		giInput.boxMax[0] = unity_SpecCube0_BoxMax;
		giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
		giInput.boxMax[1] = unity_SpecCube1_BoxMax;
		giInput.boxMin[1] = unity_SpecCube1_BoxMin;
		giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
	  #endif
	  LightingBlinnPhong_GI(o, giInput, gi);
	  //waterNormal = o.Normal;
	/*#if  defined(SHADER_API_MOBILE)
        return float4(0,1,0,1);

    #else
        return float4(1,0,0,1);
       
    #endif*/
	  c += LightingBlinnPhongWater(o, worldViewDir, gi, waterNormal,inWater, _SpecColor0);
	  APPLY_HEIGHT_FOG(c,float4(worldPos,1),waterNormal, IN.fogCoord);
	  UNITY_APPLY_FOG_MOBILE(IN.fogCoord, c); // apply fog
	  UNITY_OPAQUE_ALPHA(c.a);

	 
	  return c;
	}

	ENDCG

	}


	}
		FallBack "Specular"
}