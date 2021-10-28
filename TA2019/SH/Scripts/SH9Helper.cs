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
                    /*g_sph0.xyz * 0.2820947917f +
                    g_sph1.xyz * 0.4886025119f * v.y;
                    g_sph2.xyz * 0.4886025119f * v.z;
                    g_sph3.xyz * 0.4886025119f * v.x;
                    g_sph4.xyz * 1.0925484306f * v.x * v.y;
                    g_sph5.xyz * 1.0925484306f * v.y * v.z;
                    g_sph6.xyz * 0.3153915652f * (3.0f * v.z * v.z - 1.0f);
                    g_sph7.xyz * 1.0925484306f * v.x * v.z;
                    g_sph8.xyz * 0.5462742153f * (v.x * v.x - v.y * v.y);
                    */
                    iblData.coefficients[0] = iblData.coefficients[0] * 0.2820947917f ;
                    iblData.coefficients[1] = iblData.coefficients[1] * 0.4886025119f ;
                    iblData.coefficients[2] = iblData.coefficients[2] * 0.4886025119f  ;
                    iblData.coefficients[3] = iblData.coefficients[3] * 0.4886025119f ;
                    iblData.coefficients[4] = iblData.coefficients[4] * 1.0925484306f ;
                    iblData.coefficients[5] = iblData.coefficients[5] * 1.0925484306f  ;
                    iblData.coefficients[6] = iblData.coefficients[6] * 0.3153915652f  ;
                    iblData.coefficients[7] = iblData.coefficients[7] * 1.0925484306f  ;
                    iblData.coefficients[8] = iblData.coefficients[8] * 0.5462742153f  ;
                }
            }
            curIbl = ibl;
        }
    }
}
