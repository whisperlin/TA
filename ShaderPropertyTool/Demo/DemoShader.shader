Shader "Unlit/DemoShader"
{
    Properties
    {
        [KeywordEnum(One, Two, Three)] _MyEnum("MyEnum", Float) = 0
		_Color0("[_MYENUM_ONE]第一种颜色",Color) = (1,0,0,1)
		_Color1("[_MYENUM_TWO]第二种颜色",Color) = (0,1,0,1)
		[HDR]_Color2("[_MYENUM_THREE]第三种颜色",Color) = (0,0,1,1)

		_Color100("
		[_MYENUM_TWO]多种条件并列分行写
		[_MYENUM_THREE]每种条件达成可以显示不同文字
		",Color) = (1,1,1,1)

		/*//也可以这么写
		_Color100("[!_MYENUM_ONE]我是测试用的",Color) = (0,0,1,1)
		*/
		 [Toggle(S_BOOL)] S_BOOL("反向", Int) = 0
		_Color21("[S_BOOL]不写等于多少就按宏开启",Color) = (0,0,1,1)
		_Float22("[!S_BOOL]宏开!支持",Range(0,100)) = 2
        [Toggle] _MyToggle1("变暗", int) = 0
		_Color31("[_MyToggle1 = 1]写等于多少就是按属性开启",Color) = (1,0,1,1)
		_Float32("[_MyToggle1 = 1 &!S_BOOL]混合条件开启哦",Range(0,100)) = 2

		//枚举要中文的.
		[LCHEnum(LCHblendlModel)] _bendModel("混合模式", Int) = 0
		//用于记录混合值。 
        [HideInInspector] _SrcBlend("Src Blend", Int) = 1
        [HideInInspector]  _DstBlend("Dst Blend", Int) = 0

		[Enum(Off, 0,  Back, 2)] _Cull("Cull Off", Float) = 2
		[Enum(Off, 0, On, 1)] _ZWrite ("ZWrite", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

		Blend [_SrcBlend] [_DstBlend]
		Cull [_Cull]
		
		ZWrite [_ZWrite]

        LOD 100
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile _  S_BOOL
			#pragma multi_compile _MYENUM_ONE _MYENUM_TWO _MYENUM_THREE
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
 
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }
			half4 _Color0;
			half4 _Color1;
			half4 _Color2;
			int _MyToggle1;
            fixed4 frag (v2f i) : SV_Target
            {
 
				#if _MYENUM_ONE
				half4 col = _Color0;
				#elif _MYENUM_TWO
				half4 col = _Color1;
				#else 
				half4 col = _Color2;
				#endif
 
				#if S_BOOL
				 col = 1-col;
				#endif
				if(_MyToggle1==1)
				{
					col = col*0.5;
				}
                return col;
            }
            ENDCG
        }
    }
	CustomEditor "LCHShaderGUIBase"
}
