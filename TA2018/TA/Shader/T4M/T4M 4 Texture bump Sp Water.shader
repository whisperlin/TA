// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:3,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:True,hqlp:False,rprd:True,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,billboard:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:2865,x:33120,y:32694,varname:node_2865,prsc:2|diff-3450-OUT,spec-358-OUT,gloss-135-OUT,normal-3787-OUT;n:type:ShaderForge.SFN_Slider,id:358,x:32089,y:32478,ptovrint:False,ptlb:Metallic,ptin:_Metallic,varname:node_358,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Slider,id:1813,x:31984,y:32836,ptovrint:False,ptlb:Gloss,ptin:_Glossiness,varname:_Metallic_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Tex2d,id:8231,x:31768,y:31793,ptovrint:False,ptlb:Splat0,ptin:_Splat0,varname:node_8231,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:8189,x:31768,y:31978,ptovrint:False,ptlb:Splat1,ptin:_Splat1,varname:node_8189,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:882,x:31747,y:32154,ptovrint:False,ptlb:Splat2,ptin:_Splat2,varname:node_882,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:211,x:31722,y:32342,ptovrint:False,ptlb:Splat3,ptin:_Splat3,varname:node_211,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:8025,x:33204,y:31672,ptovrint:False,ptlb:BumpSplat0,ptin:_BumpSplat0,varname:node_8025,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Tex2d,id:5289,x:33204,y:31888,ptovrint:False,ptlb:BumpSplat1,ptin:_BumpSplat1,varname:node_5289,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Tex2d,id:5537,x:33215,y:32088,ptovrint:False,ptlb:BumpSplat2,ptin:_BumpSplat2,varname:node_5537,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Tex2d,id:3058,x:33215,y:32276,ptovrint:False,ptlb:BumpSplat3,ptin:_BumpSplat3,varname:node_3058,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:5157,x:31768,y:31541,ptovrint:False,ptlb:Control,ptin:_Control,varname:node_5157,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:3924,x:32450,y:31754,varname:node_3924,prsc:2|A-8231-RGB,B-5157-R;n:type:ShaderForge.SFN_Multiply,id:559,x:32450,y:31916,varname:node_559,prsc:2|A-8189-RGB,B-5157-G;n:type:ShaderForge.SFN_Multiply,id:2778,x:32450,y:32064,varname:node_2778,prsc:2|A-882-RGB,B-5157-B;n:type:ShaderForge.SFN_Multiply,id:7915,x:32347,y:32243,varname:node_7915,prsc:2|A-211-RGB,B-5157-A;n:type:ShaderForge.SFN_Add,id:3391,x:32704,y:31754,varname:node_3391,prsc:2|A-3924-OUT,B-559-OUT;n:type:ShaderForge.SFN_Add,id:2055,x:32726,y:32020,varname:node_2055,prsc:2|A-3391-OUT,B-2778-OUT;n:type:ShaderForge.SFN_Add,id:3450,x:32711,y:32242,varname:node_3450,prsc:2|A-2055-OUT,B-7915-OUT;n:type:ShaderForge.SFN_Multiply,id:7768,x:33536,y:31712,varname:node_7768,prsc:2|A-8025-RGB,B-5157-R;n:type:ShaderForge.SFN_Multiply,id:5981,x:33536,y:31911,varname:node_5981,prsc:2|A-5289-RGB,B-5157-G;n:type:ShaderForge.SFN_Multiply,id:8685,x:33536,y:32085,varname:node_8685,prsc:2|A-5537-RGB,B-5157-B;n:type:ShaderForge.SFN_Multiply,id:6339,x:33536,y:32277,varname:node_6339,prsc:2|A-3058-RGB,B-5157-A;n:type:ShaderForge.SFN_Add,id:2667,x:33761,y:31831,varname:node_2667,prsc:2|A-7768-OUT,B-5981-OUT;n:type:ShaderForge.SFN_Add,id:6221,x:33785,y:32005,varname:node_6221,prsc:2|A-2667-OUT,B-8685-OUT;n:type:ShaderForge.SFN_Add,id:3787,x:33785,y:32233,varname:node_3787,prsc:2|A-6221-OUT,B-6339-OUT;n:type:ShaderForge.SFN_Multiply,id:4160,x:32318,y:30663,varname:node_4160,prsc:2|A-8231-A,B-5157-R;n:type:ShaderForge.SFN_Multiply,id:2903,x:32493,y:30913,varname:node_2903,prsc:2|A-8231-A,B-5157-G;n:type:ShaderForge.SFN_Multiply,id:4466,x:32449,y:31163,varname:node_4466,prsc:2|A-8189-A,B-5157-B;n:type:ShaderForge.SFN_Multiply,id:2034,x:32449,y:31399,varname:node_2034,prsc:2|A-882-A,B-5157-A;n:type:ShaderForge.SFN_Add,id:9810,x:32770,y:30752,varname:node_9810,prsc:2|A-4160-OUT,B-2903-OUT;n:type:ShaderForge.SFN_Add,id:5116,x:32890,y:31151,varname:node_5116,prsc:2|A-9810-OUT,B-4466-OUT;n:type:ShaderForge.SFN_Add,id:8112,x:32838,y:31440,varname:node_8112,prsc:2|A-5116-OUT,B-2034-OUT;n:type:ShaderForge.SFN_Multiply,id:135,x:32959,y:33193,varname:node_135,prsc:2|A-1813-OUT,B-8112-OUT;proporder:358-1813-8231-8189-882-211-5157-8025-5289-5537-3058;pass:END;sub:END;*/

Shader "TA/T4M/T4M 4 Texture bump Sp Water" {
    Properties {
        //_Metallic ("Metallic", Range(0, 1)) = 0
        _Glossiness ("Gloss", Range(0, 1)) = 1
        _Splat0 ("Splat0", 2D) = "white" {}
        _Splat1 ("Splat1", 2D) = "white" {}
        _Splat2 ("Splat2", 2D) = "white" {}
        _Splat3 ("Splat3", 2D) = "white" {}
        _Control ("Control", 2D) = "white" {}
        _BumpSplat0 ("BumpSplat0", 2D) = "bump" {}
        _BumpSplat1 ("BumpSplat1", 2D) = "bump" {}
        _BumpSplat2 ("BumpSplat2", 2D) = "bump" {}
        _BumpSplat3 ("BumpSplat3", 2D) = "white" {}


		_TopColor("浅水色", Color) = (0.619, 0.759, 1, 1)
		_ButtonColor("深水色", Color) = (0.35, 0.35, 0.35, 1)
		_Gloss4("水高光锐度", Range(0,1)) = 0.5
		_WaveNormalPower("水法线强度",Range(0,1)) = 1
		_GNormalPower("地表法线强度",Range(0,1)) = 1
		_WaveScale("水波纹缩放", Range(0.02,0.15)) = .07
		_WaveSpeed("水流动速度", Vector) = (19,9,-16,-7)
		_SpColor4("水高光色", Color) = (1, 1, 1, 1)
		[KeywordEnum(Off, On)] _IsMetallic("是否开启金属度", Float) = 0
		metallic_power("天空强度", Range(0,1)) = 1

		[Toggle]_snow_options("----------雪选项-----------",int) = 1
		[MaterialToggle] MELT_SNOW("消融雪", Float) = 0
		//_Color3("自发光颜色", Color) = (1,1,1,1)
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
 
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
 

			#define _ISWEATHER_ON 1
			#pragma multi_compile __ SNOW_ENABLE
			#pragma multi_compile __ RAIN_ENABLE
			#pragma multi_compile __ COMBINE_SHADOWMARK
			#pragma multi_compile _ISMETALLIC_OFF _ISMETALLIC_ON  
			#pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#define SHADOWS_SHADOWMASK 1
 
			#include "../shadowmarkex.cginc"

			#include "../FogCommon.cginc"
			#include "../SceneWeather.inc" 
			#include "../snow.cginc"
 
 
            #pragma target 3.0
            uniform float _Metallic;
            uniform float _Glossiness;
            uniform sampler2D _Splat0; uniform float4 _Splat0_ST;
            uniform sampler2D _Splat1; uniform float4 _Splat1_ST;
            uniform sampler2D _Splat2; uniform float4 _Splat2_ST;
            uniform sampler2D _Splat3; uniform float4 _Splat3_ST;
            uniform sampler2D _BumpSplat0; uniform float4 _BumpSplat0_ST;
            uniform sampler2D _BumpSplat1; uniform float4 _BumpSplat1_ST;
            uniform sampler2D _BumpSplat2; uniform float4 _BumpSplat2_ST;
            uniform sampler2D _BumpSplat3; uniform float4 _BumpSplat3_ST;
            uniform sampler2D _Control; uniform float4 _Control_ST;


			uniform float4 _WaveSpeed;
			uniform float _WaveScale;
			uniform float _WaveNormalPower;
			uniform float _GNormalPower;
			float4 _TopColor;
			float4	_ButtonColor;
			float _Gloss4;
			float metallic_power;

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
 
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
 
 
                float4 worldPos : TEXCOORD3;
                //float3 normalDir : TEXCOORD4;
                //float3 tangentDir : TEXCOORD5;
                //float3 bitangentDir : TEXCOORD6;

				half3 tspace0 : TEXCOORD4; // tangent.x, bitangent.x, normal.x
				half3 tspace1 : TEXCOORD5; // tangent.y, bitangent.y, normal.y
				half3 tspace2 : TEXCOORD6; // tangent.z, bitangent.z, normal.z
 
				UBPA_FOG_COORDS(9) 
               
				float3 sh : TEXCOORD10;
				SHADOW_UVS(7, 8)
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;

#if COMBINE_SHADOWMARK
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
#endif
                o.uv0 = v.texcoord0;
              
 
               
 


				half3 wNormal = UnityObjectToWorldNormal(v.normal);
				half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
				// compute bitangent from cross product of normal and tangent
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
				// output the tangent space matrix
				o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
				o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
				o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);


                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );

				VS_FILL_SHADOW_DATA(o, v.texcoord1);
 
				o.sh.xyz = ShadeSH9(half4(wNormal, 1)).rgb;
 
				UBPA_TRANSFER_FOG(o, v.vertex);
                return o;
            }
			fixed3 UnpackNormalmapRG(fixed4 packednormal)
			{
				fixed3 normal;
				normal.xy = packednormal.xy * 2 - 1;
				normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
				return normal;
			}
			inline float2 ToRadialCoords(float3 coords)
			{
				float3 normalizedCoords = normalize(coords);
				float latitude = acos(normalizedCoords.y);
				float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
				float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
				return float2(0.5, 1.0) - sphereCoords;
			}
            float4 frag(VertexOutput i) : COLOR {
				#if COMBINE_SHADOWMARK
					UNITY_SETUP_INSTANCE_ID(i);
				#endif
				GET_LIGHT_MAP_DATA(i,uv1);
                //i.normalDir = normalize(i.normalDir);
                //float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                float3 _BumpSplat0_var = UnpackNormalmapRG(tex2D(_BumpSplat0,TRANSFORM_TEX(i.uv0, _Splat0)));
                float4 _Control_var = tex2D(_Control,TRANSFORM_TEX(i.uv0, _Control));
                float3 _BumpSplat1_var = UnpackNormalmapRG(tex2D(_BumpSplat1,TRANSFORM_TEX(i.uv0, _Splat1)));
                float3 _BumpSplat2_var = UnpackNormalmapRG(tex2D(_BumpSplat2,TRANSFORM_TEX(i.uv0, _Splat2)));
                //float3 _BumpSplat3_var = UnpackNormalmapRG(tex2D(_BumpSplat3,TRANSFORM_TEX(i.uv0, _Splat3)));


				half4 temp = i.worldPos.xzxz * _WaveScale + _WaveSpeed * _WaveScale * _Time.y; 
				temp.xy *= float2(.4, .45); 
				half3 bump1 = UnpackNormal(tex2D(_BumpSplat3, temp.xy)).rgb; 
				half3 bump2 = UnpackNormal(tex2D(_BumpSplat3, temp.zw)).rgb;
				half3 bump = normalize( (bump1 + bump2) * 0.5);
		 
				bump = lerp(float3(0,0,1), bump,_WaveNormalPower);
 

                float3 normalLocal = ((((_BumpSplat0_var.rgb*_Control_var.r)+(_BumpSplat1_var.rgb*_Control_var.g))+(_BumpSplat2_var.rgb*_Control_var.b))+(bump.rgb*_Control_var.a));

				normalLocal = normalize(normalLocal.xyz);
				half3 normalDirection;
				normalDirection.x = dot(i.tspace0, normalLocal);
				normalDirection.y = dot(i.tspace1, normalLocal);
				normalDirection.z = dot(i.tspace2, normalLocal);
				normalLocal = normalize(normalLocal.xyz);

                //float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals

#if _ISWEATHER_ON

#if SNOW_ENABLE 
				//i.normalDir.xyz
				fixed nt;
				CmpSnowNormalAndPower(i.uv0, normalize(half3(i.tspace0.z, i.tspace1.z, i.tspace2.z))   , nt, normalDirection);
				
#endif
#endif

                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:

                float3 attenColor = attenuation * _LightColor0.xyz;
                float Pi = 3.141592654;
                float InvPi = 0.31830988618;
///////// Gloss:
                float4 _Splat0_var = tex2D(_Splat0,TRANSFORM_TEX(i.uv0, _Splat0));
                float4 _Splat1_var = tex2D(_Splat1,TRANSFORM_TEX(i.uv0, _Splat1));
                float4 _Splat2_var = tex2D(_Splat2,TRANSFORM_TEX(i.uv0, _Splat2));
				
                float gloss = (_Glossiness*((((_Splat0_var.a*_Control_var.r)+(_Splat1_var.a*_Control_var.g))+(_Splat2_var.a*_Control_var.b))+(_Gloss4*_Control_var.a)));


#if _ISWEATHER_ON
#if RAIN_ENABLE  
				gloss = saturate(gloss* get_smoothnessRate());
#endif
#if(SNOW_ENABLE)
				gloss = lerp(gloss, _SnowGloss, nt);
#endif
#endif
				 
			 
                float perceptualRoughness = 1.0 - gloss;
                float roughness = perceptualRoughness * perceptualRoughness;
                float specPow = exp2( gloss * 10.0 + 1.0 );
/////// GI Data:
				UnityLight light;
#ifdef LIGHTMAP_OFF
				light.color = lightColor;
				light.dir = lightDirection;
				light.ndotl = LambertTerm(normalDirection, light.dir);
#else
				light.color = half3(0.f, 0.f, 0.f);
				light.ndotl = 0.0f;
				light.dir = half3(0.f, 0.f, 0.f);
#endif
				UnityGIInput d;
				d.light = light;
				d.worldPos = i.worldPos.xyz;
				d.worldViewDir = viewDirection;
				d.atten = attenuation;
#if defined(LIGHTMAP_ON)  
				d.ambient = 0;
				d.lightmapUV.xy = i.uv1.xy;
				d.lightmapUV.zw = 0;
#else
				d.ambient = i.sh.rgb;
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
				//lightDirection = gi.light.dir;
				//lightColor = gi.light.color;

////// Specular:
                float NdotL = saturate(dot( normalDirection, lightDirection ));
                float LdotH = saturate(dot(lightDirection, halfDirection));

#if _ISMETALLIC_OFF
				float3 specularColor = 0;
#else
				float _metallic = metallic_power * _Control_var.a;
				float3 specularColor = _metallic;
#endif
 
                //float3 specularColor = _Metallic;
                float specularMonochrome;
/*#if _ISMETALLIC_OFF
				half3 waterColor = lerp(_TopColor, _ButtonColor, _Control_var.a);

#else
				//float4 _Splat3_var = tex2D(_Splat3, TRANSFORM_TEX(i.uv0, _Splat3));
	 
				//half2 skyUV = half2(ToRadialCoords(viewReflectDirection)); 
				//float4 _Splat3_var = tex2D(_Splat3, skyUV);
				//half3 waterColor = lerp(_TopColor, _ButtonColor, _Control_var.a)* lerp(half3(1, 1, 1), _Splat3_var.rgb, metallic_power);

#endif*/
				half3 waterColor = lerp(_TopColor, _ButtonColor, _Control_var.a);
                
                float3 diffuseColor = ((((_Splat0_var.rgb*_Control_var.r)+(_Splat1_var.rgb*_Control_var.g))+(_Splat2_var.rgb*_Control_var.b))+(waterColor.rgb*_Control_var.a)); // Need this for specular when using metallic
				

#if _ISMETALLIC_OFF
				diffuseColor = DiffuseAndSpecularFromMetallic(diffuseColor, specularColor, specularColor, specularMonochrome);
#else
				diffuseColor = DiffuseAndSpecularFromMetallic(diffuseColor, specularColor, specularColor, specularMonochrome);
#endif

#if _ISWEATHER_ON
#if RAIN_ENABLE 

				calc_weather_info(i.worldPos.xyz, normalDirection, normalDirection, diffuseColor, normalDirection, diffuseColor.rgb);
#endif
#if SNOW_ENABLE 
				
				diffuseColor.rgb = lerp(diffuseColor.rgb, _SnowColor.rgb, nt *_SnowColor.a);
#endif
#endif
				
 
                specularMonochrome = 1.0-specularMonochrome;
                float NdotV = abs(dot( normalDirection, viewDirection ));
                float NdotH = saturate(dot( normalDirection, halfDirection ));
                float VdotH = saturate(dot( viewDirection, halfDirection ));
                float visTerm = SmithJointGGXVisibilityTerm( NdotL, NdotV, roughness );
                float normTerm = GGXTerm(NdotH, roughness);
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
                    surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;
                #else
                    surfaceReduction = 1.0/(roughness*roughness + 1.0);
                #endif
                specularPBL *= any(specularColor) ? 1.0 : 0.0;
                float3 directSpecular = attenColor*specularPBL*FresnelTerm(specularColor, LdotH);
                half grazingTerm = saturate( gloss + specularMonochrome );

				#if _ISMETALLIC_OFF
					float3 indirectSpecular = gi.indirect.specular;
				#else
					half2 skyUV = half2(ToRadialCoords(viewReflectDirection));
					float4 _Splat3_var = tex2D(_Splat3, skyUV);
					float3 indirectSpecular = _Splat3_var.rgb*_metallic;
				#endif
				
                indirectSpecular *= FresnelLerp (specularColor, grazingTerm, NdotV);
                indirectSpecular *= surfaceReduction;
                float3 specular = (directSpecular + indirectSpecular);
				
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                half fd90 = 0.5 + 2 * LdotH * LdotH * (1-gloss);
 
				
                float3 directDiffuse =  NdotL * attenColor;
				
                float3 indirectDiffuse = float3(0,0,0);

#if LIGHTMAP_ON
	#if SHADOWS_SHADOWMASK
				indirectDiffuse += lightmap.rgb;
	#endif
#else
				indirectDiffuse = i.sh.rgb;
#endif
				
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
				
/// Final Color:
                float3 finalColor = diffuse + specular;
				 
				/////// Diffuse:
                fixed4 finalRGBA = fixed4(finalColor,1);
				UBPA_APPLY_FOG(i, finalRGBA);
			 
                return finalRGBA;
            }
            ENDCG
        }
         
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
