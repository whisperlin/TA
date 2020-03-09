using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SH9Data : ScriptableObject
{
    public Vector4 [] coefficients = new Vector4[9];
}

[System.Serializable]
public class SH9Struct
{
    public Vector4[] coefficients = new Vector4[9];

    string[] shader_params = null;
    public void Commit(string paramName = "g_sph",string KeyWord = "GLOBAL_SH9")
    {
        if (null == shader_params || shader_params.Length ==0)
        {
            shader_params = new string[9];
            for (int i = 0; i < 9; ++i)
            {
                shader_params[i] = paramName + i.ToString(); 
            }
        }
        if (coefficients.Length > 0)
        {
            for (int i = 0; i < 9; ++i)
            {
                Shader.SetGlobalVector(shader_params[i], coefficients[i]);
            }
        }

        if (coefficients.Length > 0)
        {
            Shader.EnableKeyword(KeyWord);
        }
        else
        {
            Shader.DisableKeyword(KeyWord);
        }
    }
}
