Shader "Hidden/FlowMapFlowMapPaint"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

		_MainTex2 ("_MainTex2", 2D) = "white" {}
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
			sampler2D _MainTex2;
			
			float4 GlobalFlowMapPaintParams;
			float4 GlobalFlowMapPaintPos;
 
            fixed4 frag (v2f i) : SV_Target
            {
				float3 dir = float3(0,0,1)*0.5+0.5;
				return float4(dir,1);
			 
            }
            ENDCG
        }

		 Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
			float4 GlobalFlowMapPaintParams;
			float4 GlobalFlowMapPaintParams2;
			float4 GlobalFlowMapPaintPos;

            fixed4 frag (v2f i) : SV_Target
            {
 
				GlobalFlowMapPaintPos.yw = float2(1,1)-GlobalFlowMapPaintPos.yw ;
                fixed4 col = tex2D(_MainTex, i.uv);


				float3 dir = float3(GlobalFlowMapPaintPos.zw,  0.5 );

				
				/*dir = normalize(dir);
				dir = dir*0.5+0.5;
				 dir.b = 0.5;
				 return float4(dir,1);*/
				float  _l = length(i.uv-GlobalFlowMapPaintPos.xy);
				_l =  saturate(   (GlobalFlowMapPaintParams.x - _l)/GlobalFlowMapPaintParams.x);
				if(_l>0)
				{
					float f = _l*_l;
					f = lerp(f,1,GlobalFlowMapPaintParams.z); 
	 
					col.xyz = lerp(col.xyz, dir,GlobalFlowMapPaintParams.y*f);
					
				}
             
                return col;
            }
            ENDCG
        }
         
    }
}
