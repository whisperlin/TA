Shader "Hidden/FlowMapPerview"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

		_TargetTex ("_TargetTex", 2D) = "white" {}

		_FlowSpeed ("Flow Speed", Range(0,1)) = 0.04
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#pragma multi_compile  _   _GLOBAL_FLOW_MAP
			

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
			sampler2D _TargetTex;
			sampler2D GlobalFlowMapUVS;
			float4 GlobalFlowMapPaintParams;
			float4 GlobalFlowMapPaintParams2;
			float4 GlobalFlowMapPaintPos;

			float _FlowSpeed;
            fixed4 frag (v2f i) : SV_Target
            {
				GlobalFlowMapPaintPos.yw = float2(1,1)-GlobalFlowMapPaintPos.yw ;
             
				fixed4 col2 = tex2D(_TargetTex, i.uv);
				#if _GLOBAL_FLOW_MAP
				fixed4 col3 = tex2D(GlobalFlowMapUVS, i.uv);
 
				#endif 

				if(GlobalFlowMapPaintParams2.x>0)
				{
					#if _GLOBAL_FLOW_MAP
					col2 =  lerp(col2, float4(1,1,0,1), col3.r);
					#endif 
			 
					return  col2;
				}
				 

				float3 flowDir = col2* 2.0f - 1.0f;
                flowDir *= _FlowSpeed;

                float phase0 = frac(_Time.y* 0.5f + 0.5f);
                float phase1 = frac(_Time.y* 0.5f + 1.0f);

                half3 tex0 = tex2D(_MainTex,  i.uv + flowDir.xy * phase0);
                half3 tex1 = tex2D(_MainTex, i.uv + flowDir.xy * phase1);

                float flowLerp = abs((0.5f - phase0) / 0.5f);
                half3 finalColor = lerp(tex0, tex1, flowLerp);
				#if _GLOBAL_FLOW_MAP
				finalColor =  lerp(finalColor, float4(1,1,0,1), col3.r);
				#endif 
				
				half4 col = half4(finalColor.xyz,1);

				 
				float  _l = length(i.uv-GlobalFlowMapPaintPos.xy);
				_l =  saturate(   (GlobalFlowMapPaintParams.x - _l)/GlobalFlowMapPaintParams.x);
				if(_l>0)
				{
					float f = _l*_l;
					f = lerp(f,1,GlobalFlowMapPaintParams.z); 
					col = col+ float4(0,0,f,1);
				}
             
                return col;
            }
            ENDCG
        }
    }
}
