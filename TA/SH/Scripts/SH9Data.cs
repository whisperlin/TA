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
    public void Commit(string paramName = "g_sph",string KeyWord = "GLOBAL_SH9")
    {
        if (coefficients.Length > 0)
        {
            for (int i = 0; i < 9; ++i)
            {
                string param = paramName + i.ToString();
                Shader.SetGlobalVector(param, coefficients[i]);
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
