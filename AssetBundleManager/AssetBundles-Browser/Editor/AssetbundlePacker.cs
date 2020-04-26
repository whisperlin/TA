using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
 
public class AssetbundlePacker
{
    // 打包输出目录   路径统一都加/结尾
    private static string RES_OUTPUT_PATH = "Assets/StreamingAssets/";
    private static string[] RES_DIRS = new string[] { "Assets/Scenes", "Assets/Test" /*, "Assets/TA" */};


    // AssetBundle打包后缀
    private static string ASSET_BUNDLE_SUFFIX = ".unity3d";

    /// <summary>
	/// 清理之前设置的bundleName
	/// </summary>
	public static void ClearAssetBundleName()
    {
        string[] bundleNames = AssetDatabase.GetAllAssetBundleNames();
        for (int i = 0; i < bundleNames.Length; i++)
        {
            AssetDatabase.RemoveAssetBundleName(bundleNames[i], true);
        }
    }

    public static string GetBuildDir(BuildTarget target)
    {
        return RES_OUTPUT_PATH + target.ToString();
    }
    /// <summary>
	/// 创建和清理输出目录
	/// </summary>
	public static void CreateOrClearOutPath(BuildTarget target)
    {
        if (!System.IO.Directory.Exists(RES_OUTPUT_PATH))
        {
            // 不存在创建
            System.IO.Directory.CreateDirectory(RES_OUTPUT_PATH);
        }
        string path = GetBuildDir(target);
        if (!System.IO.Directory.Exists(path))
        {
            // 不存在创建
            System.IO.Directory.CreateDirectory(path);
        }
        else
        {
            // 存在就清理
            System.IO.Directory.Delete(path, true);
            System.IO.Directory.CreateDirectory(path);
        }
    }

    public static void MarkAssetName()
    {
        ClearAssetBundleName();

        foreach (string dir in RES_DIRS)
        {
            List<string> resList = GetAllResDirs(dir);
            foreach (string subDir in resList)
                setAssetBundleName(dir, subDir);
        }
    }


  

    [MenuItem("TA/Assets/打包Android", false, 351)]
    public static void PackAndroid()
    {
        BuildTarget target = BuildTarget.Android;
        MarkAssetName();
        BuildBundle(target);
 
    }

    [MenuItem("TA/Assets/打包PC", false, 351)]
    public static void PackAndroidPC()
    {
        BuildTarget target = BuildTarget.StandaloneWindows;
        MarkAssetName();
        BuildBundle(target);

    }


    class AssetBuildBundleInfo
    {
        public string fileName;
        public string assetName;
        public string bundleName;
        public List<string> dependencies;

        public void AddDependence(string dep)
        {
            if (dependencies == null)
            {
                dependencies = new List<string>();
            }
            dependencies.Add(dep);
        }
    }
    //public static List<string> bundleList

    public static void BuildBundle(BuildTarget target)
    {
        // 清理之前设置过的bundleName

        CreateOrClearOutPath(target);
        BuildPipeline.BuildAssetBundles(GetBuildDir(target), BuildAssetBundleOptions.DeterministicAssetBundle, target);
        AssetDatabase.Refresh();

    }

    public class AssetBundleData
    {
        public string name;
        public string path;
    }
    Dictionary<string, AssetBundleData> assetBundleDatas = new Dictionary<string, AssetBundleData>();
    /// <summary>
    /// 设置AssetBundleName
    /// </summary>
    /// <param name="fullpath">Fullpath.</param>
    public static void setAssetBundleName(string fullPath, string subPath)
    {

        string[] files = System.IO.Directory.GetFiles(subPath);
        if (files == null || files.Length == 0)
        {
            return;
        }

        Debug.Log("Set AssetBundleName Start......");
        string dirBundleName = subPath.Replace("/", "@");
        dirBundleName = dirBundleName.Replace("\\", "@");
        if (dirBundleName.EndsWith("@"))
        {
            dirBundleName = dirBundleName.Substring(0, dirBundleName.Length - 1);
        }
        //dirBundleName  += ASSET_BUNDLE_SUFFIX;
        foreach (string file in files)
        {
            if (file.EndsWith(".meta"))
            {
                continue;
            }
            AssetImporter importer = AssetImporter.GetAtPath(file);
            if (importer != null)
            {
                string ext = System.IO.Path.GetExtension(file);
                string bundleName = dirBundleName;
                if (null != ext && (
                    ext.Equals(".prefab")
                    || ext.Equals(".unity")
                    //|| ext.Equals(".mat")
                    ))
                {
                    /*if (ext.Equals(".mat"))
                    {
                        Debug.Log("here");
                    }*/
                    bundleName = file;
                }
                else
                {
                    //bundleName = fullPath;
                    bundleName = dirBundleName;
                }
                bundleName += ASSET_BUNDLE_SUFFIX;
                bundleName = bundleName.Replace("/", "@");
                bundleName = bundleName.Replace("\\", "@");
                bundleName = bundleName.ToLower();
                Debug.LogFormat("Set AssetName Succ, File:{0}, AssetName:{1}", file, bundleName);
                importer.assetBundleName = bundleName;
                EditorUtility.UnloadUnusedAssetsImmediate();


            }
            else
            {
                Debug.LogFormat("Set AssetName Fail, File:{0}, Msg:Importer is null", file);
            }
        }
        Debug.Log("Set AssetBundleName End......");


    }



    /// <summary>
	/// 获取所有资源目录
	/// </summary>
	/// <returns>The res all dir path.</returns>
	public static List<string> GetAllResDirs(string fullPath)
    {
        List<string> dirList = new List<string>();

        // 获取所有子文件
        GetAllSubResDirs(fullPath, dirList);

        return dirList;
    }

    /// <summary>
    /// 递归获取所有子目录文件夹
    /// </summary>
    /// <param name="fullPath">当前路径</param>
    /// <param name="dirList">文件夹列表</param>
    public static void GetAllSubResDirs(string fullPath, List<string> dirList)
    {
        if ((dirList == null) || (string.IsNullOrEmpty(fullPath)))
            return;

        string[] dirs = System.IO.Directory.GetDirectories(fullPath);
        if (dirs != null && dirs.Length > 0)
        {
            for (int i = 0; i < dirs.Length; ++i)
            {
                GetAllSubResDirs(dirs[i], dirList);
            }
        }
        else
        {
            dirList.Add(fullPath);
        }
    }


}
