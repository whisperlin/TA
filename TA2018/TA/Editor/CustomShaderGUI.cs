using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;

public class CustomShaderGUI : ShaderGUI
{
    override public void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // render the shader properties using the default GUI
        base.OnGUI(materialEditor, properties);

        // get the current keywords from the material
        Material targetMat = materialEditor.target as Material;
        string[] keyWords = targetMat.shaderKeywords;

        // see if redify is set, then show a checkbox
        bool redify = keyWords.Contains("REDIFY_ON");
        EditorGUI.BeginChangeCheck();
        redify = EditorGUILayout.Toggle("Redify material", redify);
        if (EditorGUI.EndChangeCheck())
        {
            // if the checkbox is changed, reset the shader keywords
            var keywords = new List<string> { redify ? "REDIFY_ON" : "REDIFY_OFF" };
            targetMat.shaderKeywords = keywords.ToArray();
            EditorUtility.SetDirty(targetMat);
        }
    }
}