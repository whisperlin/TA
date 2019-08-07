// Shader created with Shader Forge v1.35 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.35;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:False,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0,fgcb:0,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True;n:type:ShaderForge.SFN_Final,id:4795,x:32866,y:32619,varname:node_4795,prsc:2|emission-9535-OUT,custl-4316-OUT,alpha-3277-OUT;n:type:ShaderForge.SFN_Tex2d,id:8411,x:31775,y:32669,ptovrint:False,ptlb:Texture,ptin:_Texture,varname:node_8411,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:9e914398d9a47f6488d6df6e903284f4,ntxv:0,isnm:False|UVIN-56-OUT;n:type:ShaderForge.SFN_TexCoord,id:6321,x:31327,y:32458,varname:node_6321,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Add,id:56,x:31526,y:32458,varname:node_56,prsc:2|A-6321-UVOUT,B-4853-OUT;n:type:ShaderForge.SFN_Multiply,id:4853,x:31526,y:32615,varname:node_4853,prsc:2|A-851-T,B-2192-OUT;n:type:ShaderForge.SFN_Time,id:851,x:31327,y:32615,varname:node_851,prsc:2;n:type:ShaderForge.SFN_Append,id:2192,x:31526,y:32794,varname:node_2192,prsc:2|A-3786-OUT,B-4177-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3786,x:31327,y:32809,ptovrint:False,ptlb:T_U,ptin:_T_U,varname:node_9936,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.1;n:type:ShaderForge.SFN_ValueProperty,id:4177,x:31327,y:32891,ptovrint:False,ptlb:T_V,ptin:_T_V,varname:node_1745,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Tex2d,id:6301,x:31775,y:33060,ptovrint:False,ptlb:mask2,ptin:_mask2,varname:_node_8411_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:cd460ee4ac5c1e746b7a734cc7cc64dd,ntxv:0,isnm:False|UVIN-3174-OUT;n:type:ShaderForge.SFN_TexCoord,id:9525,x:31330,y:32985,varname:node_9525,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Add,id:3174,x:31529,y:32985,varname:node_3174,prsc:2|A-9525-UVOUT,B-4506-OUT;n:type:ShaderForge.SFN_Multiply,id:4506,x:31529,y:33142,varname:node_4506,prsc:2|A-6287-T,B-4308-OUT;n:type:ShaderForge.SFN_Time,id:6287,x:31330,y:33142,varname:node_6287,prsc:2;n:type:ShaderForge.SFN_Append,id:4308,x:31529,y:33321,varname:node_4308,prsc:2|A-6338-OUT,B-9711-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6338,x:31330,y:33336,ptovrint:False,ptlb:M_U,ptin:_M_U,varname:_U_speed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:9711,x:31330,y:33418,ptovrint:False,ptlb:M_V,ptin:_M_V,varname:_V_speed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:8733,x:32081,y:33008,varname:node_8733,prsc:2|A-6301-R,B-6725-R,C-3781-OUT;n:type:ShaderForge.SFN_Tex2d,id:6725,x:31775,y:33257,ptovrint:False,ptlb:mask,ptin:_mask,varname:node_6725,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Clamp01,id:9535,x:32278,y:32691,varname:node_9535,prsc:2|IN-8411-RGB;n:type:ShaderForge.SFN_ValueProperty,id:3781,x:31775,y:32975,ptovrint:False,ptlb:mask_power,ptin:_mask_power,varname:node_3781,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Clamp01,id:3277,x:32278,y:33008,varname:node_3277,prsc:2|IN-8733-OUT;n:type:ShaderForge.SFN_Lerp,id:8933,x:32278,y:32844,varname:node_8933,prsc:2|A-5128-RGB,B-8411-R,T-623-OUT;n:type:ShaderForge.SFN_Color,id:5128,x:32081,y:32691,ptovrint:False,ptlb:Yin_ying,ptin:_Yin_ying,varname:node_5128,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0,c2:0,c3:0,c4:1;n:type:ShaderForge.SFN_Slider,id:182,x:31696,y:32868,ptovrint:False,ptlb:qu_xiang,ptin:_qu_xiang,varname:node_182,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-0.1,cur:0.6941219,max:1;n:type:ShaderForge.SFN_Clamp01,id:4316,x:32475,y:32844,varname:node_4316,prsc:2|IN-8933-OUT;n:type:ShaderForge.SFN_Subtract,id:623,x:32081,y:32844,varname:node_623,prsc:2|A-8411-R,B-182-OUT;proporder:8411-3786-4177-6725-6338-9711-6301-3781-5128-182;pass:END;sub:END;*/

Shader "Shader Forge/Yun_sd" {
    Properties {
        _Texture ("Texture", 2D) = "white" {}
        _T_U ("T_U", Float ) = 0.1
        _T_V ("T_V", Float ) = 0
        _mask ("mask", 2D) = "white" {}
        _M_U ("M_U", Float ) = 0
        _M_V ("M_V", Float ) = 0
        _mask2 ("mask2", 2D) = "white" {}
        _mask_power ("mask_power", Float ) = 1
        _Yin_ying ("Yin_ying", Color) = (0,0,0,1)
        _qu_xiang ("qu_xiang", Range(-0.1, 1)) = 0.6941219
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
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
            uniform float _T_U;
            uniform float _T_V;
            uniform sampler2D _mask2; uniform float4 _mask2_ST;
            uniform float _M_U;
            uniform float _M_V;
            uniform sampler2D _mask; uniform float4 _mask_ST;
            uniform float _mask_power;
            uniform fixed4 _Yin_ying;
            uniform float _qu_xiang;
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
			float4 frag(VertexOutput i) : COLOR{
				////// Lighting:
				////// Emissive:
				float2 node_56 = (i.uv0 + (_Time.y*float2(_T_U, _T_V)));
				float4 _Texture_var = tex2D(_Texture, TRANSFORM_TEX(node_56, _Texture));

				float3 emissive = saturate(_Texture_var.rgb);
				float3 finalColor = emissive + saturate(lerp(_Yin_ying.rgb,float3(_Texture_var.r,_Texture_var.r,_Texture_var.r),(_Texture_var.r-_qu_xiang)));
				float2 node_3174 = (i.uv0+(_Time.y*float2(_M_U,_M_V)));
				float4 _mask2_var = tex2D(_mask2,TRANSFORM_TEX(node_3174, _mask2));
				float4 _mask_var = tex2D(_mask,TRANSFORM_TEX(i.uv0, _mask));
				return float4(finalColor, saturate((_mask2_var.r*_mask_var.r*_mask_power)));
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
