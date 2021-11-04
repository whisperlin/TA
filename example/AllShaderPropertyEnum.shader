/*
public enum CustomEnum
{
	Enum1 = 0,
	Enum2 = 1,
	Enum3 = 2
}
*/
Shader "Mya/EnumTest"
{
    Properties
    {
	
        _MainTex ("Texture", 2D) = "white" {}
                                                   
        [Header(Custom)]
        [Enum(CustomEnum)]  _CustomEnum ("CustomEnum", Float) = 1

        [Header(Option)]
        [Enum(UnityEngine.Rendering.BlendOp)]  _BlendOp  ("BlendOp", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("SrcBlend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("DstBlend", Float) = 0
        [Enum(Off, 0, On, 1)]_ZWriteMode ("ZWriteMode", float) = 1
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode ("ZTestMode", Float) = 4
        [Enum(UnityEngine.Rendering.ColorWriteMask)]_ColorMask ("ColorMask", Float) = 15

        [Header(Stencil)]
        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp ("Stencil Comparison", Float) = 8
        [IntRange]_StencilWriteMask ("Stencil Write Mask", Range(0,255)) = 255
        [IntRange]_StencilReadMask ("Stencil Read Mask", Range(0,255)) = 255
        [IntRange]_Stencil ("Stencil ID", Range(0,255)) = 0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilPass ("Stencil Pass", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilFail ("Stencil Fail", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilZFail ("Stencil ZFail", Float) = 0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

		
        Pass
        {
            BlendOp [_BlendOp]
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWriteMode]
            ZTest [_ZTestMode]
            Cull [_CullMode]
            ColorMask [_ColorMask]

            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
