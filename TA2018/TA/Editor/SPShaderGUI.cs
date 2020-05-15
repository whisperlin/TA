using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class SPShaderGUI : ShaderGUI
{
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        GUILayout.Label("自定义ShaderGUI");
        
        Material targetMat = materialEditor.target as Material;
        List<MaterialProperty> result = new List<MaterialProperty>(properties);
        if (targetMat.HasProperty("_NORMALMAP"))
        {
            bool b = targetMat.IsKeywordEnabled("_NORMALMAP");
            if (!b)
                ShaderGUIHelper.RemoveRroperty(result, "_BumpMap");
        }

        if (targetMat.HasProperty("SSS_EFFECT"))
        {
            bool b = targetMat.IsKeywordEnabled("SSS_EFFECT");
            if (!b)
            {
                ShaderGUIHelper.RemoveRroperty(result, "_BRDFTex");
                ShaderGUIHelper.RemoveRroperty(result, "_S3SPower");
                ShaderGUIHelper.RemoveRroperty(result, "_Metallic2");
                
            }
        }
        if (targetMat.HasProperty("ALPHA_CLIP"))
        {
            bool b = targetMat.IsKeywordEnabled("ALPHA_CLIP");
            if (!b)
                ShaderGUIHelper.RemoveRroperty(result, "_AlphaClip");
        }

        if (targetMat.HasProperty("ALPHA_CLIP"))
        {
            bool b = targetMat.IsKeywordEnabled("ALPHA_CLIP");
            if (!b)
                ShaderGUIHelper.RemoveRroperty(result, "_AlphaClip");
        }
        if (targetMat.HasProperty("EMISSSION"))
        {
            bool b = targetMat.IsKeywordEnabled("EMISSSION");
            if (!b)
            {
                ShaderGUIHelper.RemoveRroperty(result, "_EmissionColor");
                ShaderGUIHelper.RemoveRroperty(result, "_EmissionMark");
                



            }
        }
        //-luminous;
        base.OnGUI(materialEditor, result.ToArray());
    }
     
}
