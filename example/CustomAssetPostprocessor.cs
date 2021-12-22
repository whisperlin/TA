using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Reflection;

/*
1.贴图文件、图集最大1024*1024，只能使用textureSet内图片格式（），避免输出问题引起图片大小异常，控制图片文件大小为10M以下
2.放在UI图集文件夹会改为sprite，放在Imge文件夹会改为default
3.模型动作自动改名，idle动作不压缩，Gpu蒙皮使用ModelImporterAnimationType.Legacy
4.大地图士兵面数1000，武将面数1500，建筑面数2000，主城面数5000

*/

//todo 带aplha的和不带aplha分图集放置
public class CustomAssetPostprocessor : AssetPostprocessor
{
    public static List<string> atlasPath = new List<string>() { "/Atlas/","/RawAtlas/" };
    public static List<string> imagePath = new List<string>() { "/Image/", "/RawImage/" };
    //UI资源预处理阔免文件夹，样例 Assets/Res/Map/
    public static HashSet<string> dontChangeSet = new HashSet<string>() {
        "/Scene/"
    };
    public static HashSet<string> textureSet = new HashSet<string>() {
        ".png",".tga",".hdr",".exr",".jpg"
    };

    public static HashSet<string> dontOverride = new HashSet<string>() {
        "Assets/Res/Map/T4M","Assets/Res/Map_1/T4M","Assets/Res/PVESceneSource/T4M","Assets/Res/Model/ShowModel/LightingData","/Ro_CubeMap/"
    };

    public static long maxTextureFileSize = 1024 * 1024 * 10;

    public void OnPostprocessTexture(Texture2D texture)
    {
        for (int i = 0; i < atlasPath.Count; i++)
        {
            if (this.assetPath.Contains(atlasPath[i]))
            {
                if (texture != null && (texture.width > 1024 || texture.height > 1024))
                {
                    Debug.LogError(assetPath + " 该文件长或宽超出1024，不该放进图集");
                    UnityEditor.EditorUtility.DisplayDialog("这文件超大", assetPath + " 该文件长或宽超出1024，不该放进图集", "确认", "取消");
                }
                return;
            }
        }
    }
    
    //纹理导入前
    public void OnPreprocessTexture()
    {
        TextureImporter textureImporter = (TextureImporter)assetImporter;
        var pngName = assetPath.ToLower();
        if (!assetPath.StartsWith("Assets/Res"))
        {
            Debug.Log(assetPath + " 非Assets/Res中的资源暂不处理");
            return;
        }
        if (!textureSet.Contains(Path.GetExtension(pngName)))
        {
            Debug.LogError(assetPath + " 禁止使用非.png .tga .hdr .exr贴图");
            UnityEditor.EditorUtility.DisplayDialog("禁止使用dds贴图", assetPath + " 禁止使用非.png，.tga贴图，请删除该贴图", "确认", "取消");
            return;
        }

        FileInfo fileInfo = new FileInfo(assetPath);
        if (fileInfo.Length > maxTextureFileSize && !assetPath.Contains("Hero_10001"))
        {
            Debug.LogError(assetPath + " 该文件大小超出10M，请检查输出设置,并重新导入");
            UnityEditor.EditorUtility.DisplayDialog("这文件超大", assetPath + " 该文件大小超出10M，请检查输出设置,并重新导入", "确认", "取消");
            return;
        }
        if (assetPath.Contains("Assets/Res/PVESceneSource/T4MTerrains"))
        {
            textureImporter.sRGBTexture = false;
            return;
        }
        if (assetPath.Contains("Assets/Res/Map/T4M"))
        {
            if (assetPath.Contains("_BlendTex"))
            {
                textureImporter.mipmapEnabled = true;
                textureImporter.sRGBTexture = false;
            }
            else if (assetPath.Contains("_IndexTex"))
            {
                textureImporter.sRGBTexture = false;
                textureImporter.mipmapEnabled = false;
            }
            var androidSetting1 = textureImporter.GetPlatformTextureSettings("Android");
            if (!androidSetting1.overridden)
            {
                androidSetting1.overridden = true;
                if (assetPath.Contains("_BlendTex"))
                {
                    androidSetting1.format = TextureImporterFormat.ASTC_4x4;
                }
                else if (assetPath.Contains("_IndexTex"))
                {
                    androidSetting1.format = TextureImporterFormat.R8;
                }
                
                textureImporter.SetPlatformTextureSettings(androidSetting1);
            }
            var iOSSetting1 = textureImporter.GetPlatformTextureSettings("iPhone");
            if (!iOSSetting1.overridden)
            {
                iOSSetting1.overridden = true;
                if (assetPath.Contains("_BlendTex"))
                {
                    iOSSetting1.format = textureImporter.DoesSourceTextureHaveAlpha() ? TextureImporterFormat.PVRTC_RGBA4 : TextureImporterFormat.PVRTC_RGB4;
                }
                else if (assetPath.Contains("_IndexTex"))
                {
                    iOSSetting1.format = TextureImporterFormat.R8;
                }
                textureImporter.SetPlatformTextureSettings(iOSSetting1);
            }
            return;
        }
        foreach (var item in dontOverride)
        {
            if (assetPath.Contains(item))
            {
                Debug.Log(string.Format("该文件已过滤 请手动设置属性 {0}", assetPath));
                return;
            }
        }
        //if (assetPath.EndsWith(".hdr"))
        //{
        //    textureImporter.mipmapEnabled = false;
        //}
        var androidSetting = textureImporter.GetPlatformTextureSettings("Android");
        if (!androidSetting.overridden)
        {
            androidSetting.overridden = true;
            androidSetting.format = TextureImporterFormat.ASTC_6x6;
            if(assetPath.Contains("Assets/Res/Model/MapModel")) androidSetting.maxTextureSize = 256;
            textureImporter.SetPlatformTextureSettings(androidSetting);
        }
        var iOSSetting = textureImporter.GetPlatformTextureSettings("iPhone");
        if (!iOSSetting.overridden)
        {
            iOSSetting.overridden = true;
            iOSSetting.format = textureImporter.DoesSourceTextureHaveAlpha()?TextureImporterFormat.PVRTC_RGBA4: TextureImporterFormat.PVRTC_RGB4;
            if (assetPath.Contains("Assets/Res/Model/MapModel")) iOSSetting.maxTextureSize = 256;
            textureImporter.SetPlatformTextureSettings(iOSSetting);
        }

        foreach (var item in dontChangeSet)
        {
            if (assetPath.Contains(item))
            {
                Debug.Log(string.Format("该文件已过滤 请手动设置属性 {0}", assetPath));
                return;
            }
        }
        //if (FileFilterWindow.IsFilter(assetPath))
        //{
        //    Debug.Log(string.Format("该文件已过滤 请手动设置属性 {0}", assetPath));
        //    return;
        //}

        for (int i = 0; i < atlasPath.Count; i++)
        {
            if (this.assetPath.Contains(atlasPath[i]))
            {
                textureImporter.textureType = TextureImporterType.Sprite;
                if (!assetPath.EndsWith(".png"))
                {
                    Debug.LogError("UI只能使用.png图片：" + assetPath);
                    return;
                }
                Debug.Log("初始化图片资源成功：" + assetPath);
                return;
            }
        }
        for (int i = 0; i < imagePath.Count; i++)
        {
            if (this.assetPath.Contains(imagePath[i]))
            {
                textureImporter.textureType = TextureImporterType.Default;
                textureImporter.mipmapEnabled = false;
                //textureImporter.npotScale = TextureImporterNPOTScale.ToNearest;
                //textureImporter.wrapMode = TextureWrapMode.Clamp;
                textureImporter.isReadable = false;
                if (!assetPath.EndsWith(".png"))
                {
                    Debug.LogError("UI只能使用.png图片：" + assetPath);
                    return;
                }
                Debug.Log("初始化图片资源成功：" + assetPath);
                return;
            }
        }
    }

    //模型导入之前调用
    public void OnPreprocessModel()
    {
        
    }

    public void OnPostprocessModel(GameObject gameObject)
    {
        ModelImporter modelImporter = this.assetImporter as ModelImporter;
        modelImporter.materialImportMode = ModelImporterMaterialImportMode.None;
        modelImporter.importLights = false;
        modelImporter.importCameras = false;
        //顶点数统计
        var renders = gameObject.GetComponentsInChildren<SkinnedMeshRenderer>();
        int count = 0;
        for (int i = 0; i < renders.Length; i++)
        {
            count += renders[i].sharedMesh.triangles.Length;
        }
        var filters = gameObject.GetComponentsInChildren<MeshFilter>();
        for (int i = 0; i < filters.Length; i++)
        {
            count += filters[i].sharedMesh.triangles.Length;
        }
        //改用@动作名处理
        if (count == 0 && !assetPath.Contains("Temp"))
        {
            //动画自动改名
            var fileName = Path.GetFileNameWithoutExtension(assetPath);
            var defaultClipAnimations = modelImporter.clipAnimations.Length > 0 ? modelImporter.clipAnimations : modelImporter.defaultClipAnimations;
            if (fileName == "Idle")
            {
                modelImporter.animationCompression = ModelImporterAnimationCompression.Off;
            }
            if (defaultClipAnimations.Length == 1 && defaultClipAnimations[0].name != fileName)
            {
                defaultClipAnimations[0].name = fileName;
                defaultClipAnimations[0].takeName = fileName;
                modelImporter.clipAnimations = defaultClipAnimations;
                modelImporter.SaveAndReimport();
                Debug.Log(assetPath + " 初始化动画成功");
            }
        }
        count = Mathf.CeilToInt(count/3);
        if (assetPath.Contains("Model/MapModel/"))
        {
            if (Path.GetFileNameWithoutExtension(assetPath) == "Skin")
            {
                modelImporter.importAnimation = false;
            }
            else
            {
                modelImporter.importAnimation = true;
            }
            modelImporter.animationType = ModelImporterAnimationType.Legacy;
        }
        if (assetPath.Contains("Model") && ((assetPath.Contains("MapModel") || assetPath.Contains("Building"))))
        {
            if (assetPath.Contains("MapModel") )
            {
                var name = Path.GetFileNameWithoutExtension(assetPath);
                var sId = name.Replace("MapModel_", "");
                int id;
                if(int.TryParse(sId, out id))
                {
                    if (id>1000 && id <10000 && count > 1000)
                    {
                        Debug.LogError(assetPath + " 士兵模型面数:" + count + ", 超出1000，请美术修改资源");
                    }
                    else if (id > 10000 && count > 1500)
                    {
                        Debug.LogError(assetPath + " 武将模型面数:" + count + ", 超出1500，请美术修改资源");
                        return;
                    }
                }
            }
            else if (assetPath.Contains("Building") && count > 2000)
            {
                Debug.LogError(assetPath + " 建筑模型面数:" + count + ", 超出2000，请美术修改资源");
                return;
            }
            else
            {

            }
        }
        Debug.Log(assetPath + " 初始化模型资源成功，总顶点数:" + count);
    }

    public void OnPreprocessAudio()
    {
        AudioImporter audioImporter = this.assetImporter as AudioImporter;
        audioImporter.forceToMono = true;
        audioImporter.loadInBackground = true;
        AudioImporterSampleSettings audioImporterSampleSettings = audioImporter.defaultSampleSettings;
        //audioImporterSampleSettingsIOS.quality = .8f;
        //audio. = AudioCompressionFormat.MP3;
        if (assetPath.Contains("/BGM/"))
        {
            audioImporterSampleSettings.loadType = AudioClipLoadType.CompressedInMemory;
        }
        else if (assetPath.Contains("/Effect/"))
        {
            audioImporterSampleSettings.loadType = AudioClipLoadType.DecompressOnLoad;
        }
        audioImporter.defaultSampleSettings = audioImporterSampleSettings;
        Debug.Log("初始化音频资源成功：" + assetPath);
    }

    //所有的资源的导入，删除，移动，都会调用此方法，注意，这个方法是static的
    public static void OnPostprocessAllAssets(string[] importedAsset, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
    {
        foreach (string str in movedAssets)
        {
            for (int i = 0; i < atlasPath.Count; i++)
            {
                if (str.Contains(atlasPath[i]))
                {
                    AssetDatabase.ImportAsset(str);
                }
            }
            for (int i = 0; i < imagePath.Count; i++)
            {
                if (str.Contains(imagePath[i]))
                {
                    AssetDatabase.ImportAsset(str);
                }
            }
        }
    }}