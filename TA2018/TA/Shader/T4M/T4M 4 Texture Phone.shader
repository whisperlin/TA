// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,billboard:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:4013,x:34027,y:33133,varname:node_4013,prsc:2|diff-9600-OUT,spec-4202-OUT,gloss-6874-OUT,normal-9362-OUT;n:type:ShaderForge.SFN_Tex2d,id:4459,x:32411,y:32375,ptovrint:False,ptlb:Splat0,ptin:_Splat0,varname:node_4459,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:215,x:32411,y:32554,ptovrint:False,ptlb:Splat1,ptin:_Splat1,varname:node_215,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:4380,x:32411,y:32739,ptovrint:False,ptlb:Splat2,ptin:_Splat2,varname:node_4380,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:9114,x:32411,y:32918,ptovrint:False,ptlb:Splat3,ptin:_Splat3,varname:node_9114,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:8560,x:32411,y:32198,ptovrint:False,ptlb:Control,ptin:_Control,varname:node_8560,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:6906,x:32745,y:32290,varname:node_6906,prsc:2|A-4459-RGB,B-8560-R;n:type:ShaderForge.SFN_Multiply,id:3669,x:32745,y:32485,varname:node_3669,prsc:2|A-215-RGB,B-8560-G;n:type:ShaderForge.SFN_Multiply,id:9801,x:32754,y:32648,varname:node_9801,prsc:2|A-4380-RGB,B-8560-B;n:type:ShaderForge.SFN_Multiply,id:5132,x:32754,y:32802,varname:node_5132,prsc:2|A-9114-RGB,B-8560-A;n:type:ShaderForge.SFN_Add,id:1947,x:33003,y:32284,varname:node_1947,prsc:2|A-6906-OUT,B-3669-OUT;n:type:ShaderForge.SFN_Add,id:4607,x:33029,y:32431,varname:node_4607,prsc:2|A-1947-OUT,B-9801-OUT;n:type:ShaderForge.SFN_Add,id:9600,x:33003,y:32590,varname:node_9600,prsc:2|A-4607-OUT,B-5132-OUT;n:type:ShaderForge.SFN_Tex2d,id:403,x:32411,y:33130,ptovrint:False,ptlb:BumpSplat0,ptin:_BumpSplat0,varname:node_403,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Tex2d,id:7073,x:32411,y:33317,ptovrint:False,ptlb:BumpSplat1,ptin:_BumpSplat1,varname:node_7073,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Tex2d,id:3464,x:32411,y:33504,ptovrint:False,ptlb:BumpSplat2,ptin:_BumpSplat2,varname:node_3464,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Tex2d,id:9173,x:32411,y:33690,ptovrint:False,ptlb:BumpSplat3,ptin:_BumpSplat3,varname:node_9173,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Multiply,id:8513,x:32766,y:33157,varname:node_8513,prsc:2|A-403-RGB,B-8560-R;n:type:ShaderForge.SFN_Multiply,id:6446,x:32766,y:33329,varname:node_6446,prsc:2|A-7073-RGB,B-8560-G;n:type:ShaderForge.SFN_Multiply,id:4617,x:32766,y:33512,varname:node_4617,prsc:2|A-3464-RGB,B-8560-B;n:type:ShaderForge.SFN_Multiply,id:5975,x:32766,y:33704,varname:node_5975,prsc:2|A-9173-RGB,B-8560-A;n:type:ShaderForge.SFN_Add,id:6150,x:33067,y:33153,varname:node_6150,prsc:2|A-8513-OUT,B-6446-OUT;n:type:ShaderForge.SFN_Add,id:4331,x:33047,y:33319,varname:node_4331,prsc:2|A-6150-OUT,B-4617-OUT;n:type:ShaderForge.SFN_Add,id:9362,x:33093,y:33499,varname:node_9362,prsc:2|A-4331-OUT,B-5975-OUT;n:type:ShaderForge.SFN_Multiply,id:8785,x:33683,y:32075,varname:node_8785,prsc:2|A-4459-A,B-8560-R;n:type:ShaderForge.SFN_Multiply,id:7601,x:33683,y:32203,varname:node_7601,prsc:2|A-215-A,B-8560-G;n:type:ShaderForge.SFN_Multiply,id:3331,x:33695,y:32348,varname:node_3331,prsc:2|A-4380-A,B-8560-B;n:type:ShaderForge.SFN_Multiply,id:830,x:33684,y:32509,varname:node_830,prsc:2|A-9114-A,B-8560-A;n:type:ShaderForge.SFN_Slider,id:9476,x:33091,y:31840,ptovrint:False,ptlb:Gloss,ptin:_Gloss,varname:node_9476,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Slider,id:2075,x:34544,y:32246,ptovrint:False,ptlb:ShininessL0,ptin:_ShininessL0,varname:node_2075,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Slider,id:9089,x:34549,y:32410,ptovrint:False,ptlb:ShininessL1,ptin:_ShininessL1,varname:node_9089,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Slider,id:5622,x:34530,y:32547,ptovrint:False,ptlb:ShininessL2,ptin:_ShininessL2,varname:node_5622,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Slider,id:175,x:34530,y:32709,ptovrint:False,ptlb:ShininessL3,ptin:_ShininessL3,varname:node_175,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Multiply,id:5483,x:34983,y:32217,varname:node_5483,prsc:2|A-2075-OUT,B-8560-R;n:type:ShaderForge.SFN_Multiply,id:5182,x:34983,y:32364,varname:node_5182,prsc:2|A-9089-OUT,B-8560-G;n:type:ShaderForge.SFN_Multiply,id:9795,x:34983,y:32520,varname:node_9795,prsc:2|A-5622-OUT,B-8560-B;n:type:ShaderForge.SFN_Multiply,id:5463,x:34976,y:32671,varname:node_5463,prsc:2|A-175-OUT,B-8560-A;n:type:ShaderForge.SFN_Add,id:2770,x:35422,y:32326,varname:node_2770,prsc:2|A-5483-OUT,B-5182-OUT;n:type:ShaderForge.SFN_Add,id:472,x:35388,y:32498,varname:node_472,prsc:2|A-2770-OUT,B-9795-OUT;n:type:ShaderForge.SFN_Add,id:4202,x:35386,y:32756,varname:_shininess,prsc:2|A-472-OUT,B-5463-OUT;n:type:ShaderForge.SFN_Add,id:905,x:34231,y:31868,varname:node_905,prsc:2|A-8785-OUT,B-7601-OUT;n:type:ShaderForge.SFN_Add,id:969,x:34111,y:32114,varname:node_969,prsc:2|A-905-OUT,B-3331-OUT;n:type:ShaderForge.SFN_Add,id:1008,x:34124,y:32345,varname:node_1008,prsc:2|A-969-OUT,B-830-OUT;n:type:ShaderForge.SFN_Multiply,id:6874,x:34071,y:32677,varname:node_6874,prsc:2|A-1008-OUT,B-9476-OUT;proporder:4459-215-4380-9114-9476-403-7073-3464-9173-2075-9089-5622-175-8560;pass:END;sub:END;*/

Shader "TA/T4M/T4M 4 Texture Phone" {
    Properties {
		_SpecColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Splat0 ("Splat0", 2D) = "white" {}
        _Splat1 ("Splat1", 2D) = "white" {}
        _Splat2 ("Splat2", 2D) = "white" {}
        _Splat3 ("Splat3", 2D) = "white" {}
        _Gloss ("Gloss", Range(0, 1)) = 1
        _BumpSplat0 ("BumpSplat0", 2D) = "bump" {}
        _BumpSplat1 ("BumpSplat1", 2D) = "bump" {}
        _BumpSplat2 ("BumpSplat2", 2D) = "bump" {}
        _BumpSplat3 ("BumpSplat3", 2D) = "bump" {}
        _ShininessL0 ("ShininessL0", Range(0, 1)) = 1
        _ShininessL1 ("ShininessL1", Range(0, 1)) = 1
        _ShininessL2 ("ShininessL2", Range(0, 1)) = 1
        _ShininessL3 ("ShininessL3", Range(0, 1)) = 1
        _Control ("Control", 2D) = "white" {}
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
            #define UNITY_PASS_FORWARDBASE
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma   multi_compile  _  LIGHT_MAP_CTRL
			#pragma   multi_compile  _  COMBINE_SHADOWMARK
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
			#include "../shadowmarkex.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _Splat0; uniform float4 _Splat0_ST;
            uniform sampler2D _Splat1; uniform float4 _Splat1_ST;
            uniform sampler2D _Splat2; uniform float4 _Splat2_ST;
            uniform sampler2D _Splat3; uniform float4 _Splat3_ST;
            uniform sampler2D _Control; uniform float4 _Control_ST;
            uniform sampler2D _BumpSplat0; uniform float4 _BumpSplat0_ST;
            uniform sampler2D _BumpSplat1; uniform float4 _BumpSplat1_ST;
            uniform sampler2D _BumpSplat2; uniform float4 _BumpSplat2_ST;
            uniform sampler2D _BumpSplat3; uniform float4 _BumpSplat3_ST;
            uniform float _Gloss;
            uniform float _ShininessL0;
            uniform float _ShininessL1;
            uniform float _ShininessL2;
            uniform float _ShininessL3;
			float4 _SpecColor;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
				
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				float2 uv1 : TEXCOORD5;
#else
				UNITY_LIGHTING_COORDS(5, 6)
#endif
                UNITY_FOG_COORDS(7)
				half3 Ambient : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
#if COMBINE_SHADOWMARK
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
#endif
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = UnityObjectToWorldDir(v.tangent.xyz);
                half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                o.bitangentDir = cross(o.normalDir, o.tangentDir) * tangentSign;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );


				half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				 
				

                UNITY_TRANSFER_FOG(o,o.pos);
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				o.uv1 = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
				o.Ambient = ShadeSH9(half4(worldNormal, 1));
				TRANSFER_VERTEX_TO_FRAGMENT(o);
#endif
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {

				#if COMBINE_SHADOWMARK
					UNITY_SETUP_INSTANCE_ID(i);
				#endif


#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
			GETLIGHTMAP(i.uv1);
			lightmap.rgb *= LightMapInf.rgb *(1 + LightMapInf.a);
			#if  SHADOWS_SHADOWMASK 

				 //return float4(lightmap,1);
			#else
				 
				return lightmap;;

			#endif

#endif
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                
                float4 _Control_var = tex2D(_Control,TRANSFORM_TEX(i.uv0, _Control));


				float4 bump0 = tex2D(_BumpSplat0, TRANSFORM_TEX(i.uv0, _Splat0));
				float4 bump1 = tex2D(_BumpSplat1, TRANSFORM_TEX(i.uv0, _Splat1));
				float4 bump2 = tex2D(_BumpSplat2, TRANSFORM_TEX(i.uv0, _Splat2));
				float4 bump3 = tex2D(_BumpSplat3, TRANSFORM_TEX(i.uv0, _Splat3));

				
				float3 _BumpSplat0_var = UnpackNormal(bump0);
                float3 _BumpSplat1_var = UnpackNormal(bump1);
                float3 _BumpSplat2_var = UnpackNormal(bump2);
                float3 _BumpSplat3_var = UnpackNormal(bump3);
                float3 normalLocal = ((((_BumpSplat0_var.rgb*_Control_var.r)+(_BumpSplat1_var.rgb*_Control_var.g))+(_BumpSplat2_var.rgb*_Control_var.b))+(_BumpSplat3_var.rgb*_Control_var.a));
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
			
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				  
#else
				float attenuation = LIGHT_ATTENUATION(i);
#endif

               
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                float4 _Splat0_var = tex2D(_Splat0,TRANSFORM_TEX(i.uv0, _Splat0));
                float4 _Splat1_var = tex2D(_Splat1,TRANSFORM_TEX(i.uv0, _Splat1));
                float4 _Splat2_var = tex2D(_Splat2,TRANSFORM_TEX(i.uv0, _Splat2));
                float4 _Splat3_var = tex2D(_Splat3,TRANSFORM_TEX(i.uv0, _Splat3));
                float gloss = (((((_Splat0_var.a*_Control_var.r)+(_Splat1_var.a*_Control_var.g))+(_Splat2_var.a*_Control_var.b))+(_Splat3_var.a*_Control_var.a))*_Gloss);
                //float specPow = exp2( gloss * 10.0 + 1.0 );
////// Specular:
                float NdotL = saturate(dot( normalDirection, lightDirection ));
                float _shininess = ((((_ShininessL0*_Control_var.r*bump0.a)+(_ShininessL1*_Control_var.g*bump0.a))+(_ShininessL2*_Control_var.b*bump0.a))+(_ShininessL3*_Control_var.a*bump0.a));
                float3 specularColor = float3(_shininess,_shininess,_shininess);
				float nh = max(0, dot(normalDirection, halfDirection));
				float directSpecular = pow(nh, specularColor*256) * gloss;

                float3 specular = lightColor * directSpecular *_SpecColor;
				
				//return float4(bump2.bbbb);
/////// Diffuse:
   
                float3 directDiffuse = saturate(    NdotL) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
			 
                indirectDiffuse += i.Ambient; // Ambient Light
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
#if SHADOWS_SHADOWMASK
				 
				indirectDiffuse += lightmap.rgb   ;
#endif
#endif
                float3 diffuseColor = ((((_Splat0_var.rgb*_Control_var.r)+(_Splat1_var.rgb*_Control_var.g))+(_Splat2_var.rgb*_Control_var.b))+(_Splat3_var.rgb*_Control_var.a));
                float3 diffuse = (directDiffuse +indirectDiffuse ) * diffuseColor;
/// Final Color:
				//float3 finalColor = diffuse;
                float3 finalColor = diffuse + specular;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        /*Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
           
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _Splat0; uniform float4 _Splat0_ST;
            uniform sampler2D _Splat1; uniform float4 _Splat1_ST;
            uniform sampler2D _Splat2; uniform float4 _Splat2_ST;
            uniform sampler2D _Splat3; uniform float4 _Splat3_ST;
            uniform sampler2D _Control; uniform float4 _Control_ST;
            uniform sampler2D _BumpSplat0; uniform float4 _BumpSplat0_ST;
            uniform sampler2D _BumpSplat1; uniform float4 _BumpSplat1_ST;
            uniform sampler2D _BumpSplat2; uniform float4 _BumpSplat2_ST;
            uniform sampler2D _BumpSplat3; uniform float4 _BumpSplat3_ST;
            uniform float _Gloss;
            uniform float _ShininessL0;
            uniform float _ShininessL1;
            uniform float _ShininessL2;
            uniform float _ShininessL3;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                UNITY_LIGHTING_COORDS(5,6)
                UNITY_FOG_COORDS(7)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = UnityObjectToWorldDir(v.tangent.xyz);
                half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                o.bitangentDir = cross(o.normalDir, o.tangentDir) * tangentSign;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                 
                float4 _Control_var = tex2D(_Control,TRANSFORM_TEX(i.uv0, _Control));

				float4 bump0 = tex2D(_BumpSplat0, TRANSFORM_TEX(i.uv0, _Splat0));
				float4 bump1 = tex2D(_BumpSplat1, TRANSFORM_TEX(i.uv0, _Splat1));
				float4 bump2 = tex2D(_BumpSplat2, TRANSFORM_TEX(i.uv0, _Splat2));
				float4 bump3 = tex2D(_BumpSplat3, TRANSFORM_TEX(i.uv0, _Splat3));


				float3 _BumpSplat0_var = UnpackNormal(bump0);
				float3 _BumpSplat1_var = UnpackNormal(bump1);
				float3 _BumpSplat2_var = UnpackNormal(bump2);
				float3 _BumpSplat3_var = UnpackNormal(bump3);
                
                float3 normalLocal = ((((_BumpSplat0_var.rgb*_Control_var.r)+(_BumpSplat1_var.rgb*_Control_var.g))+(_BumpSplat2_var.rgb*_Control_var.b))+(_BumpSplat3_var.rgb*_Control_var.a));
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                float4 _Splat0_var = tex2D(_Splat0,TRANSFORM_TEX(i.uv0, _Splat0));
                float4 _Splat1_var = tex2D(_Splat1,TRANSFORM_TEX(i.uv0, _Splat1));
                float4 _Splat2_var = tex2D(_Splat2,TRANSFORM_TEX(i.uv0, _Splat2));
                float4 _Splat3_var = tex2D(_Splat3,TRANSFORM_TEX(i.uv0, _Splat3));
                float gloss = (((((_Splat0_var.a*_Control_var.r)+(_Splat1_var.a*_Control_var.g))+(_Splat2_var.a*_Control_var.b))+(_Splat3_var.a*_Control_var.a))*_Gloss);
                float specPow = exp2( gloss * 10.0 + 1.0 );
////// Specular:
				float NdotL = saturate(dot(normalDirection, lightDirection));
				float _shininess = ((((_ShininessL0*_Control_var.r*bump0.a) + (_ShininessL1*_Control_var.g*bump0.a)) + (_ShininessL2*_Control_var.b*bump0.a)) + (_ShininessL3*_Control_var.a*bump0.a));
				float3 specularColor = float3(_shininess, _shininess, _shininess);
				float nh = max(0, dot(normalDirection, halfDirection));
				float directSpecular = pow(nh, specularColor * 256) * gloss;

				float3 specular = lightColor * directSpecular;
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float3 diffuseColor = ((((_Splat0_var.rgb*_Control_var.r)+(_Splat1_var.rgb*_Control_var.g))+(_Splat2_var.rgb*_Control_var.b))+(_Splat3_var.rgb*_Control_var.a));
                float3 diffuse = directDiffuse * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse + specular;
                fixed4 finalRGBA = fixed4(finalColor * 1,0);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }*/
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
