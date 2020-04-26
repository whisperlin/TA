using UnityEditor;

public class CreateAssetBundles
{
    [MenuItem("TA/Build AssetBundles")]
    static void BuildAllAssetBundles()
    {
        BuildPipeline.BuildAssetBundles("Assets/StreamingAssets/StandaloneWindows", BuildAssetBundleOptions.DeterministicAssetBundle, BuildTarget.StandaloneWindows);
    }
} 
 