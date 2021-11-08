using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using UnityEngine.Rendering;
public enum BlendModeSimple
{
    //
    // 摘要:
    //     Blend factor is (0, 0, 0, 0).
    Zero = 0,
    //
    // 摘要:
    //     Blend factor is (1, 1, 1, 1).
    One = 1,
    
    //
    // 摘要:
    //     Blend factor is (1 - As, 1 - As, 1 - As, 1 - As).
    OneMinusSrcAlpha = 10
}
public enum BlendModeSimpleFirst
{
    //
    // 摘要:
    //     Blend factor is (0, 0, 0, 0).
    Zero = 0,
    //
    // 摘要:
    //     Blend factor is (1, 1, 1, 1).
    One = 1,
    SrcAlpha = 5,
    //
    // 摘要:
    //     Blend factor is (1 - As, 1 - As, 1 - As, 1 - As).
    
}
public enum ZTestFunction
{
    // 摘要:
    [EnumAttirbute("正常剔除")]
    //     
    LessEqual = 4,
    [EnumAttirbute("不剔除")]
    //     不剔除
    Always = 8
}
//
// 摘要:
//     Backface culling mode.
public enum CullMode
{
    //
    // 摘要:
    //     Disable culling.
    Off = 0,
    //
    // 摘要:
    //     Cull front-facing geometry.
    Front = 1,
    //
    // 摘要:
    //     Cull back-facing geometry.
    Back = 2
}
public enum LCHCullModel
{
    [EnumAttirbute("开双面")]
    Off = 0,
    //Front = 1,
    [EnumAttirbute("正面剔除")]
    Back = 2
}
public enum LCHblendlModel
{
    [EnumAttirbute("无混合")]
    Off = 0,
    [EnumAttirbute("传统混合")]
    BLEND = 1,
    [EnumAttirbute("加法")]
    ADD = 2,
     [EnumAttirbute("加法(读Alpha)")]
    ADD2 = 3
}
public class MyToggleDrawer : MaterialPropertyDrawer
{
    public override void OnGUI(Rect position, MaterialProperty prop, String label, MaterialEditor editor)
    {
        bool value = (prop.floatValue != 0.0f);
        EditorGUI.BeginChangeCheck();
        EditorGUI.showMixedValue = prop.hasMixedValue;
        value = EditorGUI.Toggle(position, label, value);

        EditorGUI.showMixedValue = false;
        if (EditorGUI.EndChangeCheck())
        {
            prop.floatValue = value ? 1.0f : 0.0f;
        }
    }
}
public class LCHShaderGUIBase : ShaderGUI
{
    public bool IsVisible(ref string displayName, Material targetMat)
    {
        bool _result = true;
        string[] lines = displayName.Split('\n');
        for (int i = 0; i < lines.Length; i++)
        {
            string line = lines[i].Trim();
            if(line.Length==0)
                continue;
            int index0 = line.LastIndexOf("[");
            int index1 = line.LastIndexOf("]");
            if (index0 >= 0 && index1 > index0)
            {
                index0++;
                string keyWorld = line.Substring(index0, index1 - index0);
                string[] condictions = keyWorld.Split('&');
                bool isOk = true;
                for (int j = 0; j < condictions.Length && isOk; j++)
                {
                    string cnd = condictions[j];
                    string[] keys = cnd.Split('=');
                    if (keys.Length == 1)
                    {
                        if (index1 < line.Length - 1)
                        {
                            displayName = line.Substring(0, index0 - 1) + line.Substring(index1 + 1);
                        }
                        else
                        {
                            displayName = line.Substring(0, index0 - 1) ;
                        }
                        
                        keys[0] = keys[0].Trim();
                        if (keys[0].StartsWith("!"))
                        {
                            bool b = targetMat.IsKeywordEnabled(keys[0].Substring(1).Trim());
                            if (b)
                                isOk = false;
                        }
                        else
                        {
                            if (!targetMat.IsKeywordEnabled(keys[0]))
                                isOk =  false;
                        }
                    }
                    else if (keys.Length == 2)
                    {
                        //去掉空格
                        if (index1 < line.Length - 1)
                        {
                            displayName = line.Substring(0, index0 - 1) + line.Substring(index1 + 1);
                        }
                        else
                        {
                            displayName = line.Substring(0, index0 - 1);
                        }
                        if (int.TryParse(keys[1].Trim(), out int n))
                        {
                            keys[0] = keys[0].Trim();
                            if (targetMat.HasProperty(keys[0]))
                            {
                                if (!(Mathf.Abs(targetMat.GetFloat(keys[0]) - n) < 0.01f))
                                    isOk =  false;
                            }
                        }
                    }
                }
                if (isOk)
                    return true;
                else
                    _result = false; 
            }
        }
        return _result;
    }
    public bool ModifyTextureFormatSmall(string path, string platformString = "Android" )
    {
        TextureImporterPlatformSettings textureSettings = new TextureImporterPlatformSettings();
        try
        {
            bool textureModify = false; ;
            TextureImporter ti = (TextureImporter)TextureImporter.GetAtPath(path);
            textureSettings = ti.GetPlatformTextureSettings(platformString);
            if (
                textureSettings.format == TextureImporterFormat.RGBA32
                    || textureSettings.format == TextureImporterFormat.RGBA16
                    || textureSettings.format == TextureImporterFormat.ARGB32
                    || textureSettings.format == TextureImporterFormat.ARGB16
                    )
            {
                
                textureSettings.format = TextureImporterFormat.ASTC_RGBA_5x5;
                textureModify = true;

            }

            else if (textureSettings.format == TextureImporterFormat.RGB16
                    || textureSettings.format == TextureImporterFormat.RGB24
                    )
            {
                textureSettings.format = TextureImporterFormat.ASTC_RGBA_5x5;
                textureModify = true;
            }

            if (textureSettings.maxTextureSize > 512)
            {
                textureSettings.maxTextureSize = 512;
                textureModify = true;
            }
            textureSettings.overridden = true;
            textureSettings.androidETC2FallbackOverride = AndroidETC2FallbackOverride.Quality32BitDownscaled;
            if (textureModify)
            {
                ti.SetPlatformTextureSettings(textureSettings);
                AssetDatabase.SaveAssets();
                return true;
            }
           
        }
        catch (System.Exception e)
        {
            Debug.LogError(e.ToString() + " " + textureSettings.format + "" + path + "\n" + e.StackTrace);
        }
        return false;
    }
    public bool ModifyTextureFormat(string path, string platformString = "Android", bool smallChange = false)
    {
        TextureImporterPlatformSettings textureSettings = new TextureImporterPlatformSettings();
        try
        {
            TextureImporter ti = (TextureImporter)TextureImporter.GetAtPath(path);
            textureSettings = ti.GetPlatformTextureSettings(platformString);
            if (
                textureSettings.format == TextureImporterFormat.RGBA32
                    || textureSettings.format == TextureImporterFormat.RGBA16
                    || textureSettings.format == TextureImporterFormat.ARGB32
                    || textureSettings.format == TextureImporterFormat.ARGB16
                    )
            {
                textureSettings.overridden = true;
                if (smallChange)
                {
                    textureSettings.format = TextureImporterFormat.ASTC_RGBA_5x5;
                }
                else
                {
                    textureSettings.format = TextureImporterFormat.ASTC_RGBA_4x4;
                }

                textureSettings.androidETC2FallbackOverride = AndroidETC2FallbackOverride.Quality32BitDownscaled;
                ti.SetPlatformTextureSettings(textureSettings);
                AssetDatabase.SaveAssets();
                //AssetDatabase.ImportAsset(path);
                Debug.Log("修改图片" + path + " " + textureSettings.format.ToString());
                return true;
            }

            else if (textureSettings.format == TextureImporterFormat.RGB16
                    || textureSettings.format == TextureImporterFormat.RGB24
                    )
            {
                textureSettings.overridden = true;
                if (ti.alphaIsTransparency)
                {
                    if (smallChange)
                    {
                        textureSettings.maxTextureSize = 512;
                        textureSettings.format = TextureImporterFormat.ASTC_RGBA_5x5;
                    }
                    else
                    {
                        textureSettings.format = TextureImporterFormat.ASTC_RGBA_4x4;
                    }
                }
                else
                {
                    if (smallChange)
                    {
                        textureSettings.maxTextureSize = 512;
                        textureSettings.format = TextureImporterFormat.ASTC_RGB_5x5;
                    }
                    else
                    {
                        textureSettings.format = TextureImporterFormat.ASTC_RGB_4x4;
                    }
                }

                textureSettings.androidETC2FallbackOverride = AndroidETC2FallbackOverride.Quality32BitDownscaled;
                ti.SetPlatformTextureSettings(textureSettings);
                AssetDatabase.SaveAssets();
                Debug.Log("修改图片" + path + " " + textureSettings.format.ToString());
                return true;
            }
        }
        catch (System.Exception e)
        {
            Debug.LogError(e.ToString() + " " + textureSettings.format + "" + path + "\n" + e.StackTrace);
        }
        return false;
    }
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        Material targetMat = materialEditor.target as Material;

        bool lockInstance = false;
        if (targetMat.shader != null && targetMat.shader.name.Contains("GPU Instancing"))
        {
            lockInstance = true;
            targetMat.enableInstancing = true;
        }
        for (int i = 0; i < properties.Length; i++)
        {
            var pop = properties[i];
            if (pop.flags == MaterialProperty.PropFlags.HideInInspector)
            {
                continue;
            }
            string displayName = pop.displayName;
            bool clearTex = displayName.Contains("{clear}");
            if (clearTex)
            {
                displayName.Replace("{clear}", "");
            }
            if (IsVisible(ref displayName, targetMat))
            {
                EditorGUI.BeginChangeCheck();
                materialEditor.ShaderProperty(pop, displayName);
                if (EditorGUI.EndChangeCheck())
                {
                    OnPorpertyModify(targetMat, pop);
                    //Debug.LogError(pop.name);
                }
            }
            else
            {
                if (clearTex)
                {
                    targetMat.SetTexture(pop.name, null);
                    EditorUtility.SetDirty(targetMat);
                }
            }
        }
        GUILayout.Space(20);
        materialEditor.RenderQueueField();
        if (lockInstance)
        {
            if (targetMat.enableInstancing)
            {
                GUILayout.Label("GPU Instancing 已开启");
            }
            else
            {
                GUILayout.Label("GPU Instancing 已关闭");
            }
        }
        else
        {
            materialEditor.EnableInstancingField();
        }
    }

    void OnPorpertyModify( Material targetMat, MaterialProperty pop )
    {
        if (pop.name == "_bendModel")
        {
            int _bendModel2 =  (int)(pop.floatValue+0.000001f);
            ModifyBlendModel(targetMat, _bendModel2);
            EditorUtility.SetDirty(targetMat);
        }
    }
    void ModifyBlendModel(Material mat, int _bendModel2)
    {
        switch (_bendModel2)
        {
            case 0:
                {
                    mat.SetInt("_SrcBlend",(int)UnityEngine.Rendering.BlendMode.One);
                    mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    mat.SetInt("_ZWrite", 1);
                    if (mat.renderQueue >= 2500)
                    {
                       
                        mat.renderQueue = 2500;
                    }
                }
                break;
            case 1:
                {
                    mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    mat.SetInt("_ZWrite", 0);
                    if (mat.renderQueue <= 2500)
                    {
                        mat.renderQueue = 3000;
                    }
                }
                break;
            case 2:
                {
                    mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    mat.SetInt("_ZWrite", 0);
          
                    if (mat.renderQueue <= 2500)
                    {
                        mat.renderQueue = 3000;
                    }
                }
                break;
            case 3:
                {
                    mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    mat.SetInt("_ZWrite", 0);

                    if (mat.renderQueue <= 2500)
                    {
                        mat.renderQueue = 3000;
                    }
                }
                break;
        }
    }
     
}

 
