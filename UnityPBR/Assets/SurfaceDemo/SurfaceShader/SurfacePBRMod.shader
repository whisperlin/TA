// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SurfacePBR Mod"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_MainTex("MainTex", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_Metallic("Metallic", 2D) = "white" {}
		_SmoothnessPower("SmoothnessPower", Range( 0 , 1)) = 0.857734
		_MetallicPower("MetallicPower", Range( 0 , 1)) = 0
		_TestOffset("TestOffset", Vector) = (0,0,0,0)
		_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma only_renderers d3d9 d3d11 gles gles3 
		//novertexlights
		#pragma skip_variants  INSTANCING_ON 
		#pragma surface surf Standard keepalpha  fullforwardshadows  nodynlightmap nodirlightmap nofog noforwardadd// vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _Metallic;
		uniform float4 _Metallic_ST;
		uniform half4 _EmissionColor;
		uniform half _MetallicPower;
		uniform half _SmoothnessPower;
		uniform half3 _TestOffset;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += _TestOffset;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			half4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			o.Albedo = tex2DNode1.rgb;
			float2 uv_Metallic = i.uv_texcoord * _Metallic_ST.xy + _Metallic_ST.zw;
			half4 tex2DNode4 = tex2D( _Metallic, uv_Metallic );
			o.Emission = ( tex2DNode1 * tex2DNode4.g * _EmissionColor ).rgb;
			o.Metallic = ( tex2DNode4.r * _MetallicPower );
			o.Smoothness = ( tex2DNode4.a * _SmoothnessPower );
			o.Occlusion = tex2DNode4.b;
			o.Alpha = 1;
		}

		ENDCG
	}
 
}
/*ASEBEGIN
Version=13101
7;104;1860;929;2526.594;1478.805;2.250738;True;True
Node;AmplifyShaderEditor.RangedFloatNode;9;-569,367;Float;False;Property;_SmoothnessPower;SmoothnessPower;3;0;0.857734;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;1;-608.9175,-653.082;Float;True;Property;_MainTex;MainTex;0;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;12;-644.4232,-408.9626;Float;False;Property;_EmissionColor;EmissionColor;6;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;6;-608,-12;Float;False;Property;_MetallicPower;MetallicPower;4;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;4;-768.0999,-200.9;Float;True;Property;_Metallic;Metallic;2;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.Vector3Node;10;44.0377,283.2625;Float;False;Property;_TestOffset;TestOffset;5;0;0,0,0;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;100,-28;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;3;-632.3001,-894.6;Float;True;Property;_Normal;Normal;1;0;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-141,87;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;107,-172;Float;False;3;3;0;COLOR;0.0;False;1;FLOAT;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;529,-58;Half;False;True;2;Half;;0;0;Standard;SurfacePBR Mod;False;False;False;False;False;True;False;True;True;True;False;True;False;False;True;False;False;Back;0;0;False;0;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;False;True;True;False;False;False;False;False;False;False;False;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;4;1
WireConnection;7;1;6;0
WireConnection;8;0;4;4
WireConnection;8;1;9;0
WireConnection;5;0;1;0
WireConnection;5;1;4;2
WireConnection;5;2;12;0
WireConnection;0;0;1;0
WireConnection;0;1;3;0
WireConnection;0;2;5;0
WireConnection;0;3;7;0
WireConnection;0;4;8;0
WireConnection;0;5;4;3
WireConnection;0;11;10;0
ASEEND*/
//CHKSM=BB4CB6AC5DDCE42936E991B16285D2DB7F7D3CE9