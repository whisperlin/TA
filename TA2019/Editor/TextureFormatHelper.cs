using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;



public class TextureFormatHelper 
{
    /// <summary>
    /// 修改图片格式
    /// </summary>
    /// <param name="path">图片路径</param>
    /// <param name="platform"> Standalone, Web, iPhone, Android, WebGL, Windows Store Apps, PS4, XboxOne, Nintendo 3DS and tvOS</param>
    /// <param name="format">格式</param>

    public static void ModifyTextureFormat(string path,string  platform,   TextureImporterFormat format,int compressionQuality = 100)
    {
        TextureImporter texImporter = TextureImporter.GetAtPath(path) as TextureImporter;
        
        if (null != texImporter)
        {
 
            var setting = texImporter.GetPlatformTextureSettings(platform);
            if (setting.format != format || setting.overridden != true)
            {
                setting.overridden = true;
                setting.format = format;
                setting.compressionQuality = compressionQuality;
                texImporter.SetPlatformTextureSettings(setting);
            }
            
        }
    } 
    
}

#endif
