
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				float2 uv2 : TEXCOORD1;
#else
				float3 normal : NORMAL;
#endif
				float4 color: COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				float2 uv2 : TEXCOORD1;
#else
				
#endif
				float3 normalWorld : TEXCOORD1;
				float4 color: TEXCOORD2;
				float4 wpos:TEXCOORD3;
				UNITY_FOG_COORDS_EX(4)
				float4 vertex : SV_POSITION;
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
				o.vertex = mul(unity_ObjectToWorld, v.vertex);
				float4 wpos = mul(unity_ObjectToWorld, v.vertex); 
				o.wpos = wpos;
				#if _FADEPHY_ON
					half4 normalDir0;
					 half s0;
					 isHit(_HitData0,o.vertex,normalDir0,s0);
					 float s = sin(_Time.y*_Speed + (o.vertex.x+ o.vertex.z) *_Ctrl) * (1-s0);
					 o.vertex.xyz = o.vertex.xyz + float3(_Wind.x,0, _Wind.y)  * v.color.g * s  ;
					 o.vertex.xz = o.vertex.xz + s0 *    v.color.g * 5
					  * normalDir0.rb;
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

				
				UNITY_TRANSFER_FOG_EX(o, o.vertex, o.wpos, o.normalWorld);
				return o;
			}