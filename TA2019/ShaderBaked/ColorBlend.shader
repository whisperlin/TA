// Unlit shader. Simplest possible colored shader.
// - no lighting
// - no lightmap support
// - no texture

Shader "Editor/Color" {
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
	}

		SubShader{
			Tags {"Queue" = "Transparent+4000" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
			LOD 100

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			Pass {
				CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
					#pragma target 2.0
 

					#include "UnityCG.cginc"

					struct appdata_t {
						float4 vertex : POSITION;
						UNITY_VERTEX_INPUT_INSTANCE_ID
					};

					struct v2f {
						float4 vertex : SV_POSITION;
 
						UNITY_VERTEX_OUTPUT_STEREO
					};

					fixed4 _Color;

					v2f vert(appdata_t v)
					{
						v2f o;
						UNITY_SETUP_INSTANCE_ID(v);
						UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
						o.vertex = UnityObjectToClipPos(v.vertex);
 
						return o;
					}

					fixed4 frag(v2f i) : COLOR
					{
						fixed4 col = _Color;
					 
						return col;
					}
				ENDCG
			}
	}

}
