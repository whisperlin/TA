// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,billboard:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:True,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:4013,x:33396,y:32932,varname:node_4013,prsc:2|diff-476-OUT,diffpow-1108-OUT,spec-9170-RGB,gloss-580-OUT,normal-2853-RGB,emission-3863-OUT,clip-8263-A;n:type:ShaderForge.SFN_Color,id:1304,x:32231,y:32676,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_1304,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Tex2d,id:8263,x:32231,y:32463,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_8263,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:476,x:32474,y:32480,varname:node_476,prsc:2|A-8263-RGB,B-1304-RGB;n:type:ShaderForge.SFN_Color,id:9170,x:32470,y:32776,ptovrint:False,ptlb:SpecularColor,ptin:_SpecularColor,varname:node_9170,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Slider,id:580,x:32253,y:32982,ptovrint:False,ptlb:_Gloss,ptin:_Gloss,varname:node_580,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.5128205,max:1;n:type:ShaderForge.SFN_Slider,id:1108,x:32795,y:32488,ptovrint:False,ptlb:DiffusePower,ptin:_DiffusePower,varname:node_1108,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Tex2d,id:2853,x:33189,y:32506,ptovrint:False,ptlb:Bumpc,ptin:_Bumpc,varname:node_2853,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:False;n:type:ShaderForge.SFN_Color,id:6615,x:32269,y:33147,ptovrint:False,ptlb:Emission,ptin:_Emission,varname:node_6615,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0,c2:0,c3:0,c4:1;n:type:ShaderForge.SFN_Multiply,id:3863,x:32785,y:33057,varname:node_3863,prsc:2|A-8263-RGB,B-6615-RGB;proporder:1304-8263-9170-580-1108-2853-6615;pass:END;sub:END;*/

Shader "Shader Forge/PhoneFull" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _SpecularColor ("SpecularColor", Color) = (1,1,1,1)
        _Gloss ("_Gloss", Range(0, 1)) = 0.5128205
        _Bumpc ("Bumpc", 2D) = "bump" {}
        _Emission ("Emission", Color) = (0,0,0,1)
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Cull Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 
            #pragma target 2.0
            uniform float4 _LightColor0;
            uniform float4 _Color;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _SpecularColor;
            uniform float _Gloss;
 
            uniform sampler2D _Bumpc; uniform float4 _Bumpc_ST;
            uniform float4 _Emission;
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
                LIGHTING_COORDS(5,6)
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
			float3 BlinnPhone(float3 attenColor,float3 diffuseColor,float3 specularColor,float gloss, float3 viewDirection,float3 normalDirection ,float3 lightDirection, float3 indirectDiffuse)
			{
				float3 halfDirection = normalize(viewDirection + lightDirection);
				float specPow = exp2(gloss * 10.0 + 1.0);
				////// Specular:
				float NdotL = saturate(dot(normalDirection, lightDirection));
				float3 directSpecular = attenColor * pow(max(0, dot(halfDirection, normalDirection)), specPow)*specularColor;
				float3 specular = directSpecular;
				/////// Diffuse:
 
				float3 directDiffuse =  NdotL  * attenColor;
		
				float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
				////// Emissive:
				return diffuse + specular;
			}
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float4 _Bumpc_var = tex2D(_Bumpc,TRANSFORM_TEX(i.uv0, _Bumpc));
                float3 normalLocal = _Bumpc_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                clip(_MainTex_var.a - 0.5);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
 
				float3 diffuseColor = (_MainTex_var.rgb*_Color.rgb);
				float3 diffuseSP = BlinnPhone( attenColor, diffuseColor, _SpecularColor.rgb , _Gloss, viewDirection, normalDirection,  lightDirection, UNITY_LIGHTMODEL_AMBIENT.rgb);
////// Emissive:
                float3 emissive = (_MainTex_var.rgb*_Emission.rgb);
/// Final Color:
                float3 finalColor = diffuseSP + emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            Cull Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 
            #pragma target 2.0
            uniform float4 _LightColor0;
            uniform float4 _Color;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _SpecularColor;
            uniform float _Gloss;
 
            uniform sampler2D _Bumpc; uniform float4 _Bumpc_ST;
            uniform float4 _Emission;
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
                LIGHTING_COORDS(5,6)
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
			float3 BlinnPhone(float3 attenColor, float3 diffuseColor, float3 specularColor, float gloss, float3 viewDirection, float3 normalDirection, float3 lightDirection, float3 indirectDiffuse)
			{
				float3 halfDirection = normalize(viewDirection + lightDirection);
				float specPow = exp2(gloss * 10.0 + 1.0);
				////// Specular:
				float NdotL = saturate(dot(normalDirection, lightDirection));
				float3 directSpecular = attenColor * pow(max(0, dot(halfDirection, normalDirection)), specPow)*specularColor;
				float3 specular = directSpecular;
				/////// Diffuse:

				float3 directDiffuse = NdotL * attenColor;

				float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
				////// Emissive:
				return diffuse + specular;
			}
			float4 frag(VertexOutput i, float facing : VFACE) : COLOR{
				float isFrontFace = (facing >= 0 ? 1 : 0);
				float faceSign = (facing >= 0 ? 1 : -1);
				i.normalDir = normalize(i.normalDir);
				i.normalDir *= faceSign;
				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float4 _Bumpc_var = tex2D(_Bumpc,TRANSFORM_TEX(i.uv0, _Bumpc));
				float3 normalLocal = _Bumpc_var.rgb;
				float3 normalDirection = normalize(mul(normalLocal, tangentTransform)); // Perturbed normals
				float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
				clip(_MainTex_var.a - 0.5);
				float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
				float3 lightColor = _LightColor0.rgb;
				float3 halfDirection = normalize(viewDirection + lightDirection);
				////// Lighting:
				float attenuation = LIGHT_ATTENUATION(i);
				float3 attenColor = attenuation * _LightColor0.xyz;

				float3 diffuseColor = (_MainTex_var.rgb*_Color.rgb);
				float3 diffuseSP = BlinnPhone(attenColor, diffuseColor, _SpecularColor.rgb, _Gloss, viewDirection, normalDirection, lightDirection, 0);
				/// Final Color:
				float3 finalColor = diffuseSP;
				fixed4 finalRGBA = fixed4(finalColor * 1,0);
				UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
				return finalRGBA;
			}
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 
            #pragma target 2.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                clip(_MainTex_var.a - 0.5);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
