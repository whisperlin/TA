Shader "BNN/Scene/RealLightTree" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_CutAlpha("Cut Alpha", Range(0, 1)) = 0.2
		_Frequency("Frequency", float) = 1
		_Wind("Wind", Vector) = (0, 0, 0.1, 0)
	}
	SubShader {
		Tags { "RenderType" = "Opaque" "Queue" = "AlphaTest+1" }
		LOD 200
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert vertex:vert alphatest:_CutAlpha addshadow fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		fixed4 _Color;
		//float _CutAlpha;
		float _Frequency;
		float4 _Wind;
		
		void vert(inout appdata_full v)
		{
			float wave_offset = v.color.r;
			float wave_weight = v.color.g;
			v.vertex.xyz += _Wind.xyz * cos(_Time.y * _Frequency + wave_offset * 3.14159) * wave_weight;
		}

		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
