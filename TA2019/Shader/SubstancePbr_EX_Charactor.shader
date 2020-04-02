// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:3,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:True,hqlp:False,rprd:True,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,billboard:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:2865,x:33009,y:32767,varname:node_2865,prsc:2|diff-6343-OUT,spec-3345-OUT,gloss-6256-OUT,normal-5964-RGB;n:type:ShaderForge.SFN_Multiply,id:6343,x:32385,y:32538,varname:node_6343,prsc:2|A-7736-RGB,B-6665-RGB;n:type:ShaderForge.SFN_Color,id:6665,x:32022,y:32613,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Tex2d,id:7736,x:32055,y:32382,ptovrint:True,ptlb:Albedo,ptin:_MainTex,varname:_MainTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:5964,x:32425,y:33140,ptovrint:True,ptlb:Normal Map,ptin:_BumpMap,varname:_BumpMap,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Slider,id:358,x:32250,y:32780,ptovrint:False,ptlb:MetallicPower,ptin:_MetallicPower,varname:node_358,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Slider,id:1813,x:32125,y:33024,ptovrint:False,ptlb:GlossPower,ptin:_GlossPower,varname:_Metallic_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Tex2d,id:8912,x:32385,y:32373,ptovrint:False,ptlb:Metallic,ptin:_Metallic,varname:node_8912,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:3345,x:32692,y:32503,varname:node_3345,prsc:2|A-8912-R,B-358-OUT;n:type:ShaderForge.SFN_Multiply,id:6256,x:32619,y:32793,varname:node_6256,prsc:2|A-8912-A,B-1813-OUT;proporder:5964-6665-7736-358-1813-8912;pass:END;sub:END;*/

Shader "TA/Substance PBR EX Charactor" {
	Properties{
		_BumpMap("Normal Map", 2D) = "bump" {}
		_Color("Color", Color) = (1,1,1,1)
		 

		//_AmbTex("_AmbTex", 2D) = "white" {}
		
		_MainTex("Albedo", 2D) = "white" {}

		_MetallicPower("MetallicPower", Range(0, 1)) = 1
		_GlossPower("GlossPower", Range(0, 1)) = 1
		_Metallic("Metallic", 2D) = "white" {}
		_Metallic2("Metallic2", 2D) = "white" {}
		emissive_power("自发光强度", Range(0, 1)) = 0
		[KeywordEnum(On,Off)] _IsMetallic("是否开启金属度", Float) = 0

 
		_BRDFTex("SSS brdf贴图", 2D) = "gray" {}
		_S3SPower("SSS强度",Range(0,1)) = 1
		[Enum(UnityEngine.Rendering.CullMode)] _Cull("Off为双面贴图", Float) = 2


		[Toggle(_NO_SCENE_SHADOW2)] _NO_SCENE_SHADOW2("不受场景阴影", Float) = 0
			
		 [Toggle(ANISOTROPIC_NORMAL)] ANISOTROPIC_NORMAL("各向异性高光", Float) = 0
		 anisotropy("anisotropy",Range(-20,1)) = 1

		 _Color3("Color3", Color) = (1,1,1,1)
	
	}
		SubShader{
			Tags {
				"RenderType" = "Opaque"
			}
			Cull[_Cull]
			Pass {
				Name "FORWARD"
				Tags {
					"LightMode" = "ForwardBase"
				}

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				//#pragma multi_compile_fwdbase

				#define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
				#define _GLOSSYENV 1
				
				
	 

				#pragma multi_compile _ISMETALLIC_ON _ISMETALLIC_OFF 

				//#pragma   multi_compile  _  FOG_LIGHT
				 
 
				#define _ISWEATHER_ON 1
				
 

				#pragma multi_compile __ GLOBAL_SH9_ROLE
				#define LIGHT_CTRL 1

				#pragma   multi_compile  _ _NO_SCENE_SHADOW2
 
				#pragma  multi_compile  __ _SCENE_SHADOW2
				
				#define TEX_CTRL2 1
				#define SSS_IN_CTRL2 1
				//#define SSS_EFFECT 1
	 
				#pragma   multi_compile  _ ANISOTROPIC_NORMAL
				//#pragma multi_compile __ SSS_EFFECT  
				#define COLOR2_CTRL 1
				#include "AutoLight.cginc"
				#include "Lighting.cginc"
				#include "unity_pbr-simple.cginc"
				ENDCG
				}
																											 
		}
		FallBack "Diffuse"
																																																	CustomEditor "ShaderForgeMaterialInspector"
}
