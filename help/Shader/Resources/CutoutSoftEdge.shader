// Upgrade NOTE: replaced 'UNITY_INSTANCE_ID' with 'UNITY_VERTEX_INPUT_INSTANCE_ID'

Shader "YuLongZhi/CutoutSoftEdge"
{
	Properties
	{
		_Color("Main Color", Color) = (1, 1, 1, 1)
		_MainTex("Base (RGB) Alpha (A)", 2D) = "white" {}
		_Cutoff("Base Alpha cutoff", Range(0, .9)) = .5
	}

	SubShader {
		Tags { "Queue" = "AlphaTest-1" }

		Pass{
			Name "BaseClip"
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma multi_compile_fog
#pragma multi_compile_fwdbase
#pragma multi_compile __ BRIGHTNESS_ON
#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#define UNITY_PASS_FORWARDBASE
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

		fixed4 _Color;
		sampler2D _MainTex;
		fixed _Cutoff;

#ifdef BRIGHTNESS_ON
		fixed3 _Brightness;
#endif

		struct Input {
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			clip(c.a - _Cutoff);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

#ifdef LIGHTMAP_OFF
		struct v2f_surf {
			float4 pos : SV_POSITION;
			float2 pack0 : TEXCOORD0; // _MainTex
			half3 worldNormal : TEXCOORD1;
			float3 worldPos : TEXCOORD2;
#if UNITY_SHOULD_SAMPLE_SH
			half3 sh : TEXCOORD3; // SH
#endif
			SHADOW_COORDS(4)
				UNITY_FOG_COORDS(5)
#if SHADER_TARGET >= 30
				float4 lmap : TEXCOORD6;
#endif
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};
#endif
		// with lightmaps:
#ifndef LIGHTMAP_OFF
		struct v2f_surf {
			float4 pos : SV_POSITION;
			float2 pack0 : TEXCOORD0; // _MainTex
			half3 worldNormal : TEXCOORD1;
			float3 worldPos : TEXCOORD2;
			float4 lmap : TEXCOORD3;
			SHADOW_COORDS(4)
				UNITY_FOG_COORDS(5)
#ifdef DIRLIGHTMAP_COMBINED
				fixed3 tSpace0 : TEXCOORD6;
			fixed3 tSpace1 : TEXCOORD7;
			fixed3 tSpace2 : TEXCOORD8;
#endif
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};
#endif
		float4 _MainTex_ST;

		// vertex shader
		v2f_surf vert_surf(appdata_full v) {
			UNITY_SETUP_INSTANCE_ID(v);
			v2f_surf o;
			UNITY_INITIALIZE_OUTPUT(v2f_surf, o);
			UNITY_TRANSFER_INSTANCE_ID(v, o);
			o.pos = UnityObjectToClipPos(v.vertex);
			o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
#if !defined(LIGHTMAP_OFF) && defined(DIRLIGHTMAP_COMBINED)
			fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
			fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
			fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
#endif
#if !defined(LIGHTMAP_OFF) && defined(DIRLIGHTMAP_COMBINED)
			o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
			o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
			o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
#endif
			o.worldPos = worldPos;
			o.worldNormal = worldNormal;
#ifndef DYNAMICLIGHTMAP_OFF
			o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
#ifndef LIGHTMAP_OFF
			o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif

			// SH/ambient and vertex lights
#ifdef LIGHTMAP_OFF
#if UNITY_SHOULD_SAMPLE_SH
			o.sh = 0;
			// Approximated illumination from non-important point lights
#ifdef VERTEXLIGHT_ON
			o.sh += Shade4PointLights(
				unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
				unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
				unity_4LightAtten0, worldPos, worldNormal);
#endif
			o.sh = ShadeSHPerVertex(worldNormal, o.sh);
#endif
#endif // LIGHTMAP_OFF

			TRANSFER_SHADOW(o); // pass shadow coordinates to pixel shader
			UNITY_TRANSFER_FOG(o, o.pos); // pass fog coordinates to pixel shader
			return o;
		}

		// fragment shader
		fixed4 frag_surf(v2f_surf IN) : SV_Target{
			UNITY_SETUP_INSTANCE_ID(IN);
		// prepare and unpack data
		Input surfIN;
		UNITY_INITIALIZE_OUTPUT(Input, surfIN);
		surfIN.uv_MainTex.x = 1.0;
		surfIN.uv_MainTex = IN.pack0.xy;
		float3 worldPos = IN.worldPos;
#ifndef USING_DIRECTIONAL_LIGHT
		fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
#else
		fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#endif
#ifdef UNITY_COMPILER_HLSL
		SurfaceOutput o = (SurfaceOutput) 0;
#else
		SurfaceOutput o;
#endif
		o.Albedo = 0.0;
		o.Emission = 0.0;
		o.Specular = 0.0;
		o.Alpha = 0.0;
		o.Gloss = 0.0;
		fixed3 normalWorldVertex = fixed3(0, 0, 1);
		o.Normal = IN.worldNormal;
		normalWorldVertex = IN.worldNormal;

		// call surface function
		surf(surfIN, o);

		// compute lighting & shadowing factor
		UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
			fixed4 c = 0;

		// Setup lighting environment
		UnityGI gi;
		UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
		gi.indirect.diffuse = 0;
		gi.indirect.specular = 0;
#if !defined(LIGHTMAP_ON)
		gi.light.color = _LightColor0.rgb;
		gi.light.dir = lightDir;
		gi.light.ndotl = LambertTerm(o.Normal, gi.light.dir);
#endif
		// Call GI (lightmaps/SH/reflections) lighting function
		UnityGIInput giInput;
		UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
		giInput.light = gi.light;
		giInput.worldPos = worldPos;
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
		LightingLambert_GI(o, giInput, gi);

		// realtime lighting: call lighting function
		c += LightingLambert(o, gi);

#ifdef BRIGHTNESS_ON
		c.rgb = c.rgb * _Brightness * 2;
#endif

		UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
		return c;
		}

			ENDCG

		}

		Pass{
			Name "BaseTransparent"
			Tags{ "LightMode" = "ForwardBase" }
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma multi_compile_fog
#pragma multi_compile_fwdbase
#pragma multi_compile __ BRIGHTNESS_ON
#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#define UNITY_PASS_FORWARDBASE
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

		fixed4 _Color;
		sampler2D _MainTex;
		fixed _Cutoff;

#ifdef BRIGHTNESS_ON
		fixed3 _Brightness;
#endif

		struct Input {
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			clip(-(c.a - _Cutoff));
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

#ifdef LIGHTMAP_OFF
		struct v2f_surf {
			float4 pos : SV_POSITION;
			float2 pack0 : TEXCOORD0; // _MainTex
			half3 worldNormal : TEXCOORD1;
			float3 worldPos : TEXCOORD2;
#if UNITY_SHOULD_SAMPLE_SH
			half3 sh : TEXCOORD3; // SH
#endif
			SHADOW_COORDS(4)
				UNITY_FOG_COORDS(5)
#if SHADER_TARGET >= 30
				float4 lmap : TEXCOORD6;
#endif
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};
#endif
		// with lightmaps:
#ifndef LIGHTMAP_OFF
		struct v2f_surf {
			float4 pos : SV_POSITION;
			float2 pack0 : TEXCOORD0; // _MainTex
			half3 worldNormal : TEXCOORD1;
			float3 worldPos : TEXCOORD2;
			float4 lmap : TEXCOORD3;
			SHADOW_COORDS(4)
				UNITY_FOG_COORDS(5)
#ifdef DIRLIGHTMAP_COMBINED
				fixed3 tSpace0 : TEXCOORD6;
			fixed3 tSpace1 : TEXCOORD7;
			fixed3 tSpace2 : TEXCOORD8;
#endif
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};
#endif
		float4 _MainTex_ST;

		// vertex shader
		v2f_surf vert_surf(appdata_full v) {
			UNITY_SETUP_INSTANCE_ID(v);
			v2f_surf o;
			UNITY_INITIALIZE_OUTPUT(v2f_surf, o);
			UNITY_TRANSFER_INSTANCE_ID(v, o);
			o.pos = UnityObjectToClipPos(v.vertex);
			o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
#if !defined(LIGHTMAP_OFF) && defined(DIRLIGHTMAP_COMBINED)
			fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
			fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
			fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
#endif
#if !defined(LIGHTMAP_OFF) && defined(DIRLIGHTMAP_COMBINED)
			o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
			o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
			o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
#endif
			o.worldPos = worldPos;
			o.worldNormal = worldNormal;
#ifndef DYNAMICLIGHTMAP_OFF
			o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
#ifndef LIGHTMAP_OFF
			o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif

			// SH/ambient and vertex lights
#ifdef LIGHTMAP_OFF
#if UNITY_SHOULD_SAMPLE_SH
			o.sh = 0;
			// Approximated illumination from non-important point lights
#ifdef VERTEXLIGHT_ON
			o.sh += Shade4PointLights(
				unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
				unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
				unity_4LightAtten0, worldPos, worldNormal);
#endif
			o.sh = ShadeSHPerVertex(worldNormal, o.sh);
#endif
#endif // LIGHTMAP_OFF

			TRANSFER_SHADOW(o); // pass shadow coordinates to pixel shader
			UNITY_TRANSFER_FOG(o, o.pos); // pass fog coordinates to pixel shader
			return o;
		}

		// fragment shader
		fixed4 frag_surf(v2f_surf IN) : SV_Target{
			UNITY_SETUP_INSTANCE_ID(IN);
		// prepare and unpack data
		Input surfIN;
		UNITY_INITIALIZE_OUTPUT(Input, surfIN);
		surfIN.uv_MainTex.x = 1.0;
		surfIN.uv_MainTex = IN.pack0.xy;
		float3 worldPos = IN.worldPos;
#ifndef USING_DIRECTIONAL_LIGHT
		fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
#else
		fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#endif
#ifdef UNITY_COMPILER_HLSL
		SurfaceOutput o = (SurfaceOutput) 0;
#else
		SurfaceOutput o;
#endif
		o.Albedo = 0.0;
		o.Emission = 0.0;
		o.Specular = 0.0;
		o.Alpha = 0.0;
		o.Gloss = 0.0;
		fixed3 normalWorldVertex = fixed3(0, 0, 1);
		o.Normal = IN.worldNormal;
		normalWorldVertex = IN.worldNormal;

		// call surface function
		surf(surfIN, o);

		// compute lighting & shadowing factor
		UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
			fixed4 c = 0;

		// Setup lighting environment
		UnityGI gi;
		UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
		gi.indirect.diffuse = 0;
		gi.indirect.specular = 0;
#if !defined(LIGHTMAP_ON)
		gi.light.color = _LightColor0.rgb;
		gi.light.dir = lightDir;
		gi.light.ndotl = LambertTerm(o.Normal, gi.light.dir);
#endif
		// Call GI (lightmaps/SH/reflections) lighting function
		UnityGIInput giInput;
		UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
		giInput.light = gi.light;
		giInput.worldPos = worldPos;
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
		LightingLambert_GI(o, giInput, gi);

		// realtime lighting: call lighting function
		c += LightingLambert(o, gi);

#ifdef BRIGHTNESS_ON
		c.rgb = c.rgb * _Brightness * 2;
#endif

		UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
		return c;
		}

			ENDCG

		}

		Pass{
			Name "AddClip"
			Tags{ "LightMode" = "ForwardAdd" }
			ZWrite Off Blend One One

			CGPROGRAM
			// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma multi_compile_fog
#pragma multi_compile_fwdadd
#pragma skip_variants INSTANCING_ON
#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#define UNITY_PASS_FORWARDADD
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

			fixed4 _Color;
		sampler2D _MainTex;
		fixed _Cutoff;

		struct Input {
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			clip(c.a - _Cutoff);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}


		// vertex-to-fragment interpolation data
		struct v2f_surf {
			float4 pos : SV_POSITION;
			float2 pack0 : TEXCOORD0; // _MainTex
			half3 worldNormal : TEXCOORD1;
			float3 worldPos : TEXCOORD2;
			SHADOW_COORDS(3)
				UNITY_FOG_COORDS(4)
		};
		float4 _MainTex_ST;

		// vertex shader
		v2f_surf vert_surf(appdata_full v) {
			v2f_surf o;
			UNITY_INITIALIZE_OUTPUT(v2f_surf, o);
			o.pos = UnityObjectToClipPos(v.vertex);
			o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
			o.worldPos = worldPos;
			o.worldNormal = worldNormal;

			TRANSFER_SHADOW(o); // pass shadow coordinates to pixel shader
			UNITY_TRANSFER_FOG(o, o.pos); // pass fog coordinates to pixel shader
			return o;
		}

		// fragment shader
		fixed4 frag_surf(v2f_surf IN) : SV_Target{
			// prepare and unpack data
			Input surfIN;
		UNITY_INITIALIZE_OUTPUT(Input, surfIN);
		surfIN.uv_MainTex.x = 1.0;
		surfIN.uv_MainTex = IN.pack0.xy;
		float3 worldPos = IN.worldPos;
#ifndef USING_DIRECTIONAL_LIGHT
		fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
#else
		fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#endif
#ifdef UNITY_COMPILER_HLSL
		SurfaceOutput o = (SurfaceOutput) 0;
#else
		SurfaceOutput o;
#endif
		o.Albedo = 0.0;
		o.Emission = 0.0;
		o.Specular = 0.0;
		o.Alpha = 0.0;
		o.Gloss = 0.0;
		fixed3 normalWorldVertex = fixed3(0, 0, 1);
		o.Normal = IN.worldNormal;
		normalWorldVertex = IN.worldNormal;

		// call surface function
		surf(surfIN, o);
		UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
			fixed4 c = 0;

		// Setup lighting environment
		UnityGI gi;
		UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
		gi.indirect.diffuse = 0;
		gi.indirect.specular = 0;
#if !defined(LIGHTMAP_ON)
		gi.light.color = _LightColor0.rgb;
		gi.light.dir = lightDir;
		gi.light.ndotl = LambertTerm(o.Normal, gi.light.dir);
#endif
		gi.light.color *= atten;
		c += LightingLambert(o, gi);
		UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
		return c;
		}

			ENDCG

		}

			Pass{
			Name "AddTransparent"
			Tags{ "LightMode" = "ForwardAdd" }
			ZWrite Off
			Blend SrcAlpha One

			CGPROGRAM
			// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma multi_compile_fog
#pragma multi_compile_fwdadd
#pragma skip_variants INSTANCING_ON
#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#define UNITY_PASS_FORWARDADD
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

			fixed4 _Color;
		sampler2D _MainTex;
		fixed _Cutoff;

		struct Input {
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			clip(-(c.a - _Cutoff));
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}


		// vertex-to-fragment interpolation data
		struct v2f_surf {
			float4 pos : SV_POSITION;
			float2 pack0 : TEXCOORD0; // _MainTex
			half3 worldNormal : TEXCOORD1;
			float3 worldPos : TEXCOORD2;
			SHADOW_COORDS(3)
				UNITY_FOG_COORDS(4)
		};
		float4 _MainTex_ST;

		// vertex shader
		v2f_surf vert_surf(appdata_full v) {
			v2f_surf o;
			UNITY_INITIALIZE_OUTPUT(v2f_surf, o);
			o.pos = UnityObjectToClipPos(v.vertex);
			o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
			o.worldPos = worldPos;
			o.worldNormal = worldNormal;

			TRANSFER_SHADOW(o); // pass shadow coordinates to pixel shader
			UNITY_TRANSFER_FOG(o, o.pos); // pass fog coordinates to pixel shader
			return o;
		}

		// fragment shader
		fixed4 frag_surf(v2f_surf IN) : SV_Target{
			// prepare and unpack data
			Input surfIN;
		UNITY_INITIALIZE_OUTPUT(Input, surfIN);
		surfIN.uv_MainTex.x = 1.0;
		surfIN.uv_MainTex = IN.pack0.xy;
		float3 worldPos = IN.worldPos;
#ifndef USING_DIRECTIONAL_LIGHT
		fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
#else
		fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#endif
#ifdef UNITY_COMPILER_HLSL
		SurfaceOutput o = (SurfaceOutput) 0;
#else
		SurfaceOutput o;
#endif
		o.Albedo = 0.0;
		o.Emission = 0.0;
		o.Specular = 0.0;
		o.Alpha = 0.0;
		o.Gloss = 0.0;
		fixed3 normalWorldVertex = fixed3(0, 0, 1);
		o.Normal = IN.worldNormal;
		normalWorldVertex = IN.worldNormal;

		// call surface function
		surf(surfIN, o);
		UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
			fixed4 c = 0;

		// Setup lighting environment
		UnityGI gi;
		UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
		gi.indirect.diffuse = 0;
		gi.indirect.specular = 0;
#if !defined(LIGHTMAP_ON)
		gi.light.color = _LightColor0.rgb;
		gi.light.dir = lightDir;
		gi.light.ndotl = LambertTerm(o.Normal, gi.light.dir);
#endif
		gi.light.color *= atten;
		c += LightingLambert(o, gi);
		UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
		return c;
		}

			ENDCG

		}
		

		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
	}
}
