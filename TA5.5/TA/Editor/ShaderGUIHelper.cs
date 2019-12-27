using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class ShaderGUIHelper  {


    public static string GetAssetPathAndName(Object obj)
    {
        string path = AssetDatabase.GetAssetPath(obj);

        path = path.Substring(0, path.LastIndexOf('.'));
        return path;
    }

    public static  void CombineTextureToTga(string savePath, Texture [] editorArray,bool [] defualts)
    {

        Texture2D black = new Texture2D(1, 1, TextureFormat.RGBA32, false);
        black.SetPixel(0, 0, Color.black);
        black.Apply();

        Texture2D white = new Texture2D(1, 1, TextureFormat.RGBA32, false);
        white.SetPixel(0, 0, Color.white);
        white.Apply();
        int width = 1;
        int height = 1;
        for (int i = 0; i < editorArray.Length; i++)
        {
            if (null == editorArray[i])
            {
                if (defualts[i])
                {
                    editorArray[i] = white;
                }

                else
                {
                    editorArray[i] = black;
                }
                
                continue;
            }
            width = Mathf.Max(width, editorArray[i].width);
            height = Mathf.Max(height, editorArray[i].height);
        }
        if (width == 0)
            return;
        RenderTexture[] temp = new RenderTexture[editorArray.Length];
        Texture2D[] temp2 = new Texture2D[editorArray.Length];

        for (int i = 0; i < editorArray.Length; i++)
        {
            temp[i] = RenderTexture.GetTemporary(width, height);

            if (null != editorArray[i])
            {
                Graphics.Blit(editorArray[i], temp[i]);
            }


            temp2[i] = new Texture2D(width, height, TextureFormat.RGBA32, false);

            RenderTexture.active = temp[i];
            temp2[i].ReadPixels(new Rect(0, 0, width, height), 0, 0);
            temp2[i].Apply();
            RenderTexture.ReleaseTemporary(temp[i]);
        }

        Texture2D final = new Texture2D(width, height, TextureFormat.RGBA32, false);
        float[] _cols = new float[4];
        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                for (int k = 0; k < 4; k++)
                {
                    //_cols[k] = temp2[k].GetPixel(i, j).r* temp2[k].GetPixel(i, j).a;
                    _cols[k] = temp2[k].GetPixel(i, j).r ;
                }


                final.SetPixel(i, j, new Color(_cols[0], _cols[1], _cols[2], _cols[3]));
            }
        }
        final.Apply();
        for (int i = 0; i < editorArray.Length; i++)
        {
            GameObject.DestroyImmediate(temp2[i]);
        }
        int iBytesPerPixel = 4;
        if (editorArray.Length > 3 && (black == editorArray[3] || white == editorArray[3]))
        {
            iBytesPerPixel = 3;
        }
         
        //TextureFormat.ARGB32 || _texture2D.format == TextureFormat.RGBA32
        byte[] date = EncodeToTGAExtension.EncodeToTGA(final, iBytesPerPixel);
        //byte[] date = TgaUtil.Texture2DEx.EncodeToTGA(final, true);
        //byte [] date =  final.EncodeToPNG ();
        System.IO.File.WriteAllBytes(savePath, date);
        GameObject.DestroyImmediate(final);
        GameObject.DestroyImmediate(black);
        GameObject.DestroyImmediate(white);
        

    }

    public static void SaveMatAndClearTexture(Material targetMat, string[] param)
    {
        string path = AssetDatabase.GetAssetPath(targetMat);
        path = path.Substring(0, path.Length - 3) + "sav";
        Material mat = new Material(targetMat.shader);
        mat.CopyPropertiesFromMaterial(targetMat);
        AssetDatabase.CreateAsset(mat, path);
        for (int j = 0, l2 = param.Length; j < l2; j++)
        {
            targetMat.SetTexture(param[j], null );
        }
    }

    public static void LoadTextureFormSaveMat(Material targetMat,string [] param)
    {
        string path = AssetDatabase.GetAssetPath(targetMat);
        if (path == null || path.Length == 0)
            return;
        path = path.Substring(0, path.Length - 3) + "sav";
        if (System.IO.File.Exists(path))
        {
            Object [] ary = AssetDatabase.LoadAllAssetsAtPath(path);
            
            if (ary.Length == 0)
                return;
            Material mat = (Material)ary[0];
            if (null == mat)
                return;
            for (int j = 0, l2 = param.Length; j < l2; j++)
            {
                var t = mat.GetTexture(param[j]);
                targetMat.SetTexture(param[j],t);
            }
        } 
    }

    public static MaterialProperty   RemoveRroperty (List<MaterialProperty> result, string propertyName)
    {
        for (int i = 0, l1 = result.Count; i < l1; i++)
        {
            if (result[i].name == propertyName)
            {
                MaterialProperty p = result[i];
                result.RemoveAt(i);
                return p;
            }
        }
        return null;
    }

    public static bool RemoveExclusion(  MaterialProperty[] properties, bool ctrlProperty, string[] params1, string[] param2, List<MaterialProperty> result)
    {
        
        if (ctrlProperty)
        {
            for (int j = 0, l2 = params1.Length; j < l2; j++)
            {

                for (int i = 0, l1 = result.Count; i < l1; i++)
                {
                    if (result[i].name == params1[j])
                    {
                        result.RemoveAt(i);
                        break;
                    }
                }

            }
            return true;
        }
        else
        {
            

            for (int j = 0, l2 = param2.Length; j < l2; j++)
            {

                for (int i = 0, l1 = result.Count; i < l1; i++)
                {
                    if (result[i].name == param2[j])
                    {
                        result.RemoveAt(i);
                        break;
                    }
                }

            }
            return false;
        }

    }
    
}
