// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Hidden/PhoneMeta" {
Properties {
    _Color ("Main Color", Color) = (1,1,1,1)
 
    _MainTex ("Base (RGB)", 2D) = "white" {}
   
}

SubShader {
    LOD 100
    Tags { "RenderType"="Opaque" }

  
    // Extracts information for lightmapping, GI (emission, albedo, ...)
    // This pass it not used during regular rendering.
    Pass
    {
        Name "META"
        Tags { "LightMode" = "Meta" }
        CGPROGRAM
        #pragma vertex vertMeta
        #pragma fragment fragMeta
        #pragma target 2.0
		#define _META_PASS 1
       #include "phone.cginc"
        ENDCG
    }
}

 
}

