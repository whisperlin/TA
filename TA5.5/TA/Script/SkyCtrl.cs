using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class SectionData
{
    [Label("材质", 0.1f, 0.3f)]
    public Material mat;
 
    [Label("环境色")]
    public Color color = new Color32(249, 231, 223, 255);


    [Label("雾色")]
    public Color fogInscatteringColor = new Color32(227, 233, 255, 255); // Sets the inscattering color for the fog. Essentially, this is the fog's primary color.

    [Label("雾色远")]
    public Color farColor = Color.white;

    [Label("辉光透明度", 0f, 1f)]
    public float lensflareAlpha = 1f;



}

public class SkyCtrl : MonoBehaviour {

    [Label("天空盒对象")]
    public MeshRenderer mr;
 
    public SectionData []datas;
    [Label("进度",0f,1f)]
    public float t = 0;

    [Label("淡出透明", 0.1f, 0.3f)]
    public float fade = 0.2f;

    [Label("sh9对象")]
    public SetGlobalSH9 sh9Ctrl;
    [Space]
    [Label("指数高度雾")]
    public ExponentialHeightFogCtrl fog;
    [Space]
    [Label("辉光")]
    public LensFare lensflare;

    Material mat;
    
    // Use this for initialization
    void Start () {
        
	}
    int _SkyColorTop;
    int _SkyColorButtom;
    int _SkyCtrl;
    int _SkyButtomCtrl;
    int _SUN;
    int _SunColor;
    int _SunDir;
    int _Radius;
    int _SunPower;
    int _SUN_RAY;
    int _RadiusRay;
    int _SunRayColor;
    int _SunRayPower;
    int _CLOUND;
    int _ClondColor;
    int _CloundTex;
    int _CloundSpeed;
    int _CLOUND2;
    int _ClondColor2;
    int _CloundTex2;
    int _CloundSpeed2;
    int _SKY_FOG;
    int _SkyFogColor;
    int _SkyFogCtrl;
    int _BUTTOM;
    int _ButtomBrightness;



    float smoothstep(float a, float b, float t)
    {
        float t0 =  (t - a) / (b - a) ;
        t0 = Mathf.Min(1, t0);
        t0 = Mathf.Max(0, t0);
        return t0 * t0 * (3.0f - (2.0f * t0));
    }

    float smoothstep( float t)
    {
         
        t = Mathf.Min(1, t);
        t = Mathf.Max(0, t);
        return t * t * (3.0f - (2.0f * t));
    }


    private int index1;
    private int index2;
    private float t1;
    private float smoonthT;

    void GetNearMatIndex()
    {
        float len = 1f / datas.Length;
        index1 = (int)(t / len);
        index2 = index1 + 1;
        t1 = (t - index1 * len) / len;
        index1 = index1 % datas.Length;
        index2 = index2 % datas.Length;
        smoonthT = smoothstep(0f, 1f, t1);
    }

    void LerpColor(int _id )
    {
        mat.SetColor(_id, Color.Lerp(datas[index1].mat.GetColor(_id), datas[index2].mat.GetColor(_id), t1));
    }
    void LerpFloat(int _id )
    {
        mat.SetFloat(_id, Mathf.Lerp(datas[index1].mat.GetFloat(_id), datas[index2].mat.GetFloat(_id), t1));
    }
    void LerpVector(int _id)
    {
        mat.SetVector(_id, Vector4.Lerp(datas[index1].mat.GetVector(_id), datas[index2].mat.GetVector(_id), t1));
    }
    void FillFloat(int _id )
    {
        
        if (t1 < 0.5)
        {
            mat.SetFloat(_id, datas[index1].mat.GetFloat(_id));
        }
        else
        {
            mat.SetFloat(_id, datas[index2].mat.GetFloat(_id));
        }

    }
    void FillTexture(int _id)
    {
        //mat.SetTexture(_id, datas[index1].mat.GetTexture(_id));
        if (t1 < 0.5)
        {
            mat.SetTexture(_id, datas[index1].mat.GetTexture(_id));
        }
        else
        {
            mat.SetTexture(_id, datas[index2].mat.GetTexture(_id));
        }

    }
    void UpdateSky()
    {
        if (null == mr)
            mr = GetComponent<MeshRenderer>();
        if (null == mr)
            return;
        if (datas.Length < 2 )
            return;
        for (int i = 0; i < datas.Length; i++)
        {
            var _data = datas[i];
            if (_data.mat == null)
            {
                return;
            }
        }
        
        if (null == mat)
        {
            mat = new Material(datas[0].mat);
            _SkyColorTop = Shader.PropertyToID("_SkyColorTop");
            _SkyColorButtom = Shader.PropertyToID("_SkyColorButtom");
            _SkyCtrl = Shader.PropertyToID("_SkyCtrl");
            _SkyButtomCtrl = Shader.PropertyToID("_SkyButtomCtrl");
            _SUN = Shader.PropertyToID("_SUN");
            _SunColor =  Shader.PropertyToID("_SunColor");
            _SunDir = Shader.PropertyToID("_SunDir");
            _Radius = Shader.PropertyToID("_Radius");
            _SunPower =  Shader.PropertyToID("_SunPower");
            _SUN_RAY = Shader.PropertyToID("_SUN_RAY");
            _RadiusRay = Shader.PropertyToID("_RadiusRay");
            _SunRayColor = Shader.PropertyToID("_SunRayColor");
            _SunRayPower = Shader.PropertyToID("_SunRayPower");
            _CLOUND = Shader.PropertyToID("_CLOUND");
            _ClondColor = Shader.PropertyToID("_ClondColor");
            _CloundTex = Shader.PropertyToID("_CloundTex");
            _CloundSpeed = Shader.PropertyToID("_CloundSpeed");
            _CLOUND2 = Shader.PropertyToID("_CLOUND2");
            _ClondColor2 = Shader.PropertyToID("_ClondColor2");
            _CloundTex2 = Shader.PropertyToID("_CloundTex2");
            _CloundSpeed2 = Shader.PropertyToID("_CloundSpeed2");
            _SKY_FOG = Shader.PropertyToID("_SKY_FOG");
            _SkyFogColor = Shader.PropertyToID("_SkyFogColor");
            _SkyFogCtrl = Shader.PropertyToID("_SkyFogCtrl");
            _BUTTOM = Shader.PropertyToID("_BUTTOM");
            _ButtomBrightness = Shader.PropertyToID("_ButtomBrightness");
        }
        mr.material = mat;
        GetNearMatIndex();
        LerpColor(_SkyColorTop);
        LerpColor(_SkyColorButtom);
        LerpFloat(_SkyCtrl);
        LerpFloat(_SkyButtomCtrl);
        FillFloat(_SUN);
        LerpColor(_SunColor);
        LerpVector(_SunDir);
        LerpFloat(_Radius);
        LerpFloat(_SunPower);
        FillFloat(_SUN_RAY);
        LerpFloat(_RadiusRay);
        LerpColor(_SunRayColor);
        LerpFloat(_SunRayPower);
        FillFloat(_CLOUND);
        float _fade_max = 0.5f + fade;
        Color dataAlpha = new Color(1f, 1f, 1f, smoothstep( 0.5f, _fade_max, (1f - t1))); 
        Color nightAlpha = new Color(1f, 1f, 1f, smoothstep(0.5f, _fade_max,  t1 ));
        if (t1 < 0.5)
        {
            mat.SetColor(_ClondColor, dataAlpha);
        }
        else
        {
            mat.SetColor(_ClondColor, nightAlpha);
        }
        //_ClondColor2
        //mat.SetColor(_ClondColor, Color.Lerp(datas[index1].mat.GetColor(_ClondColor)* dataAlpha, datas[index2].mat.GetColor(_ClondColor), t)* nightAlpha);
        FillTexture(_CloundTex);
        LerpFloat(_CloundSpeed);
        FillFloat(_CLOUND2);

        if (t1 < 0.5)
        {
            mat.SetColor(_ClondColor2, dataAlpha);
        }
        else
        {
            mat.SetColor(_ClondColor2, nightAlpha);
        }
        //LerpColor();
        FillTexture(_CloundTex2);
        LerpFloat(_CloundSpeed2);
        FillFloat(_SKY_FOG);
        LerpColor(_SkyFogColor);
        LerpFloat(_SkyFogCtrl);
        FillFloat(_BUTTOM);
        LerpFloat(_ButtomBrightness);

        if (sh9Ctrl)
        {
            sh9Ctrl.GlobalTotalColor = Color.Lerp(datas[index1].color, datas[index2].color, smoonthT);
        }
        if (fog)
        {
            fog.fogInscatteringColor = Color.Lerp(datas[index1].fogInscatteringColor, datas[index2].fogInscatteringColor, smoonthT);
            fog.farColor = Color.Lerp(datas[index1].farColor, datas[index2].farColor, smoonthT);
        }
        if (null != lensflare)
        {
            if (t1 < 0.5)
            {
                lensflare._Alpha = datas[index1] .lensflareAlpha* ((1 - smoonthT) * 2f - 1f); 
            }
            else
            {
                lensflare._Alpha = datas[index2].lensflareAlpha * (smoonthT * 2f - 1f);
            }
        }
    }
    private void OnDisable()
    {
        if (null != mat)
        {
            GameObject.DestroyImmediate(mat, true);
            mat = null;
            mr.material = datas[0].mat;
        }
    }
 
    // Update is called once per frame
    void Update () {
        UpdateSky();

    }
}
