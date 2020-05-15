using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System.IO;

public partial class ResourceExporter
{

    static void GetAllTex(  )
    {
        List<string> texPathLs = new List<string>();
        GetAssetsTexInSubFolderForAtlas("assets", ref texPathLs);
        int totalCount = texPathLs.Count;
        if (texPathLs.Count > 0)
        {
            int iCurCount = 0;
            foreach (var path in texPathLs)
            {
                TextureFormatHelper.ModifyTextureFormat(path, "Android", TextureImporterFormat.ASTC_RGBA_4x4);
                TextureFormatHelper.ModifyTextureFormat(path, "iPhone", TextureImporterFormat.ASTC_RGBA_4x4);
                EditorUtility.DisplayCancelableProgressBar("Check TexFormat", "Wait......", (++iCurCount) * 1f / totalCount);
            }
        }
        EditorUtility.ClearProgressBar();
    }
    static void AddFilePathToList(string[] files, ref List<string> ls)
    {
        foreach (string oneFile in files)
        {
            string srcFile = oneFile.Replace(@"\", @"/");
            string lowerFile = srcFile.ToLower();
            ls.Add(lowerFile);
        }
    }

    static void GetAssetsTexInSubFolderForAtlas(string srcFolder, ref List<string> atlas)
    {
        string searchPattern0 = "*.png";
        string searchPattern1 = "*.tga";
        string searchPattern2 = "*.psd";
        string searchFolder = srcFolder.Replace(@"\", @"/");
        string searchDir0 = searchFolder;
        if (Directory.Exists(searchDir0))
        {
            //string[] files = Directory.GetFiles(searchDir0, searchPattern);
            AddFilePathToList(Directory.GetFiles(searchDir0, searchPattern0), ref atlas);
            AddFilePathToList(Directory.GetFiles(searchDir0, searchPattern1), ref atlas);
            AddFilePathToList(Directory.GetFiles(searchDir0, searchPattern2), ref atlas);
        }

        string[] dirs = Directory.GetDirectories(searchFolder);
        foreach (string oneDir in dirs)
        {
            GetAssetsTexInSubFolderForAtlas(oneDir, ref atlas);
        }
    }

   

    [MenuItem("MyEditor/Replace Texture Format")]
    public static void ReplaceTextureFormat()
    {
        GetAllTex(); 
        //GetAllTex(true, CheckAndroidFormat, CheckIphoneFormat, ReplacePlatformFormat);
        //SaveTextureFormatInfoPath(infoLs);
    }
}
 