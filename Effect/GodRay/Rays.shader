Shader "Hidden/Rays"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		 _Noise ("_Noise", 2D) = "white" {}
		_Center("_Center",vector)=(0.5,0.5,0.5,0.5)
		_Range("_Range",Range(0.01,1)) = 0.2
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
			sampler2D _Noise;
			half4 _Noise_ST;
			half4 _Center;
			half _Range;
            fixed4 frag (v2f i) : SV_Target
            {
				float2  dir = _Center.xy -i.uv;
				
				float y = dot( normalize( dir ), float2(0,1)   );
				float x = dot( normalize( dir ), float2(1,0)   );
				half2 uv = half2(x,y )*_Noise_ST.xy + _Noise_ST.zw*_Time.x;
				half len = length(dir);
		
				fixed4 col = tex2D(_Noise, uv  );
				col = lerp(half4(1,1,1,1) , col,  saturate( len/_Range ));
				return col;
               
            }
            ENDCG
        }
    }
}
