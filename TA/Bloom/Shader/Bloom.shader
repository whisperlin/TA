 
Shader "Hidden/Bloom"
{
    Properties
    {
        _MainTex("", 2D) = "" {}
        _BaseTex("", 2D) = "" {}
    }
    SubShader
    {
        // 0: Prefilter
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma multi_compile _ UNITY_COLORSPACE_GAMMA
            #include "Bloom.cginc"
            #pragma vertex vert
            #pragma fragment frag_prefilter
            #pragma target 3.0
            ENDCG
        }
        
        // 1: Second level downsampler
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #include "Bloom.cginc"
            #pragma vertex vert
            #pragma fragment frag_downsample2
 
            ENDCG
        }
        // 2: Upsampler
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #include "Bloom.cginc"
            #pragma vertex vert_multitex
            #pragma fragment frag_upsample
 
            ENDCG
        }
         
        // 3: Combiner
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma multi_compile _ UNITY_COLORSPACE_GAMMA
            #include "Bloom.cginc"
            #pragma vertex vert_multitex
            #pragma fragment frag_upsample_final
 
            ENDCG
        }
        // 8: High quality combiner
        Pass
        {
           ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma multi_compile _ UNITY_COLORSPACE_GAMMA
            #include "Bloom.cginc"
            #pragma vertex vert_multitex
            #pragma fragment frag_upsample_final_debug
 
            ENDCG
        }
    }
}
