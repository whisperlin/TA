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
    public Cubemap ibl;
    Cubemap curIbl;
#endif

    [Label("反射球(sbl)")]
    public Texture2D sbl;
    Texture2D curSbl = null;
    public Vector4[] iblCoefficients = new Vector4[0];
    [Label("烘培贴图颜色")]
    public Color LightMapColor = Color.white;
    [Label("烘培贴图亮度提高",    0.0f, 1f)]
    public float LightMapIntensity = 0.2f;

  
#if UNITY_EDITOR
    public void UpdateSH9FormCubeMap()
    {
        if (curIbl != ibl)
        {
            if (null == ibl)
            {
                iblCoefficients = new Vector4[0];
            }
            else
            {
                ModifyTextureReadable(ibl);
                iblCoefficients = new Vector4[9];
                if (SphericalHarmonics.CPU_Project_Uniform_9Coeff(ibl, iblCoefficients))
                {
                }
            }
            curIbl = ibl  ;
        }
 
    }


    void ModifyTextureReadable(Cubemap input_cubemap)
    {
        string path = AssetDatabase.GetAssetPath(input_cubemap);
        if (null == path || path.Length == 0)
        {
            return;
        }
        TextureImporter textureImporter = AssetImporter.GetAtPath(path) as TextureImporter;
        if (null == textureImporter)
            return;
        textureImporter.isReadable = true;
        textureImporter.SaveAndReimport();
    }


#endif

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
        UpdateSH9FormCubeMap();
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
        if (iblCoefficients.Length>0)
        { 
            for (int i = 0; i < 9; ++i)
            {
                string param = "g_sph" + i.ToString();
                Shader.SetGlobalVector(param, iblCoefficients[i]);
            }
        }
        
#if !UNITY_EDITOR
        }
#endif

        if (iblCoefficients.Length > 0)
        {
            Shader.EnableKeyword("GLOBAL_SH9");
        }
        else
        {
            Shader.DisableKeyword("GLOBAL_SH9");
        }
        Shader.SetGlobalVector("LightMapInf",new Vector4(LightMapColor.r, LightMapColor.g, LightMapColor.b, LightMapIntensity));
    }
}
