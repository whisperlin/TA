using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[System.Serializable]
public class FolderReference
{
    public string GUID;
#if  UNITY_EDITOR
    public string Path => AssetDatabase.GUIDToAssetPath(GUID);
#endif
}

 
[CreateAssetMenu(fileName = "LSpriteAtlas", menuName = "Lin/SpriteAtlas", order = 1)]
public class LinSpriteAtlas : ScriptableObject
{
    
    public FolderReference [] folders;

    public Texture2D texture;
}
 