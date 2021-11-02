Shader "Lch/DepthGodRay" {
 
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_BlurTex("Blur", 2D) = "white"{}
		_SampleCount("_SampleCount", int) = 10
		_Color("_Color",Color) = (1,1,1,1)
		_OffsetLen ("_OffsetLen", Range(0,0.1)) = 0.05
		_LightColor("_LightColor",Color) = (1,1,1,1)
		_offsets("_offsets",Vector) = (1,1,1,1)
		
	}
 
	CGINCLUDE
	#define RADIAL_SAMPLE_COUNT 6
	#include "UnityCG.cginc"
	
	//用于阈值提取高亮部分
	struct v2f_threshold
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
 
	//用于blur
	struct v2f_blur
	{
		float4 pos : SV_POSITION;
		float2 uv  : TEXCOORD0;
		float2 blurOffset : TEXCOORD1;
	};
 
	//用于最终融合
	struct v2f_merge
	{
		float4 pos : SV_POSITION;
		float2 uv  : TEXCOORD0;
		float2 uv1 : TEXCOORD1;
	};
 
	sampler2D _CameraDepthTexture;
	sampler2D _MainTex;
	float4 _MainTex_TexelSize;
	sampler2D _BlurTex;
	float4 _BlurTex_TexelSize;
	float4 _ViewPortLightPos;
	
	float4 _offsets;
	float4 _ColorThreshold;
	float4 _LightColor;
 
	float _PowFactor;
	float _LightRadius;
	float _DepthThreshold;
	float _LightMaxRadius;
	int _SampleCount;
 
	//高亮部分提取shader
	v2f_threshold vert_threshold(appdata_img v)
	{
		v2f_threshold o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		
		//dx中纹理从左上角为初始坐标，需要反向
#if UNITY_UV_STARTS_AT_TOP
		if (_MainTex_TexelSize.y < 0)
			o.uv.y = 1 - o.uv.y;
#endif	
		return o;
	}
 
	fixed4 frag_threshold(v2f_threshold i) : SV_Target
	{
	#if NOISE_TEXTURE
		//采样深度贴图
		float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
		//转换回01区间
		depth = Linear01Depth (depth);
 
		return step(_DepthThreshold,depth);
	#else
		fixed4 color = tex2D(_MainTex, i.uv);
		float distFromLight = length(_ViewPortLightPos.xy - i.uv);
		float distanceControl = saturate(_LightRadius - distFromLight);
		//仅当color大于设置的阈值的时候才输出
		float4 thresholdColor = saturate(color - _ColorThreshold) * distanceControl;
		float luminanceColor = Luminance(thresholdColor.rgb);
		
		luminanceColor = pow(luminanceColor, _PowFactor);

		luminanceColor = smoothstep( 0, _LightMaxRadius, luminanceColor) *_LightMaxRadius;
		
		
		//采样深度贴图
		float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
		//转换回01区间
		depth = Linear01Depth (depth);
 
		luminanceColor *= step(_DepthThreshold,depth);
		return fixed4(luminanceColor, luminanceColor, luminanceColor, 1);
	#endif
		
	}
 
	 
 
 


	v2f_blur vert_blur(appdata_img v)
	{
		v2f_blur o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		float2  dir = _ViewPortLightPos.xy - v.texcoord.xy;
		o.blurOffset =  normalize (dir);
		return o;
	}
	half _OffsetLen;

	half _RayScale;
	
	fixed4 frag_blur(v2f_blur i) : SV_Target
	{

		float2  dir = _ViewPortLightPos.xy - i.uv.xy;
		
		half color = 0;
		for(int j = _SampleCount; j > 0;  j -- )   
		{	 
			half  c = tex2D(_MainTex, i.uv.xy).r;
			color += c    ;
			i.uv.xy =  saturate( i.uv.xy + dir*_OffsetLen); 	
		}
		color  =   saturate( color/ _SampleCount);

		color = color*color*color*color;
		 
		 
		return color ;
	}
 
	//融合vertex shader
	v2f_merge vert_merge(appdata_img v)
	{
		v2f_merge o;
		//mvp矩阵变换
		o.pos = UnityObjectToClipPos(v.vertex);
		//uv坐标传递
		o.uv.xy = v.texcoord.xy;
		o.uv1.xy = o.uv.xy;
#if UNITY_UV_STARTS_AT_TOP
		if (_MainTex_TexelSize.y < 0)
			o.uv.y = 1 - o.uv.y;
#endif	
		return o;
	}
 
	sampler2D _Noise;
	half4 _Noise_ST;
	half4 _Center;
	half _Range;
	half4 _Color;
	fixed4 frag_merge(v2f_merge i) : SV_Target
	{
		fixed4 ori = tex2D(_MainTex, i.uv1);
		fixed4 blur = tex2D(_BlurTex, i.uv);
		

		//输出= 原始图像，叠加体积光贴图
		fixed4 lightColor =    blur * _LightColor;
		#if NOISE_TEXTURE


		float2  dir = _ViewPortLightPos.xy - i.uv;
				
		float y = dot( normalize( dir ), float2(0,1)   );
		float x = dot( normalize( dir ), float2(1,0)   );
		half2 uv = half2(x,y )*_Noise_ST.xy + _Noise_ST.zw*_Time.x;
		half len = length(dir);
		
		fixed4 col = tex2D(_Noise, uv  );
	  
		col = lerp(_Color , col,  saturate( len  ))   ;
		float t =  1- saturate( len/_LightRadius);
		//_LightRadius
		//return lightColor *  col.r  ;
		lightColor *= col.r *  t*t;
		#endif
		
		return lightColor + ori;
	}
 
		ENDCG
 
	SubShader
	{
		//pass 0: 提取高亮部分
		Pass
		{
			ZTest Off
			Cull Off
			ZWrite Off
			Fog{ Mode Off }
 
			CGPROGRAM
			 #pragma multi_compile _  NOISE_TEXTURE
			#pragma vertex vert_threshold
			#pragma fragment frag_threshold
			ENDCG
		}
 
		//pass 1: 径向模糊
		Pass
		{
			ZTest Off
			Cull Off
			ZWrite Off
			Fog{ Mode Off }
 
			CGPROGRAM
			#pragma vertex vert_blur
			#pragma fragment frag_blur
			ENDCG
		}
 
		//pass 2: 将体积光模糊图与原图融合
		Pass
		{
 
			ZTest Off
			Cull Off
			ZWrite Off
			Fog{ Mode Off }
 
			CGPROGRAM
			 #pragma multi_compile _  NOISE_TEXTURE
			#pragma vertex vert_merge
			#pragma fragment frag_merge
			ENDCG
		}
