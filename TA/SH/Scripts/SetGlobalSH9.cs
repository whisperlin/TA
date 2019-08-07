using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SetGlobalSH9 : MonoBehaviour {

    public SH9Data data;
    SH9Data curData;

   

    [Header("角色虚拟光颜色")]
    public Color virtualDirectLightColor0 = Color.white;
    [Header("虚拟光强度")]
    [Range(0, 3)]
    public float virtualDirectLightColor0Intensity = 1.0f;

    [Header("角色虚拟光方向")]
    public Vector3 VirtualDirectLight0;

    [Header("场景漫反射差")]
    [Range(0f,1f)]
    public float _DifSC = 0.0f;

    [Header("场景背光")]
    public Color _BackColor = Color.black;

    [Header("场景背光强度")]
    [Range(0f,1f)]
    public float sss_scatter0 = 0.0f;

    [Header("启动unity原生雾")]
    public bool oldFog = true;

    [Space]
    [Space]
    [Space]
    [Header("距离雾开关")]
    public bool enable_dis = false;

    [Header("雾最远距离")]
    [Range(1f, 150f)]
    public float fog_end_in_view = 100f;
    
    [Header("雾距离强度调节")]
    [Range(0.01f, 1f)]
    public float fog_dis_density = 1f;
    [Range(0.01f,1f)]
    [Header("雾距离曲线调节（远近过渡）")]
    public float fog_b = 1f;

    [Header("雾颜色")]
    public Color FogColor2 = Color.white;

    [Header("雾透明")]
    [Range(0.001f, 1f)]
    public float fog_max2 = 1f;

    [Space]
    [Space]
    [Space]
    [Header("高度雾")]
     public bool heightFog = false;

    [Header("雾初始高度")]
    public float fog_begin_in_height = 0;
    [Range(1f, 100f)]
    [Header("雾高度")]
    public float fog_height = 40;
    [Range(1f, 5f)]
    [Header("雾高度曲线调节(底部浓度)")]
     public float fog_hight_b = 2f;

    [Header("高度雾最远距离")]
    public float height_fog_end_in_view = 50;

    [Header("高度衰减曲线调节")]
    [Range(0f,1f)]
    public float height_fog_height_a = 1f;
    [Header("雾高度强度调节")]
    [Range(0f,15f)]
     public float fog_height_density = 1f;
    
    
    [Header("雾颜色")]
     public Color FogColor = Color.white;

    [Header("雾透明")]
    [Range(0.001f, 1f)]
    public float fog_max = 1f;

    [Space]
    [Space]
    [Space]


    [Header("远景变色")]
    public bool enable_env = false;
    [Header("反射环境色")]
    public SH9Data farEvn;
    SH9Data curFarEnv;
    [Header("远景色")]
    public Color farSceneColor = new Color(1, 1, 1, 1);
    [Header("远近变色最远距离")]
    [Range(1f,150f)]
    public float env_end_in_view = 100f;   
    [Range(0.01f, 1f)]
    [Header("远近变色强度调节")]
    public float env_dis_density = 1f;
    [Range(0.01f, 1f)]
    [Header("远近变色曲线调节（远近过渡）")]
    public float env_b = 1f;

    [Header("雾透明")]
    [Range(0.001f, 1f)]
    public float fog_max1 = 1f;





    private float fog_acc_density_in_height = 150f;

    [Header("高光剔除")]
    [Range(-0.1f, 0.6f)]
    public float _CullSepe = 0.0f;

    
    [Header("高度雾地平线")]
    private float heightFogHeight = 0;

    [Header("高度雾顶部")]
    private float heightFogHeight2 = 10;
    [Range(0.1f,1f)]
    [Header("高度过渡")]
    private float fog_height_power = 0.4f;
    
    
    [Range(0f,0.9f)]
    [Header("反射环境色向下偏移")]
    private float globalEnvOffset = 0.5f;
    
    
    [Range(0.001f, 0.02f)]
    [Header("远景过渡")]
    private float density = 0.01f;

    [Range(0.001f, 0.02f)]
    [Header("高度过渡")]
    private float densityH = 0.01f;

    //[Range(0.001f, 0.02f)]

    [Range(1f, 10f)]
    [Header("雾色过渡")]
    private float color_density = 1f;

   

    [Space]
    [Space]
    [Space]



    [Header("远景背光变色")]
    public bool enable_back_light = false;
 
    [Header("远景背光强度调节")]
    [Range(0f,1)]
    public float back_dis_density = 1f;

    [Range(0.7f, 1)]
    [Header("雾背光强度调节")]
    public float fog_back_dis_density = 1f;

    [Range(0.7f, 1)]
    [Header("高度雾背光强度调节")]
    public float height_fog_back_dis_density = 1f;

    [Space]
    [Space]
    [Space]



    [Header("场景虚拟光颜色")]
    public Color virtualSceneDirectLightColor0 = Color.white;

    [Header("场景光方向(烘培后用于打高光背光等)")]
    public Vector3 VirtualSceneDirectLight0;
    [Header("场景光强度")]
    [Range(0, 3)]

    public float virtualSceneDirectLightColor0Intensity = 1.0f;



     
   

    // Use this for initialization
    void Start () {
        curData = null;
        curFarEnv = null;
        setSH9Global();
    }
	// Update is called once per frame
	void Update () {
        setSH9Global();
    }
    private void setSH9Global()
    {

        if (oldFog)
        {
            Shader.DisableKeyword("ENABLE_NEW_FOG");

        }
        else
        {
            Shader.EnableKeyword("ENABLE_NEW_FOG");
        }

        //Shader.SetGlobalFloat("fog_b", fog_b* fog_b* fog_b);
 

        Shader.SetGlobalVector("FogInfo", new Vector4(fog_b * fog_b * fog_b, fog_end_in_view, fog_height, fog_begin_in_height));
        Shader.SetGlobalColor("FogColor", new Color(FogColor.r, FogColor.g, FogColor.b, fog_dis_density));
        Shader.SetGlobalColor("FogColor2", new Color(FogColor2.r, FogColor2.g, FogColor2.b, fog_dis_density));


        Shader.SetGlobalVector("FarSceneInfo", new Vector4(env_b * env_b * env_b, env_end_in_view, 0, 0));
        Shader.SetGlobalColor("FarSceneColor", new Color(farSceneColor.r, farSceneColor.g, farSceneColor.b, env_dis_density) );



        Shader.SetGlobalVector("global_fog_max", new Vector4(fog_max, fog_max1, fog_max2, 1));
        Shader.SetGlobalFloat("back_dis_density", back_dis_density*2);

        Shader.SetGlobalVector("FogBackInfor", new Vector4((1f-height_fog_back_dis_density ) * 0.5f, (1f-back_dis_density) * 0.5f, (1f-fog_back_dis_density)*0.5f));
        //Shader.SetGlobalFloat("back_dis_density", back_dis_density * 2);

        //public float fog_back_dis_density = 1f;
        //public float height_fog_back_dis_density = 1f;

        Shader.SetGlobalVector("HeightFogInfo", new Vector4(fog_height_density, fog_b * fog_b * fog_b, fog_hight_b, fog_max));
        Shader.SetGlobalFloat("height_fog_end_in_view", height_fog_end_in_view);
        Shader.SetGlobalFloat("height_fog_height_a", 1f-height_fog_height_a);
        //VirtualDirectLight0
        if (data != null && curData != data )
        {
            curData = data;
            for (int i = 0; i < 9; ++i)
            {
                string param = "g_sph" + i.ToString();
                Shader.SetGlobalVector(param, data.coefficients[i]);
            }
        }
        if (farEvn != null && curFarEnv != farEvn)
        {
            curFarEnv = farEvn;
            for (int i = 0; i < 9; ++i)
            {
                string param = "evn_sph" + i.ToString();
                Shader.SetGlobalVector(param, farEvn.coefficients[i]);
            }
        }
        float _density = density / Mathf.Sqrt(Mathf.Log(2));
        float _densityH = densityH / Mathf.Sqrt(Mathf.Log(2));

        float _color_density = color_density /  Mathf.Sqrt(Mathf.Log(2));
        //Shader.SetGlobalFloat("color_density", _color_density);
        Shader.SetGlobalFloat("env_density", _density);
        Shader.SetGlobalFloat("height_density", _densityH);
        Shader.SetGlobalFloat("color_density", color_density);

        Shader.SetGlobalFloat("globalEnvOffset", globalEnvOffset);
        //_POW_FOG_ON
        if (enable_dis)
        {
            Shader.EnableKeyword("_POW_FOG_ON");
        }
        else
        {
            Shader.DisableKeyword("_POW_FOG_ON");
        }

        if (enable_env)
        {
            Shader.EnableKeyword("ENABLE_DISTANCE_ENV");
        }
        else
        {
            Shader.DisableKeyword("ENABLE_DISTANCE_ENV");
        }
        if (enable_back_light)
        {
            Shader.EnableKeyword("ENABLE_BACK_LIGHT");
        }
        else
        {
            Shader.DisableKeyword("ENABLE_BACK_LIGHT");
        }
        if (farEvn)
        {
            Shader.EnableKeyword("GLOBAL_ENV_SH9");
        }
        else
        {
            Shader.DisableKeyword("GLOBAL_ENV_SH9");
        }
        Shader.SetGlobalFloat("fog_height_power", fog_height_power);

        var v = Matrix4x4.TRS(Vector3.zero, Quaternion.Euler(new Vector3(VirtualDirectLight0.x, VirtualDirectLight0.y, VirtualDirectLight0.z)), Vector3.one).MultiplyVector(Vector3.back);
        v.Normalize();
        //Vector3.forward
        Shader.SetGlobalVector("VirtualDirectLight0", v);
        Shader.SetGlobalVector("VirtualDirectLightColor0", new Vector4(virtualDirectLightColor0.r, virtualDirectLightColor0.g, virtualDirectLightColor0.b, virtualDirectLightColor0Intensity));



        //virtualSceneDirectLightColor0

        var v2 = Matrix4x4.TRS(Vector3.zero, Quaternion.Euler(new Vector3(VirtualSceneDirectLight0.x, VirtualSceneDirectLight0.y, VirtualSceneDirectLight0.z)), Vector3.one).MultiplyVector(Vector3.back);
        v2.Normalize();
        Shader.SetGlobalVector("VirtualDirectSceneLight0", v2);

        Shader.SetGlobalVector("VirtualScenDirectLightColor0", new Vector4(virtualSceneDirectLightColor0.r, virtualSceneDirectLightColor0.g, virtualSceneDirectLightColor0.b, virtualSceneDirectLightColor0Intensity));

        // VirtualSceneDirectLight0  ；VirtualSceneDirectLight0；
        Shader.SetGlobalFloat("_DifSC", _DifSC);
        Shader.SetGlobalColor("_BackColor", _BackColor);
        Shader.SetGlobalFloat("sss_scatter0", sss_scatter0);
        Shader.SetGlobalFloat("_CullSepe", _CullSepe);
        

        if (heightFog)
        {
            Shader.EnableKeyword("_HEIGHT_FOG_ON");
            //Shader.SetGlobalFloat("heightFogHeight", heightFogHeight);
            //Shader.SetGlobalFloat("heightFogHeight2", heightFogHeight2);
            //Shader.SetGlobalColor("farSceneColor", farSceneColor);
        }
        else
        {
            Shader.DisableKeyword("_HEIGHT_FOG_ON");
        }
        




}
}
