Shader "Hidden/Rays"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		 _Noise ("_Noise", 2D) = "white" {}
		_Center("_Center",vector)=(0.5,0.5,0.5,0.5)
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
            fixed4 frag (v2f i) : SV_Target
            {
				float2  dir = _Center.xy -i.uv;
				
				float y = dot( normalize( dir ), float2(0,1)   );
				float x = dot( normalize( dir ), float2(1,0)   );
				half2 uv = half2(x,y )*_Noise_ST.xy + _Noise_ST.zw*_Time.x;
 
				 fixed4 col0 = tex2D(_Noise, uv  );
		 
				return col0;
                fixed4 col = tex2D(_MainTex, i.uv);

				
                // just invert the colors
                //col.rgb = 1 - col.rgb;
                return col;
            }
            ENDCG
        }
    }
}
