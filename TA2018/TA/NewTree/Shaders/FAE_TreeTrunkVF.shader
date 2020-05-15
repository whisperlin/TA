 Shader "TA/Scene/Tree(烘培)"
{
    Properties
    {
		_MainTex("MainTex", 2D) = "white" {}
		//_BumpMap("BumpMap", 2D) = "white" {}
		_GradientBrightness("GradientBrightness", Range(0 , 2)) = 1
		_AmbientOcclusion("Ambient Occlusion", Range(0 , 1)) = 0.5
		_AlphaCut("半透明剔除", Range(0 , 1)) = 0.1
			
		[Toggle(_ALPHA_CLIP)] _ALPHA_CLIP("开启半透明剔除", Float) = 1
		[Toggle]_UseSpeedTreeWind("UseSpeedTreeWind", Float) = 0

		_Smoothness("Smoothness", Range(0 , 1)) = 0
		[HideInInspector] _texcoord2("", 2D) = "white" {}
		[HideInInspector] _texcoord("", 2D) = "white" {}
		[HideInInspector] __dirty("", Int) = 1
		_TotalShakePower("叶子扭动强弱控制", Range(0 , 1)) = 1
		_MaxWindStrength("Max Wind Strength", Range(0 , 1)) = 0.126967
		_WindSwinging("WindSwinging", Range(0 , 1)) = 0.25
		_WindAmplitudeMultiplier("WindAmplitudeMultiplier", Float) = 1
		_HeightmapInfluence("HeightmapInfluence", Range(0 , 1)) = 0
		_MinHeight("MinHeight", Range(-1 , 0)) = -0.5
		_MaxHeight("MaxHeight", Range(-1 , 1)) = 0
		_BendingInfluence("BendingInfluence", Range(0 , 1)) = 0
		_PigmentMapInfluence("PigmentMapInfluence", Range(0 , 1)) = 0
		_PigmentMapHeight("PigmentMapHeight", Range(0 , 1)) = 0
		_BendingTint("BendingTint", Range(-0.1 , 0.1)) = -0.05
		[KeywordEnum(Off,On)] _fadePhy("是否开启碰撞交互", Float) = 0
		[Toggle(_GRAY_COLOR)] _GRAY_COLOR("主纹理灰度", Float) = 1
		[Toggle(_GRAY_SCENE)] _GRAY_SCENE("场景图只读阴影", Float) = 0
		_MaxWindStrength("最大风强度",Range(0,2)) = 0.5
		ShakeSpeed("摇动速度",Range(0,2)) = 1.5
		ShakeCtrl("摇动控制",Range(0,1)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"   }
        LOD 100

        Pass
        {
			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase"} //第一步//
			Cull Off
            CGPROGRAM
 
 
            #pragma vertex vert
            #pragma fragment frag
 

			#define _ISWEATHER_ON 1
			#pragma multi_compile __ SNOW_ENABLE
			#pragma   multi_compile  _ HARD_SNOW
			#pragma   multi_compile  _ MELT_SNOW
			#pragma multi_compile __ RAIN_ENABLE
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma   multi_compile  _  COMBINE_SHADOWMARK
			 

 
			#pragma   multi_compile  _ _ALPHA_CLIP
            #include "FAE_TreeTrunkVF.cginc"
            ENDCG
        }

		 

		 
    }
	 
}
