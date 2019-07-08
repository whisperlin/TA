 
#include "UnityCG.cginc"

// Mobile: use RGBM instead of float/half RGB
#define USE_RGBM defined(SHADER_API_MOBILE)

sampler2D _MainTex;
sampler2D _BaseTex;
float2 _MainTex_TexelSize;
float2 _BaseTex_TexelSize;
half4 _MainTex_ST;
half4 _BaseTex_ST;

float _PrefilterOffs;
half _Threshold;
half3 _Curve;
float _SampleScale;
half _Intensity;

// Brightness function
half Brightness(half3 c)
{
    return max(max(c.r, c.g), c.b);
}

// 3-tap median filter
half3 Median(half3 a, half3 b, half3 c)
{
    return a + b + c - min(min(a, b), c) - max(max(a, b), c);
}

// Clamp HDR value within a safe range
half3 SafeHDR(half3 c) { return min(c, 65000); }
half4 SafeHDR(half4 c) { return min(c, 65000); }

// RGBM encoding/decoding
half4 EncodeHDR(float3 rgb)
{
#if USE_RGBM
    rgb *= 1.0 / 8;
    float m = max(max(rgb.r, rgb.g), max(rgb.b, 1e-6));
    m = ceil(m * 255) / 255;
    return half4(rgb / m, m);
#else
    return half4(rgb, 0);
#endif
}

float3 DecodeHDR(half4 rgba)
{
#if USE_RGBM
    return rgba.rgb * rgba.a * 8;
#else
    return rgba.rgb;
#endif
}

// Downsample with a 4x4 box filter
half3 DownsampleFilter(float2 uv)
{
    float4 d = _MainTex_TexelSize.xyxy * float4(-1, -1, +1, +1);

    half3 s;
    s  = DecodeHDR(tex2D(_MainTex, uv + d.xy));
    s += DecodeHDR(tex2D(_MainTex, uv + d.zy));
    s += DecodeHDR(tex2D(_MainTex, uv + d.xw));
    s += DecodeHDR(tex2D(_MainTex, uv + d.zw));

    return s * (1.0 / 4);
}

 

half3 UpsampleFilter(float2 uv)
{
 
    // 4-tap bilinear upsampler
    float4 d = _MainTex_TexelSize.xyxy * float4(-1, -1, +1, +1) * (_SampleScale * 0.5);

    half3 s;
    s  = DecodeHDR(tex2D(_MainTex, uv + d.xy));
    s += DecodeHDR(tex2D(_MainTex, uv + d.zy));
    s += DecodeHDR(tex2D(_MainTex, uv + d.xw));
    s += DecodeHDR(tex2D(_MainTex, uv + d.zw));

    return s * (1.0 / 4);
 
}

//
// Vertex shader
//

v2f_img vert(appdata_img v)
{
    v2f_img o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = UnityStereoScreenSpaceUVAdjust(v.texcoord, _MainTex_ST);
    return o;
}

struct v2f_multitex
{
    float4 pos : SV_POSITION;
    float2 uvMain : TEXCOORD0;
    float2 uvBase : TEXCOORD1;
};

v2f_multitex vert_multitex(appdata_img v)
{
    v2f_multitex o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uvMain = UnityStereoScreenSpaceUVAdjust(v.texcoord, _MainTex_ST);
    o.uvBase = UnityStereoScreenSpaceUVAdjust(v.texcoord, _BaseTex_ST);
#if UNITY_UV_STARTS_AT_TOP
    if (_BaseTex_TexelSize.y < 0.0)
        o.uvBase.y = 1.0 - v.texcoord.y;
#endif
    return o;
}

//
// fragment shader
//

half4 frag_prefilter(v2f_img i) : SV_Target
{
    float2 uv = i.uv + _MainTex_TexelSize.xy * _PrefilterOffs;

 
    half4 s0 = SafeHDR(tex2D(_MainTex, uv));
    half3 m = s0.rgb;
 

#if UNITY_COLORSPACE_GAMMA
    m = GammaToLinearSpace(m);
#endif
    // Pixel brightness
    half br = Brightness(m);

    // Under-threshold part: quadratic curve
    half rq = clamp(br - _Curve.x, 0, _Curve.y);
    rq = _Curve.z * rq * rq;

    // Combine and apply the brightness response curve.
    m *= max(rq, br - _Threshold) / max(br, 1e-5);

    return EncodeHDR(m);
}

half4 frag_downsample1(v2f_img i) : SV_Target
{
 
    return EncodeHDR(DownsampleFilter(i.uv));
 
}

half4 frag_downsample2(v2f_img i) : SV_Target
{
    return EncodeHDR(DownsampleFilter(i.uv));
}

half4 frag_upsample(v2f_multitex i) : SV_Target
{
    half3 base = DecodeHDR(tex2D(_BaseTex, i.uvBase));
    half3 blur = UpsampleFilter(i.uvMain);
    return EncodeHDR(base + blur);
}

half4 frag_upsample_final(v2f_multitex i) : SV_Target
{
    half4 base = tex2D(_BaseTex, i.uvBase);
    half3 blur = UpsampleFilter(i.uvMain);
#if UNITY_COLORSPACE_GAMMA
    base.rgb = GammaToLinearSpace(base.rgb);
#endif
    half3 cout = base.rgb + blur * _Intensity;
#if UNITY_COLORSPACE_GAMMA
    cout = LinearToGammaSpace(cout);
#endif
    return half4(cout, base.a);
}


half4 frag_upsample_final_debug(v2f_multitex i) : SV_Target
{
    half4 base = 0;
    half3 blur = UpsampleFilter(i.uvMain);
#if UNITY_COLORSPACE_GAMMA
    base.rgb = GammaToLinearSpace(base.rgb);
#endif
    half3 cout = base.rgb + blur * _Intensity;
#if UNITY_COLORSPACE_GAMMA
    cout = LinearToGammaSpace(cout);
#endif
    return half4(cout, base.a);
}


