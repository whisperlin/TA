// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:0,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33257,y:32709,varname:node_3138,prsc:2|emission-2064-OUT;n:type:ShaderForge.SFN_Tex2d,id:8205,x:32876,y:33037,ptovrint:False,ptlb:node_8205,ptin:_node_8205,varname:_node_8205,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:db85d3d9c0ce09b49b95bd95dbdada6d,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:297,x:32787,y:32795,varname:node_297,prsc:2|A-7221-OUT,B-8205-R;n:type:ShaderForge.SFN_ValueProperty,id:7221,x:32704,y:32587,ptovrint:False,ptlb:QD,ptin:_QD,varname:_QD,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Tex2d,id:1981,x:32546,y:32905,ptovrint:False,ptlb:node_7130_copy,ptin:_node_7130_copy,varname:_node_7130_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:1a0c05b35abb13341bc42515bfa1832a,ntxv:0,isnm:False|UVIN-3447-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:7749,x:32182,y:32905,varname:node_7749,prsc:2,uv:0;n:type:ShaderForge.SFN_Panner,id:3447,x:32364,y:32905,varname:node_3447,prsc:2,spu:0.1,spv:-0.2|UVIN-7749-UVOUT;n:type:ShaderForge.SFN_Add,id:2064,x:33023,y:32835,varname:node_2064,prsc:2|A-297-OUT,B-1981-RGB;proporder:8205-7221-1981;pass:END;sub:END;*/

Shader "Shader Forge/yuan" {
    Properties {
        _node_8205 ("node_8205", 2D) = "white" {}
        _QD ("QD", Float ) = 1
        _node_7130_copy ("node_7130_copy", 2D) = "white" {}
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha One
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _node_8205; uniform float4 _node_8205_ST;
            uniform float _QD;
            uniform sampler2D _node_7130_copy; uniform float4 _node_7130_copy_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float4 _node_8205_var = tex2D(_node_8205,TRANSFORM_TEX(i.uv0, _node_8205));
                float4 node_116 = _Time + _TimeEditor;
                float2 node_3447 = (i.uv0+node_116.g*float2(0.1,-0.2));
                float4 _node_7130_copy_var = tex2D(_node_7130_copy,TRANSFORM_TEX(node_3447, _node_7130_copy));
                float3 emissive = ((_QD*_node_8205_var.r)+_node_7130_copy_var.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
