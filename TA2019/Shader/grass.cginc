#if GRASS_SHADOW || GRASS_SHADOW2
#include "grassshadowmap.cginc"
#endif
#include "FogCommon.cginc"
#include "UnityCG.cginc"
#if GLOBAL_SH9
#include "SHGlobal.cginc"
#endif

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
 
				float2 uv2 : TEXCOORD1;
 
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

#if defined(GRASS_SHADOW) ||  defined(GRASS_SHADOW2)
				float4 shadowCoord : TEXCOORD10;
#endif
			};
			sampler2D grass_kkSceneColor;
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
#if _NEW_SHAKE
			uniform float _MaxWindStrength;
			uniform float _WindStrength;
			uniform sampler2D _WindVectors;
			uniform float _WindAmplitudeMultiplier;
			uniform float _WindAmplitude;
			uniform float _WindSpeed;
			uniform float4 _WindDirection;
			uniform float _WindSwinging;


			uniform float _UseSpeedTreeWind;
			uniform float _TrunkWindSpeed;
			uniform float _TrunkWindSwinging;
			uniform float _TrunkWindWeight;
			uniform float _FlatLighting;
			uniform float4 _ObstaclePosition;
			uniform float _BendingStrength;
			uniform float _BendingRadius;
			uniform float _BendingInfluence;
			uniform float4 _TerrainUV;
			uniform sampler2D _PigmentMap;
			uniform float _PigmentMapInfluence;
			uniform float _MinHeight;
			uniform float _MaxHeight;
			uniform float _HeightmapInfluence;
			uniform float ShakeSpeed;
			uniform float ShakeCtrl;
			/*void vertexDataFunc(inout appdata v, float3 ase_worldPos)
			{
				
				float WindStrength522 = _WindStrength;
				float3 windDirV3d = (float3(_WindDirection.x,0, _WindDirection.z));
				windDirV3d = mul(unity_WorldToObject, windDirV3d);
				
				float2 windDirV3 = (float2(windDirV3d.x, windDirV3d.z));
				
				float3 WindVector91 = UnpackNormal(tex2Dlod(_WindVectors, float4(((((ase_worldPos).xz * 0.01) * _WindAmplitudeMultiplier * _WindAmplitude) + (((_WindSpeed * 0.05) * _Time.w) * windDirV3)), 0, 0.0)));

				float3 break277 = WindVector91;
				float3 appendResult495 = (float3(break277.x, 0.0, break277.y));
				float3 temp_cast_0 = (-1.0).xxx;
				float3 lerpResult249 = lerp((float3(0, 0, 0) + (appendResult495 - temp_cast_0) * (float3(1, 1, 0) - float3(0, 0, 0)) / (float3(1, 1, 0) - temp_cast_0)), appendResult495, _WindSwinging);
				float3 Wind84 = lerp(((_MaxWindStrength * WindStrength522) * lerpResult249), float3(0, 0, 0), (1.0 - v.color.r));
				v.vertex.xyz += float3(Wind84.x, 0, Wind84.z);
				//v.normal = float3(0, 1, 0);
			}*/
			//这一坨是插件的。
			void vertexDataFunc(inout appdata v )
			{

				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex);
				float WindStrength522 = _WindStrength;
				
				float2 appendResult469 = (float2(_WindDirection.x, _WindDirection.z));
				float3 WindVector91 = UnpackNormal(tex2Dlod(_WindVectors, float4(((((ase_worldPos).xz * 0.01) * _WindAmplitudeMultiplier * _WindAmplitude) + (((_WindSpeed * 0.05) * _Time.w) * appendResult469)), 0, 0.0)));
				float3 break277 = WindVector91;
				float3 appendResult495 = (float3(break277.x, 0.0, break277.y));
				float3 temp_cast_0 = (-1.0).xxx;
				float3 lerpResult249 = lerp((float3(0, 0, 0) + (appendResult495 - temp_cast_0) * (float3(1, 1, 0) - float3(0, 0, 0)) / (float3(1, 1, 0) - temp_cast_0)), appendResult495, _WindSwinging);
				float3 lerpResult74 = lerp(((_MaxWindStrength * WindStrength522) * lerpResult249), float3(0, 0, 0), (1.0 - v.color.g));
				float3 Wind84 = lerpResult74;

				float3 temp_output_571_0 = (_ObstaclePosition).xyz;
				float3 normalizeResult184 = normalize((temp_output_571_0 - ase_worldPos));
				float temp_output_186_0 = (_BendingStrength * 0.1);
				float3 appendResult468 = (float3(temp_output_186_0, 0.0, temp_output_186_0));
				float clampResult192 = clamp((distance(temp_output_571_0, ase_worldPos) / _BendingRadius), 0.0, 1.0);
				float3 Bending201 = (v.color.g * -(((normalizeResult184 * appendResult468) * (1.0 - clampResult192)) * _BendingInfluence));
				float3 temp_output_203_0 = (Wind84 + Bending201);
				float2 appendResult483 = (float2(_TerrainUV.z, _TerrainUV.w));
				float2 TerrainUV324 = (((1.0 - appendResult483) / _TerrainUV.x) + ((_TerrainUV.x / (_TerrainUV.x * _TerrainUV.x)) * (ase_worldPos).xz));
				float4 PigmentMapTex320 = tex2Dlod(_PigmentMap, float4(TerrainUV324, 0, 1.0));
				float temp_output_467_0 = (PigmentMapTex320).a;
				float Heightmap518 = temp_output_467_0;
				float PigmentMapInfluence528 = _PigmentMapInfluence;
				float3 lerpResult508 = lerp(temp_output_203_0, (temp_output_203_0 * Heightmap518), PigmentMapInfluence528);
				float3 break437 = lerpResult508;
				float3 ase_vertex3Pos = v.vertex.xyz;
//#ifdef _VS_TOUCHBEND_ON
//				float staticSwitch659 = (TouchReactAdjustVertex(float4(ase_vertex3Pos, 0.0).xyz)).y;
//#else
//				float staticSwitch659 = 0.0;
//#endif
				float staticSwitch659 = 0.0;
				float TouchBendPos613 = staticSwitch659;
				float temp_output_499_0 = (1.0 - v.color.r);
				float lerpResult344 = lerp((saturate(((1.0 - temp_output_467_0) - TouchBendPos613)) * _MinHeight), 0.0, temp_output_499_0);
				float lerpResult388 = lerp(_MaxHeight, 0.0, temp_output_499_0);
				float GrassLength365 = ((lerpResult344 * _HeightmapInfluence) + lerpResult388);
				float3 appendResult391 = (float3(break437.x, GrassLength365, break437.z));
				float3 VertexOffset330 = appendResult391;
				v.vertex.xyz += VertexOffset330;
				
				//下面两句俺补上去的。
				float s = sin(_Time.y  + (ase_worldPos.x + ase_worldPos.z)*ShakeSpeed )  ;
	 			v.vertex.xz = v.vertex.xz + _WindDirection.zx*s * v.color.g *ShakeCtrl;
			}
			
			/*void vertexDataFunc(inout float4 vertex, inout float3 normal, float4 color, float2 uv, float2 uv2, float3 worldPos )
			{

				float speedOffset = ((_WindSpeed * 0.05) * _Time.w);
				float2 windDir2D = (float2(_WindDirection.x, _WindDirection.z));
				float3 windNoise = UnpackNormal(tex2Dlod(_WindVectors, float4(((_WindAmplitudeMultiplier * _WindAmplitude * ((worldPos).xz * 0.01)) + (speedOffset * windDir2D)), 0, 0.0)));
				float3 ase_objectScale = float3(length(unity_ObjectToWorld[0].xyz), length(unity_ObjectToWorld[1].xyz), length(unity_ObjectToWorld[2].xyz));
				float3 windDirV3 = (float3(_WindDirection.x, 0.0, _WindDirection.z));
				windDirV3 = mul(unity_WorldToObject, windDirV3);
				float3 _One = float3(1, 1, 1);
				float3 winOffset = (((float3(0, 0, 0) + (sin(((speedOffset * (_TrunkWindSpeed / ase_objectScale)) * windDirV3)) - (float3(-1, -1, -1) + _TrunkWindSwinging)) * (_One) / (_One - (float3(-1, -1, -1) + _TrunkWindSwinging))) * _TrunkWindWeight) * lerp(color.a, (uv.xy.y * 0.01), _UseSpeedTreeWind));
				float3 winOffsetH = (float3(winOffset.x, 0.0, winOffset.z));
				float3 Wind17 = (((windNoise * lerp(color.g, uv2.xy.x, _UseSpeedTreeWind)) * _MaxWindStrength * _WindStrength) + winOffsetH);
				vertex.xyz += Wind17;
				float3 ase_vertexNormal = normal.xyz;
				float3 _Vector0 = float3(0, 1, 0);
				float3 finalNormal = lerp(ase_vertexNormal, _Vector0, _FlatLighting);
				normal = finalNormal;
#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
				float3 ase_worldlightDir = 0;
#else //aseld
				float3 ase_worldlightDir = normalize(UnityWorldSpaceLightDir(worldPos));
#endif //aseld
				ase_worldlightDir = normalize(ase_worldlightDir);
				float3 ase_worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				float DotworldlightDir = dot(ase_worldlightDir, (1.0 - ase_worldViewDir));
#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
				float4 ase_lightColor = 0;
#else //aselc
				float4 ase_lightColor = _LightColor0;
#endif //aselc
				 


			}*/
#endif
			v2f vert (appdata v)
			{

				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);

				//_Wind
				
				float4 wpos = mul(unity_ObjectToWorld, v.vertex); 
				o.wpos = wpos;
#if _NEW_SHAKE  //关掉这个是原版草摆动.

				//vertexDataFunc(v.vertex, v.normal, v.color, v.uv, v.uv2, wpos);
				//vertexDataFunc(v, wpos);
				vertexDataFunc(v);
				 
				 
#endif
				o.vertex    = mul(unity_ObjectToWorld, v.vertex);
				
#if _FADEPHY_ON
					half4 normalDir0;
					 half s0;
					 //假物理.
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
							 len0 = len1;
						 }
						 if (_HitData2.w > 0 && len2 < len0)
						 {
							 _HitData0 = _HitData2;
							 len0 = len2;
						 }
						 if (_HitData3.w > 0 && len3 < len0)
						 {
							 _HitData0 = _HitData3;
							 len0 = len3;
						 }
						 if (_HitData4.w > 0 && len4 < len0)
						 {
							 _HitData0 = _HitData4;
							 len0 = len4;
						 }
					 }
					 else
					 {
						 s0 = 0;
						 normalDir0 = 0;
					 }
					 isHit(_HitData0,o.vertex,normalDir0,s0);
#if  !_NEW_SHAKE  //原版草摆动

					 float s = sin(_Time.y*_Speed + (o.vertex.x + o.vertex.z) *_Ctrl) * (1 - s0);
					 o.vertex.xyz = o.vertex.xyz + float3(_Wind.x, 0, _Wind.y)  * v.color.g * s;
#endif
					 
					 o.vertex.xz = o.vertex.xz + s0 *    v.color.g * _HitPower   * normalDir0.rb;
				#else
#if  !_NEW_SHAKE
				   //原版草摆动
					float s = sin(_Time.y*_Speed + (o.vertex.x+ o.vertex.z) *_Ctrl);
					o.vertex.xyz = o.vertex.xyz + float3(_Wind.x,0, _Wind.y)  * v.color.g * s ;
#endif
				#endif



				o.vertex = mul(UNITY_MATRIX_VP, o.vertex);
				o.uv = v.uv;
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				o.uv2 = v.uv2 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
				
#endif
				o.normalWorld = UnityObjectToWorldNormal(v.normal);
/*#if GLOBAL_SH9
				o.SH = g_sh(half4(o.normalWorld, 1));
#else
				o.SH = ShadeSH9(half4(o.normalWorld, 1));
#endif*/
				o.SH = ShadeSH9(half4(o.normalWorld, 1));
				
				o.color = v.color;
#if GRASS_SHADOW  || GRASS_SHADOW2
				o.shadowCoord = mul(grass_depthVPBias, mul(unity_ObjectToWorld, v.vertex));
				o.shadowCoord.z = -(mul(grass_depthV, mul(unity_ObjectToWorld, v.vertex)).z * grass_farplaneScale);
#endif
				
				UBPA_TRANSFER_FOG(o, v.vertex);
				return o;
			}