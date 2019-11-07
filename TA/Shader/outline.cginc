// Upgrade NOTE: replaced 'defined OUT_LINE_FROM_TEX' with 'defined (OUT_LINE_FROM_TEX)'

float _brightnessFactor;
float _saturationFactor;

sampler2D _OutlineWidthTexture;
half _EdgeThickness;
half _OutlineScaledMaxDistance;


 

 
inline float4 CalculateOutlineVertexClipPosition(float4 vertex ,float3 normal)
{
#if defined (OUT_LINE_FROM_TEX)
	float outlineTex = tex2Dlod(_OutlineWidthTexture, float4(TRANSFORM_TEX(texcoord, _MainTex), 0, 0)).r;
#else
	float outlineTex = 1;
#endif

#if defined(MTOON_OUTLINE_WIDTH_WORLD)
	float3 worldNormalLength = length(mul((float3x3)transpose(unity_WorldToObject), normal));
	float3 outlineOffset =    _EdgeThickness * outlineTex * worldNormalLength * normal;
	float4 out_vertex = UnityObjectToClipPos(vertex + outlineOffset);
#elif defined(MTOON_OUTLINE_WIDTH_SCREEN)
	float4 nearUpperRight = mul(unity_CameraInvProjection, float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y));
	float aspect = abs(nearUpperRight.y / nearUpperRight.x);
	float4 out_vertex = UnityObjectToClipPos(vertex);
	float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, normal.xyz);
	float3 clipNormal = TransformViewToProjection(viewNormal.xyz);
	float2 projectedNormal = normalize(clipNormal.xy);
	projectedNormal *= min(out_vertex.w, _OutlineScaledMaxDistance);
	projectedNormal.x *= aspect;
	out_vertex.xy +=   _EdgeThickness * outlineTex * projectedNormal.xy * saturate(1 - abs(normalize(viewNormal).z)); // ignore offset when normal toward camera
#else
	float4 out_vertex = UnityObjectToClipPos(vertex);
#endif
	return out_vertex;
}

inline void CalculateOutlineColor(inout float3 color)
{
	float3 newMapColor = color;
	float maxChan = max(max(newMapColor.r, newMapColor.g), newMapColor.b);
	float3 lerpVals = newMapColor / maxChan;
	float _powerFactor = 10;
	lerpVals = pow(lerpVals, _powerFactor);
	newMapColor.rgb = lerp(_saturationFactor * newMapColor.rgb, newMapColor.rgb, lerpVals);
	color.rgb = _brightnessFactor * newMapColor.rgb * color.rgb;
}