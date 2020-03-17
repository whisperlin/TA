Shader "Unlit/FAE_Grass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_MaxWindStrength("Max Wind Strength", Range(0 , 1)) = 0.126967
		_WindSwinging("WindSwinging", Range(0 , 1)) = 0.25
		_WindAmplitudeMultiplier("WindAmplitudeMultiplier", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal: NORMAL;
				float4 color:COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			uniform float _MaxWindStrength;
			uniform float _WindStrength;
			uniform sampler2D _WindVectors;
			uniform float _WindAmplitudeMultiplier;
			uniform float _WindAmplitude;
			uniform float _WindSpeed;
			uniform float4 _WindDirection;
			uniform float _WindSwinging;
			uniform float4 _ObstaclePosition;
			uniform float _BendingStrength;
			uniform float _BendingRadius;
			uniform float _BendingInfluence;
			uniform sampler2D _PigmentMap;
 
		 


			void fadePhysics(inout appdata v, float3 ase_worldPos)
			{
				float3 _hitDir = normalize((_ObstaclePosition.xyz - ase_worldPos));
				float3 appendVertex = (float3(_BendingStrength, 0.0, _BendingStrength));
				float hitPower = clamp((distance(_ObstaclePosition.xyz, ase_worldPos) / _BendingRadius), 0.0, 1.0);
				float3 Bending201 = (v.color.r * -(((_hitDir * appendVertex) * (1.0 - hitPower))));
				v.vertex.xyz += float3(Bending201.x, 0, Bending201.z);
			}
			void vertexDataFunc(inout appdata v , float3 ase_worldPos)
			{
				float WindStrength522 = _WindStrength;
				float2 appendResult469 = (float2(_WindDirection.x, _WindDirection.z));
				float3 WindVector91 = UnpackNormal(tex2Dlod(_WindVectors, float4(((((ase_worldPos).xz * 0.01) * _WindAmplitudeMultiplier * _WindAmplitude) + (((_WindSpeed * 0.05) * _Time.w) * appendResult469)), 0, 0.0)));
				float3 break277 = WindVector91;
				float3 appendResult495 = (float3(break277.x, 0.0, break277.y));
				float3 temp_cast_0 = (-1.0).xxx;
				float3 lerpResult249 = lerp((float3(0, 0, 0) + (appendResult495 - temp_cast_0) * (float3(1, 1, 0) - float3(0, 0, 0)) / (float3(1, 1, 0) - temp_cast_0)), appendResult495, _WindSwinging);
				float3 Wind84 = lerp(((_MaxWindStrength * WindStrength522) * lerpResult249), float3(0, 0, 0), (1.0 - v.color.r));
				v.vertex.xyz += float3(Wind84.x, 0, Wind84.z);
				v.normal = float3(0, 1, 0);
			}

            v2f vert (appdata v)
            {
                v2f o;
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex);
				vertexDataFunc(v, ase_worldPos);
				fadePhysics(v, ase_worldPos);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
