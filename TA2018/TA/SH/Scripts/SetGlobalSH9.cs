using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

[ExecuteInEditMode]
public class SetGlobalSH9 : MonoBehaviour {

    [Label("开启深度贴图")]
    public bool openDepthTexture =false;
#if UNITY_EDITOR
    [Label("ibl(场景)")]
    public Cubemap ibl;
    Cubemap curIbl;
#endif

#if UNITY_EDITOR
    [Label("ibl(角色-身体)")]
    public Cubemap ibl2;
    Cubemap curIbl2;

    [Label("ibl(角色-脸)")]
    public Cubemap ibl3;
    Cubemap curIbl3;
#endif

    [Label("反射球(sbl)")]
    public Texture2D sbl;
    Texture2D curSbl = null;



    //public Vector4[] iblCoefficients = new Vector4[0];

    public SH9Struct iblData;
    public SH9Struct iblData2;
    public SH9Struct iblData3;
    [Label("烘培贴图颜色")]
    public Color LightMapColor = Color.white;
    [Label("烘培贴图亮度提高",    -1f, 1f)]
    public float LightMapIntensity = 0.2f;


    [Label("角色光照调整",-1f,1f)]
    public float RoleLightPower = 0f;

 

    public bool updateSH9Data = true;


    // Use this for initialization
    void Start () {
        curSbl = null;
        updateSH9Data = true;
        setSH9Global();
    }
	// Update is called once per frame
	void Update () {
#if UNITY_EDITOR
        SH9Helper.UpdateSH9FormCubeMap(ibl,ref curIbl,iblData);
        SH9Helper.UpdateSH9FormCubeMap(ibl2, ref curIbl2, iblData2);
        SH9Helper.UpdateSH9FormCubeMap(ibl3, ref curIbl3, iblData3);
        
        setSH9Global();
#endif
       
    }
    private void setSH9Global()
    {
        if (openDepthTexture)
        {
            Camera.main.depthTextureMode = DepthTextureMode.Depth;
            Shader.EnableKeyword("__DEPTH_TEXTURE_MODE");
        }
        else
        {
            Shader.DisableKeyword("__DEPTH_TEXTURE_MODE");
        }
 
#if !UNITY_EDITOR
        if (curSbl != sbl)
        {
#endif
            Shader.SetGlobalTexture("GlobalSBL", sbl);
#if !UNITY_EDITOR
            curSbl = sbl  ;
        }
#endif



#if !UNITY_EDITOR
        if (updateSH9Data)
        {
            updateSH9Data = false;
#endif
        iblData.Commit("g_sph", "GLOBAL_SH9");
        iblData2.Commit("g_sph_role", "GLOBAL_SH9_ROLE");
        iblData3.Commit("g_sph_role2", "GLOBAL_SH9_ROLE2");


#if !UNITY_EDITOR
        }
#endif


        Shader.SetGlobalFloat("RoleLightPower", RoleLightPower);
        Shader.SetGlobalVector("LightMapInf",new Vector4(LightMapColor.r, LightMapColor.g, LightMapColor.b, LightMapIntensity));
    }
}
