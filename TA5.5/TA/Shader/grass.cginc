#include "UnityCG.cginc"
#include "FogCommon.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				float2 uv2 : TEXCOORD1;
 
				
#endif
				float3 normal : NORMAL;
				float4 color: COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				float2 uv2 : TEXCOORD1;
#else
				
#endif
				float3 normalWorld : TEXCOORD5;
				float4 color: TEXCOORD2;
				float4 wpos:TEXCOORD3;
				UBPA_FOG_COORDS(4)
				float4 vertex : SV_POSITION;
				float3 SH : TEXCOOR6;
			};

			sampler2D _MainTex;
			sampler2D _EmissionTex;
			half _AlphaCut;
			half4 _Wind;
			half _Speed;
			half _Ctrl;
			half4 _Color;
			half _Emission;

			#if _FADEPHY_ON
			float4 _HitData0;
			float4 _HitData1;
			float4 _HitData2;
			float4 _HitData3;
			float4 _HitData4;
			float _HitPower;
			void isHit( float4 hitData,float4 worldPos,  out half4 normalDir ,out half result)
			{
				normalDir.xyz =  worldPos.xyz - hitData.xyz ;
				
				normalDir.w = length( normalDir.xz );
				normalDir.xz = normalDir.xz* (hitData.w-normalDir.w ) /hitData.w;

				
				result =  step(normalDir.w,hitData.w) *step(hitData.y,worldPos.y) ;
	 
				 
			}
			#endif
			v2f vert (appdata v)
			{

				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);

				//_Wind
				
				float4 wpos = mul(unity_ObjectToWorld, v.vertex); 
				o.wpos = wpos;

				o.vertex    = mul(unity_ObjectToWorld, v.vertex);
				#if _FADEPHY_ON
					half4 normalDir0;
					 half s0;
					 
					if (_HitData0.w > 0)
					{
						float len0 = length(wpos.xyz - _HitData0.xyz);
						float len1 = length(wpos.xyz - _HitData1.xyz);
						float len2 = length(wpos.xyz - _HitData2.xyz);
						float len3 = length(wpos.xyz - _HitData3.xyz);
						float len4 = length(wpos.xyz - _HitData4.xyz);


						//_HitData0 = _HitData1;
						if (_HitData1.w > 0 && len1 < len0)
						{
							_HitData0 = _HitData1;
						}
						if (_HitData2.w > 0 && len2 < len0)
						{
							_HitData0 = _HitData2;
						}
						if (_HitData3.w > 0 && len3 < len0)
						{
							_HitData0 = _HitData3;
						}
						if (_HitData4.w > 0 && len4 < len0)
						{
							_HitData0 = _HitData4;
						}

						isHit(_HitData0, o.vertex, normalDir0, s0);
					}
					else
					{
						normalDir0 = 0;
						s0 = 0;
					}
					
					 float s = sin(_Time.y*_Speed + (o.vertex.x+ o.vertex.z) *_Ctrl) * (1-s0);
					 o.vertex.xyz = o.vertex.xyz + float3(_Wind.x,0, _Wind.y)  * v.color.g * s  ;
					 o.vertex.xz = o.vertex.xz + s0 *    v.color.g * _HitPower   * normalDir0.rb;
				#else
					float s = sin(_Time.y*_Speed + (o.vertex.x+ o.vertex.z) *_Ctrl);
					o.vertex.xyz = o.vertex.xyz + float3(_Wind.x,0, _Wind.y)  * v.color.g * s ;
				#endif

				 

				o.vertex = mul(UNITY_MATRIX_VP, o.vertex);
				o.uv = v.uv;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
				
#endif
				o.normalWorld = UnityObjectToWorldNormal(v.normal);
				o.color = v.color;
				o.SH = ShadeSH9(float4(o.normalWorld,1));
				
				UBPA_TRANSFER_FOG(o, v.vertex);
				return o;
			}