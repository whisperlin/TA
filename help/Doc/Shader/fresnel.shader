Shader "Shader Forge/fresnel"
{
    Properties
	{
        _fresnel_1 ("fresnel_1", Range(0, 1)) = 0.4686216
        _fresnel ("fresnel", Float ) = 20
        _node_11 ("node_11", Color) = (0.5,0.5,0.5,1)
        _mask ("mask", 2D) = "white" {}
        _alpha ("alpha", Range(0, 8)) = 1.372233
        _subtact ("subtact", Float ) = 0.35
        _node_1578 ("node_1578", Color) = (1,1,1,1)
        _light ("light", Float ) = 5
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader
	{
        Tags
		{
            "Queue"="Transparent+200"
            "RenderType"="Transparent"
        }
        Pass
		{
            Name "ForwardBase"
            Tags
			{
                "LightMode"="ForwardBase"
            }
            Blend One One
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #define UNITY_PASS_FORWARDBASE							// Our proj is force forward base.
            #include "UnityCG.cginc"
            // #pragma multi_compile_fwdbase_fullshadows				// Shadow is not allowed.
            // #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 	// Should compile for all the platforms
            // #pragma target 3.0										// Target 3.0 is not fully supported by OpenGL ES 2.0
			
			uniform float4 _node_11;
			uniform float4 _mask_ST;
			uniform float4 _node_1578;
            uniform float _fresnel_1;
            uniform float _fresnel;
            uniform float _alpha;
            uniform float _subtact;
            uniform float _light;
			
			uniform sampler2D _mask;
			
            struct VertexInput
			{
                fixed4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
			
            struct VertexOutput
			{
                fixed4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
                float2 uv0 : TEXCOORD0;
            };
			
            VertexOutput vert (VertexInput v)
			{
                VertexOutput o;
                o.uv0 = v.texcoord0;
                o.normalDir = mul(float4(v.normal,0), unity_WorldToObject).xyz;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                return o;
            }
			
            fixed4 frag(VertexOutput i) : COLOR
			{
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
/////// Normals:
                float3 normalDirection =  i.normalDir;
                float2 node_1619 = i.uv0;
                float node_470 = (tex2D(_mask,TRANSFORM_TEX(node_1619.rg, _mask)).rgb*_alpha).r;
                float node_476_if_leA = step(node_470,0.3);
                float node_476_if_leB = step(0.3,node_470);
                float node_472 = 0.0;
                float node_475 = 1.0;
                float node_476 = lerp((node_476_if_leA*node_472)+(node_476_if_leB*node_475),node_475,node_476_if_leA*node_476_if_leB);
                clip(node_476 - 0.5);
////// Lighting:
////// Emissive:
                float node_471_if_leA = step(node_470,_subtact);
                float node_471_if_leB = step(_subtact,node_470);
                float3 emissive = ((pow((_fresnel_1+(1.0-max(0,dot(normalDirection, viewDirection)))),_fresnel)*_node_11.rgb)+((_node_1578.rgb*(1.0*(node_476-lerp((node_471_if_leA*node_472)+(node_471_if_leB*node_475),node_475,node_471_if_leA*node_471_if_leB))))*_light));
                float3 finalColor = emissive;
/// Final Color:
                return fixed4(finalColor,0);
            }
			
            ENDCG
        }
    }
    FallBack "Diffuse"
    // CustomEditor "ShaderForgeMaterialInspector" // Can not be opened by this editor.
}
