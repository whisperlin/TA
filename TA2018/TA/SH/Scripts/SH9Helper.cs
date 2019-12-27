using System.Collections;
using System.Collections.Generic;

using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
public class SH9Helper 
{
    public static void ModifyTextureReadable(Cubemap input_cubemap)
    {
#if UNITY_EDITOR
        string path = AssetDatabase.GetAssetPath(input_cubemap);
        if (null == path || path.Length == 0)
        {
            return;
        }
        TextureImporter textureImporter = AssetImporter.GetAtPath(path) as TextureImporter;
        if (null == textureImporter)
            return;
        if (textureImporter.isReadable == false)
        {
            textureImporter.isReadable = true;

            textureImporter.SaveAndReimport();
        }
#endif
    }


    public static  void UpdateSH9FormCubeMap(Cubemap ibl, ref Cubemap curIbl, SH9Struct iblData)
    {
        if (curIbl != ibl)
        {
            if (null == ibl)
            {
                iblData.coefficients = new Vector4[0];
            }
            else
            {
                SH9Helper.ModifyTextureReadable(ibl);
                iblData.coefficients = new Vector4[9];
                if (SphericalHarmonics.CPU_Project_Uniform_9Coeff(ibl, iblData.coefficients))
                {
                }
            }
            curIbl = ibl;
        }
    }
}
