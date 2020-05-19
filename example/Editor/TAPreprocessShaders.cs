
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Callbacks;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;

 

public class TAPreprocessShaders : IPreprocessShaders
{
    private ShaderKeyword[] m_ForbidenKeywords;


    public TAPreprocessShaders()
    {
 

        m_ForbidenKeywords = new ShaderKeyword[] {
                 new ShaderKeyword("FOG_EXP"),
                 new ShaderKeyword("FOG_EXP2"),
                 new ShaderKeyword("FOG_LINEAR"),
                 new ShaderKeyword("DYNAMICLIGHTMAP_ON"),
                 new ShaderKeyword("VERTEXLIGHT_ON")
                 
             };

    }

    // Multiple callback may be implemented. 
    // The first one executed is the one where callbackOrder is returning the smallest number.
    public int callbackOrder { get { return 0; } }

    
        public void OnProcessShader(
        Shader shader, ShaderSnippetData snippet, IList<ShaderCompilerData> shaderCompilerData)
    {
       

        // In development, don't strip debug variants
        if (EditorUserBuildSettings.development)
            return;

        for (int i = 0; i < shaderCompilerData.Count; ++i)
        {
            for (int j = 0; j < m_ForbidenKeywords.Length; j++)
            {
                if (shaderCompilerData[i].shaderKeywordSet.IsEnabled(m_ForbidenKeywords[j]))
                {
                    Debug.LogError("Remove one form " + shader.name);
                    shaderCompilerData.RemoveAt(i);
                    --i;
                    continue;
                }
            }
            
        }
        Debug.LogError("OnProcessShader " + shader.name +" Key World Count "+ shaderCompilerData.Count);

    }
}
