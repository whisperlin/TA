
 Shader "Tessellation Cloud" {
    Properties {
        //[Toggle(WORLD_POS_CMP)] WORLD_POS_CMP ("WORLD_POS_CMP", int) = 0
        [NoScaleOffset]_3DTex ("Texture", 3D) = "white" {}
        _Color ("颜色Color", color) = (0.9,0.9,0.9,0)
        _SpeColor ("高光Spec color", color) = (0.2,0.2,0.2,0.5)
        //[Toggle]_AoModel("_AoModel",float) = 0
        _Scale("_Scale",Range(0.1,1)) = 1
        _BumpPower("法线强度_BumpPower",Range(0,5 )) = 2
        _Speed("流动速度(Speed)",Vector) = (0.1,0.0,0.1,0)
        //_AoPower("_AoPower",Range(0,1)) = 1
        _Gloss ("高光控制_Gloss", Range(0,1)) = 0.5
 

        _Tess ("曲面细分控制", Range(0.1,8)) = 4
        //_EdgeLength ("Edge length", Range(2,50)) = 15
        _Phong ("细分Phong强度", Range(0,1)) = 0.5
        _MinDist ("最小距离", Range(5,15)) = 5
        _FadeDist ("最大距离", Range(5,20)) = 10
         _Displacement ("起伏程度Displacement", Range(0, 1.0)) = 0.3


    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 300
            
            
 
	    Pass {
		    Name "FORWARD"
		    Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma multi_compile_instancing
            #pragma vertex tessvert
            #pragma fragment frag
            #pragma hull FlatTessControlPoint
            #pragma domain PhoneTriTessDomain
            //#pragma multi_compile_fwdbase//第二步//
            #define FORWARD_BASE_PASS
            #pragma multi_compile    _ DIRECTIONAL
            #pragma multi_compile    _ LIGHTPROBE_SH
            #pragma multi_compile    _ SHADOWS_SCREEN
 
            #pragma multi_compile   WORLD_POS_CMP
            #pragma multi_compile   _TYPE_DISSIDE
            //#pragma multi_compile   _TYPE_DISTANCE  _TYPE_EDGE _TYPE_INPUT  _TYPE_DISSIDE   

            #pragma multi_compile    _ WORLD_POS_CMP
            #pragma target 4.6
 
            #pragma multi_compile_fog
            #include "UnityCG.cginc"
     
            
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            //#define WORLD_POS_CMP
          
            fixed4 _SpeColor;
           // #include "Tessellation.cginc"

            half4 LightingSimpleSpecular (float3 Albedo ,float Alpha ,float3 Normal, half3 lightDir, half3 viewDir, half atten) {
                half3 h = normalize (lightDir + viewDir);
                half diff = max (0, dot ( Normal, lightDir));
                float nh = max (0, dot ( Normal, h));
                float spec = pow (nh, 48.0);
                half4 c;
                c.rgb = (Albedo * _LightColor0.rgb * diff + _SpeColor.rgb*_LightColor0.rgb * spec) * atten;
                c.a = Alpha;
     
                return c;
            }

            struct appdata {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct V2f {
              //float4 pos : INTERNALTESSPOS; 
              float4  pos      : SV_POSITION;
              //UNITY_POSITION(pos);
              float2 uv : TEXCOORD0; // _MainTex
              float4 tSpace0 : TEXCOORD1;
              float4 tSpace1 : TEXCOORD2;
              float4 tSpace2 : TEXCOORD3;
              fixed3 ambient : TEXCOORD4; // ambient/SH/vertexlights
              UNITY_FOG_COORDS(5)
              UNITY_SHADOW_COORDS(6)
              UNITY_VERTEX_INPUT_INSTANCE_ID
              UNITY_VERTEX_OUTPUT_STEREO
            };
       

            struct TessInterpAppdata {
              float4 vertex : INTERNALTESSPOS;
              float4 tangent : TANGENT;
              float3 normal : NORMAL;
              float2 texcoord : TEXCOORD0;
            };

            sampler3D _3DTex;
            float _Displacement;
            half _Phong;
            float _EdgeLength;
            float _Tess;
            float4 _NoiseCtrl;


 

            float _MinDist  ;
            float _FadeDist  ;
             

            TessInterpAppdata tessvert (appdata v) {
              TessInterpAppdata o;
              #ifdef WORLD_POS_CMP
              float3 worldNormal = UnityObjectToWorldNormal(v.normal);
              fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
               
               float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
              o.vertex = float4(worldPos.xyz,1);
              o.normal = worldNormal.xyz;
              o.tangent.xyz = worldTangent;
              o.tangent.w = v.tangent.w;
              #else
              o.vertex = v.vertex;
              o.normal = v.normal;
              o.tangent = v.tangent;
              #endif
              o.texcoord = v.texcoord;
              return o;
            }
            float UnityCalcDistanceTessFactorMod (float4 vertex, float minDist, float fadeDist, float tess)
            {
                #ifdef WORLD_POS_CMP
                    float3 worldPos = vertex.xyz;
                #else
                     float3 worldPos = mul(unity_ObjectToWorld,vertex).xyz;
                #endif
               
                float dist = distance (worldPos, _WorldSpaceCameraPos);
                float f = clamp(1.0 - (dist - minDist) / fadeDist, 0.01, 1.0) * tess;
                return f;
            }
            float UnityCalcDistanceSideTessFactorMod (float4 vertex,float3 normal, float minDist, float fadeDist, float tess)
            {
                #ifdef WORLD_POS_CMP
                    float3 worldPos = vertex.xyz;
                    float3 worldNormal = normal.xyz;
                #else
                     float3 worldPos = mul(unity_ObjectToWorld,vertex).xyz;
                     float3 worldNormal = UnityObjectToWorldNormal(normal);
                #endif
               
                float3 worldViewDir = UnityWorldSpaceViewDir(worldPos);
                float dist = length (worldViewDir);
                worldViewDir /= dist;
                float nDotV = 1.01- abs(dot(worldViewDir,normal) );
                float t = clamp(1.0 - (dist - minDist) / fadeDist, 0.01, 1.0);
                float f = t * nDotV* tess;
                return f;
            }
            float4 UnityCalcTriEdgeTessFactors (float3 triVertexFactors)
            {
                float4 tess;
                tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
                tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
                tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
                tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
                return tess;
            }
            float4 UnityDistanceBasedTess (float4 v0, float4 v1, float4 v2, float minDist, float fadeDist, float tess)
            {
                float3 f;
                f.x = UnityCalcDistanceTessFactorMod (v0,minDist,fadeDist,tess);
                f.y = UnityCalcDistanceTessFactorMod (v1,minDist,fadeDist,tess);
                f.z = UnityCalcDistanceTessFactorMod (v2,minDist,fadeDist,tess);

                return UnityCalcTriEdgeTessFactors (f);
            }
            float4 UnityDistanceSideTess (float4 v0, float4 v1, float4 v2, float3 normal0 ,float3 normal1,float3 normal2,float minDist, float fadeDist, float tess)
            {
                float3 f;
                f.x = UnityCalcDistanceSideTessFactorMod (v0,normal0,minDist,fadeDist,tess);
                f.y = UnityCalcDistanceSideTessFactorMod (v1,normal1,minDist,fadeDist,tess);
                f.z = UnityCalcDistanceSideTessFactorMod (v2,normal2,minDist,fadeDist,tess);

                return UnityCalcTriEdgeTessFactors (f);
            }
            

            float UnityCalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen)
            {
                // distance to edge center
                float dist = distance (0.5 * (wpos0+wpos1), _WorldSpaceCameraPos);
                // length of the edge
                float len = distance(wpos0, wpos1);
                // edgeLen is approximate desired size in pixels
                float f = max(len * _ScreenParams.y / (edgeLen * dist), 1.0);
                return f;
            }
            float4 UnityEdgeLengthBasedTess (float4 v0, float4 v1, float4 v2, float edgeLength)
            {
                #ifdef WORLD_POS_CMP
                float3 pos0 = mul(unity_ObjectToWorld,v0).xyz;
                float3 pos1 = mul(unity_ObjectToWorld,v1).xyz;
                float3 pos2 = mul(unity_ObjectToWorld,v2).xyz;
                #else
                float3 pos0 = v0.xyz;
                float3 pos1 = v1.xyz;
                float3 pos2 = v0.xyz;
                #endif
                float4 tess;
                tess.x = UnityCalcEdgeTessFactor (pos1, pos2, edgeLength);
                tess.y = UnityCalcEdgeTessFactor (pos2, pos0, edgeLength);
                tess.z = UnityCalcEdgeTessFactor (pos0, pos1, edgeLength);
                tess.w = (tess.x + tess.y + tess.z) / 3.0f;
                return tess;
            }
            float4 tessEdge (appdata v0, appdata v1, appdata v2)
            {
                #if _TYPE_DISTANCE

     
                return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, _MinDist, _FadeDist, _Tess);

                #elif _TYPE_DISSIDE
                return UnityDistanceSideTess(v0.vertex, v1.vertex, v2.vertex,v0.normal, v1.normal, v2.normal, _MinDist, _FadeDist, _Tess);

                #elif _TYPE_EDGE
                 return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
                #else
                return _Tess;
                #endif
               
            }
            UnityTessellationFactors PatchConstant (InputPatch<TessInterpAppdata,3> v) {
              UnityTessellationFactors o;
              float4 tf  = tessEdge(v[0], v[1], v[2]);

              o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
              return o;
            }

            [UNITY_domain("tri")]
            [UNITY_partitioning("fractional_odd")]
            [UNITY_outputtopology("triangle_cw")]
            [UNITY_patchconstantfunc("PatchConstant")]
            [UNITY_outputcontrolpoints(3)]
            TessInterpAppdata FlatTessControlPoint (InputPatch<TessInterpAppdata,3> v, uint id : SV_OutputControlPointID) {
              return v[id];
            }
        fixed4 _Color;
        half _Gloss;
        //float _AoModel;
        //float _AoPower;
        float _BumpPower;
        float _Scale;
        float4 _Speed;
        float3 GetNoiseUV(float3 worldPos)
        {
            return  worldPos*_Scale + _Speed.xyz*_Time.yyy;
        }
        V2f vert (appdata v) {
          UNITY_SETUP_INSTANCE_ID(v);
          V2f o;
          UNITY_INITIALIZE_OUTPUT(V2f,o);
          UNITY_TRANSFER_INSTANCE_ID(v,o);
          UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
          
          o.uv.xy = v.texcoord;
          #ifdef WORLD_POS_CMP
          float3 worldNormal = v.normal;
          fixed3 worldTangent = v.tangent.xyz;
          fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
          fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
          float3 worldPos = v.vertex.xyz;
          #else
          float3 worldNormal = UnityObjectToWorldNormal(v.normal);
          fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
          fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
          fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
          float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
          #endif
          float3 uv = GetNoiseUV(worldPos);
          float d = tex3Dlod(_3DTex,float4(uv,0));
          worldPos.xyz += worldNormal * d*_Displacement;
          o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
          o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
          o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
          float3 shlight = ShadeSH9 (float4(worldNormal,1.0));
          o.ambient = shlight;
          o.pos =  mul(UNITY_MATRIX_VP, float4(worldPos,1.0 ));
          UNITY_TRANSFER_LIGHTING(o,half2(0.0, 0.0)); // pass shadow and, possibly, light cookie coordinates to pixel shader
          UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
          return o;
        }


        [UNITY_domain("tri")]
        V2f PhoneTriTessDomain (UnityTessellationFactors tessFactors, const OutputPatch<TessInterpAppdata,3> vi, float3 bary : SV_DomainLocation) {
          appdata v;
          UNITY_INITIALIZE_OUTPUT(appdata,v);
          v.vertex = vi[0].vertex*bary.x + vi[1].vertex*bary.y + vi[2].vertex*bary.z;
          float3 pp[3];
          for (int i = 0; i < 3; ++i)
            pp[i] = v.vertex.xyz - vi[i].normal * (dot(v.vertex.xyz, vi[i].normal) - dot(vi[i].vertex.xyz, vi[i].normal));
          v.vertex.xyz = _Phong * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-_Phong) * v.vertex.xyz;
          v.tangent = vi[0].tangent*bary.x + vi[1].tangent*bary.y + vi[2].tangent*bary.z;
          v.normal = vi[0].normal*bary.x + vi[1].normal*bary.y + vi[2].normal*bary.z;
          v.texcoord = vi[0].texcoord*bary.x + vi[1].texcoord*bary.y + vi[2].texcoord*bary.z;
        
          V2f o = vert (v);
          return o;
        }

        fixed4 frag (V2f i) : SV_Target {
          UNITY_SETUP_INSTANCE_ID(i);
          UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
          float3 worldPos = float3(i.tSpace0.w, i.tSpace1.w, i.tSpace2.w);
          fixed3 lightDir = _WorldSpaceLightPos0.xyz;
          float3 worldNormal = float3(i.tSpace0.z, i.tSpace1.z, i.tSpace2.z);
          half3 samplePosition = GetNoiseUV(worldPos);
          float depth0 = tex3D(_3DTex, samplePosition.xyz  ).r;
          float AO = 1;
         
 
        /*if(_AoModel)
        {
            AO = depth0*_AoPower+(1.0-_AoPower);  
        }
        else*/
        {
            float3 worldBitanget = normalize(float3(i.tSpace0.y, i.tSpace1.y, i.tSpace2.y));
            float3 worldTangent = normalize(float3(i.tSpace0.x, i.tSpace1.x, i.tSpace2.x));
            float3 worldNormal0 = normalize( cross( ddy( worldPos ), ddx( worldPos ) ) );
            worldPos+= worldNormal * depth0.r*0.015625 ;  //0.015625 //0.0293  // 0.03125
            float3 worldNormal1 = normalize( cross( ddy( worldPos ), ddx( worldPos ) ) );
            float3 delta =  worldNormal1-worldNormal0  ;
            worldNormal = normalize(worldNormal +delta* _BumpPower);
        }


   
          
          half3 viewDir = _WorldSpaceCameraPos.xyz - worldPos.xyz;
          viewDir = normalize(viewDir);
          UNITY_LIGHT_ATTENUATION(atten, i, worldPos)
          atten*=AO;

          float nDotL = max( dot(worldNormal,lightDir),0 );
          float4 col = float4(_LightColor0.rgb *_Color* nDotL *AO,1.0);

          col.rgb += i.ambient * _Color;
          return col;
 
  
        }
 

        ENDCG

        }
 

        }
        FallBack "Diffuse"
    }
