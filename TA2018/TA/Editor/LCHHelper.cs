using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class LCHHelper 
{
    [MenuItem("TA/其它/转换预览材质")]
    public static void SceneToPerview()
    {
        Renderer[] rs = GameObject.FindObjectsOfType<Renderer>();
        Shader shaderSimple = Shader.Find("TA/Substance PBR EX Simple");
        Shader shaderPerview = Shader.Find("TA/Substance PBR  Perview");
        foreach (Renderer r in rs)
        {
            foreach (Material m in r.sharedMaterials)
            {
                if (m.shader == shaderSimple)
                {
                    m.shader = shaderPerview;
                }
            }
        }
    }

    [MenuItem("TA/其它/转换预览材质为场景材质")]
    public static void PerviewToScene()
    {
        Renderer[] rs = GameObject.FindObjectsOfType<Renderer>();
        Shader shaderSimple = Shader.Find("TA/Substance PBR EX Simple");
        Shader shaderPerview = Shader.Find("TA/Substance PBR  Perview");
        foreach (Renderer r in rs)
        {
            foreach (Material m in r.sharedMaterials)
            {
                if (m.shader == shaderPerview)
                {
                    m.shader = shaderSimple;
                }
            }
        }
    }
}
