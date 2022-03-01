using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class AssetPostprocessorEvent : UnityEditor.AssetPostprocessor
{
    //模型导入之前调用  
    public void OnPreprocessModel()
    {
        //Debug.Log("OnPreprocessModel=" + this.assetPath);
    }
    //模型导入之前调用  
    public void OnPostprocessModel(GameObject go)
    {
        //Debug.Log("OnPostprocessModel=" + go.name);
    }
    //纹理导入之前调用，针对入到的纹理进行设置  
    public void OnPreprocessTexture()
    {
        //Lightmap-0_comp_light
        

        if (this.assetPath.Contains("Lightmap") && this.assetPath.Contains("comp_light"))
        {
            string meta_path = this.assetPath+".meta";
            Debug.Log("meta_path = "+ meta_path);
            TextureImporter impor = this.assetImporter as TextureImporter;
            impor.sRGBTexture = false;
            if (System.IO.File.Exists(meta_path))
            {
                string meta_text = System.IO.File.ReadAllText(meta_path);

                meta_text = meta_text.Replace("sRGBTexture: 1", "sRGBTexture: 0");
                Debug.Log(meta_text);
                System.IO.File.WriteAllText(meta_path, meta_text);
                AssetDatabase.ImportAsset(this.assetPath);
                Debug.Log("found");
            }
            else
            {
                Debug.Log("not found");
            }


        }
 
    }

    //文理导入之后
    public void OnPostprocessTexture(Texture2D tex)
    {
         
    }

    //音频导入之前
    public void OnPreprocessAudio()
    {
         
    }

    //音频导入之后
    public void OnPostprocessAudio(AudioClip clip)
    {
         
    }

    //所有的资源的导入，删除，移动，都会调用此方法，注意，这个方法是static的  
    public static void OnPostprocessAllAssets(string[] importedAsset, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
    {
         
    }
}
