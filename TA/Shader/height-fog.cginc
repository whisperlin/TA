



 #if _HEIGHT_FOG_ON
 half heightFogHeight;
 half heightFogHeight2;
 fixed4 farSceneColor;
 #endif



#ifdef _HEIGHT_FOG_ON
	#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
    
	#define APPLY_HEIGHT_FOG(c,posWorld)\
	float fogCoord0 =   smoothstep(heightFogHeight,heightFogHeight2, posWorld.y/posWorld.w);\
	farSceneColor.rgb = lerp(c.rgb,farSceneColor.rgb,farSceneColor.a);\
	unity_FogColor.rgb = lerp(unity_FogColor.rgb,farSceneColor.rgb,fogCoord0  );
	
	#else

	#define APPLY_HEIGHT_FOG(c,posWorld)  
	
	#endif
#else
    #define APPLY_HEIGHT_FOG(c,posWorld)  
#endif


