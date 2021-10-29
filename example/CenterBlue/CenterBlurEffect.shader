Shader "Hidden/Lch/BlurEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Offset("_Offset",Range(0,0.1)) = 0.02
 
		_Center("_Center",vector) = (0.5,0.5,0,1)
 

		_R0 ("R0", Range(0,1)) = 0.097

		_R1 ("R1", Range(0,1)) =  0.383

 
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
 
 
			uniform float4 _MainTex_TexelSize;
			half _Offset;
			half _R0;
			half _R1;
			half4 _Center;
 
            fixed4 frag (v2f i) : SV_Target
            {

				half t =  abs( _MainTex_TexelSize.x*_MainTex_TexelSize.w);
				half2 offset0 = (1,t);

				half2 dir =  i.uv -  _Center.xy;
				half2 uv0 = dir;
				uv0.y *= t ;
				uv0+=_Center.xy;


				half2 uv1 =  abs( uv0 -_Center.xy );
				half r =  length(uv1) ;
	 
				half s = saturate(   (r-_R0)/(_R1 - _R0) );
 
			
		 
				_Offset*=s;
				 
 
                half4 col = tex2D(_MainTex, i.uv);

				dir = normalize(dir);
 
				
			 
				col += tex2D(_MainTex, i.uv + dir * _Offset  );
				half  _Offset1 = _Offset + _Offset;
				col += tex2D(_MainTex, i.uv + dir * _Offset1  );
				
				_Offset1 +=  _Offset;
				col += tex2D(_MainTex, i.uv + dir * _Offset1  );
				_Offset1 +=  _Offset;
				col += tex2D(_MainTex, i.uv + dir * _Offset1  );
				_Offset1 +=  _Offset;
				col += tex2D(_MainTex, i.uv + dir * _Offset1  );
				_Offset1 +=  _Offset;
				col += tex2D(_MainTex, i.uv + dir * _Offset1  );
				_Offset1 +=  _Offset;
				col += tex2D(_MainTex, i.uv + dir * _Offset1  );
				_Offset1 +=  _Offset;
				col += tex2D(_MainTex, i.uv + dir * _Offset1  );
				_Offset1 +=  _Offset;
				col += tex2D(_MainTex, i.uv + dir * _Offset1  );
				col  *= 0.1;
 
                return col;
 
            }
            ENDCG
        }
    }
}
