// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Hidden/PostFX/ShadowReceiver" {
 Properties {
 	_MainTex ("Base (RGB)", 2D) = "white" {}
 	_Color("Main Color", Color) = (1,1,1,1)
 }
 SubShader {
	  Tags { "RenderType"="Opaque" }
	  
	  Pass {
		  CGPROGRAM


		  #pragma vertex vert
		  #pragma fragment frag

		  #include "UnityCG.cginc"
		  #pragma multi_compile HARD_SHADOW  SOFT_SHADOW_4Samples   
		  uniform float4 _Color;
		 
		  uniform sampler2D _MainTex;

#include "shadowmap.cginc"
	
		  struct v2f {
			   float4 position : SV_POSITION;
			   float2 uv : TEXCOORD0;
			   float4 shadowCoord : TEXCOORD1;
		  };
		  
		  
		  v2f vert(appdata_base v )
		  {
			   v2f o;
			   o.position = mul(UNITY_MATRIX_MVP, v.vertex);
			   o.shadowCoord = mul(_depthVPBias, mul(unity_ObjectToWorld, v.vertex));
			   o.shadowCoord.z = -(mul(_depthV, mul(unity_ObjectToWorld, v.vertex)).z * _farplaneScale);
			   o.uv = v.texcoord;
			   return o;
		  }
	

		  

	  		
			
		 
		  
		   half4 fragPCF4Samples(v2f IN)
		  {
			   float sum = PCF4Samples(IN.shadowCoord);
		  	   return sum * tex2D(_MainTex, IN.uv) * _Color;
		  }
		  
	 
		  
		  half4 frag(v2f IN) : COLOR
		  {
#ifdef HARD_SHADOW
		  		float depth = DecodeFloatRGBA(tex2D(_kkShadowMap, IN.shadowCoord.xy));
		  		float shade =  max(step(IN.shadowCoord.z - _bias, depth), _strength);
		  	    return shade * tex2D(_MainTex, IN.uv) * _Color;
#endif

 

#ifdef SOFT_SHADOW_4Samples
			return fragPCF4Samples(IN);
#endif

 
		  }
	  ENDCG
	  }
 }
 
}