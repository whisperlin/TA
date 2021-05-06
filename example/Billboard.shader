// Shader created with Shader Forge v1.38 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.7507569,fgcg:0.8665211,fgcb:0.9632353,fgca:1,fgde:0.2,fgrn:400,fgrf:2500,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:7859,x:32837,y:32793,varname:node_7859,prsc:2|diff-5601-RGB,alpha-5601-A;n:type:ShaderForge.SFN_Tex2d,id:5601,x:32143,y:32704,ptovrint:False,ptlb:Albedo,ptin:_Albedo,varname:node_5601,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,taginstsco:False,tex:ffeac9f8fefea2e46b1a971c2d1469eb,ntxv:0,isnm:False;proporder:5601;pass:END;sub:END;*/

Shader "Test/Billboard" {
    Properties {
        _Albedo ("Albedo", 2D) = "white" {}
        [KeywordEnum(YAXIS, ALL)] _ROT("MyEnum", Float) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 100
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
 		
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 
            #pragma multi_compile _ROT_YAXIS  _ROT_ALL
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _Albedo; uniform float4 _Albedo_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
 
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                UNITY_FOG_COORDS(3)
            };

            
			void BillboardY(inout float4 vertex,inout float3 normal )
			{
			   
				//Calculate new billboard vertex position and normal;
				float3 upCamVec = float3( 0, 1, 0 );
				float3 forwardCamVec = -normalize ( UNITY_MATRIX_V._m20_m21_m22 );
				float3 rightCamVec = normalize( UNITY_MATRIX_V._m00_m01_m02 );
				float4x4 rotationCamMatrix = float4x4( rightCamVec, 0, upCamVec, 0, forwardCamVec, 0, 0, 0, 0, 1 );
				normal = normalize( mul( float4( normal , 0 ), rotationCamMatrix ));
				vertex.x *= length( unity_ObjectToWorld._m00_m10_m20 );
				vertex.y *= length( unity_ObjectToWorld._m01_m11_m21 );
				vertex.z *= length( unity_ObjectToWorld._m02_m12_m22 );
				vertex = mul( vertex, rotationCamMatrix );
				vertex.xyz += unity_ObjectToWorld._m03_m13_m23;
				//Need to nullify rotation inserted by generated surface shader;
				vertex = mul( unity_WorldToObject, vertex );

			}
			void Billboard(inout float4 vertex,inout float3 normal )
			{
			   
				//Calculate new billboard vertex position and normal;
				float3 upCamVec = normalize ( UNITY_MATRIX_V._m10_m11_m12 );
				float3 forwardCamVec = -normalize ( UNITY_MATRIX_V._m20_m21_m22 );
				float3 rightCamVec = normalize( UNITY_MATRIX_V._m00_m01_m02 );
				float4x4 rotationCamMatrix = float4x4( rightCamVec, 0, upCamVec, 0, forwardCamVec, 0, 0, 0, 0, 1 );
				normal = normalize( mul( float4( normal , 0 ), rotationCamMatrix ));
				vertex.x *= length( unity_ObjectToWorld._m00_m10_m20 );
				vertex.y *= length( unity_ObjectToWorld._m01_m11_m21 );
				vertex.z *= length( unity_ObjectToWorld._m02_m12_m22 );
				vertex = mul( vertex, rotationCamMatrix );
				vertex.xyz += unity_ObjectToWorld._m03_m13_m23;
				//Need to nullify rotation inserted by generated surface shader;
				vertex = mul( unity_WorldToObject, vertex );
			}
			 
			 
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
              
			 	//BillboardY(v.vertex,v.normal);

			 	#if _ROT_YAXIS
            	BillboardY(v.vertex,v.normal);
            	#else
            	Billboard(v.vertex,v.normal);
            	#endif

			 	
			 	o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );

          

                UNITY_TRANSFER_FOG(o,o.pos);
 
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * _LightColor0.xyz;
/////// Diffuse:
                float NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
                float4 _Albedo_var = tex2D(_Albedo,TRANSFORM_TEX(i.uv0, _Albedo));
                float3 diffuseColor = _Albedo_var.rgb;
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse;
 
                fixed4 finalRGBA = fixed4(finalColor,_Albedo_var.a);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
