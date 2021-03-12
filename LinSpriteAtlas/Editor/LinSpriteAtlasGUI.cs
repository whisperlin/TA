//指定类型
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

 
[CustomPropertyDrawer(typeof(FolderReference))]
public class FolderReferencePropertyDrawer : PropertyDrawer
{
 
    private SerializedProperty guid;
    private Object obj;

    private void Init(SerializedProperty property)
    {
 
        guid = property.FindPropertyRelative("GUID");
        obj = AssetDatabase.LoadAssetAtPath<Object>(AssetDatabase.GUIDToAssetPath(guid.stringValue));
    }

    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
         Init(property);
        if(null!=obj)
            label.text = obj.name;
        GUIContent guiContent = EditorGUIUtility.ObjectContent(obj, typeof(DefaultAsset));

        Rect r = EditorGUI.PrefixLabel(position, label);
        
        Rect textFieldRect = r;
        textFieldRect.width -= 19f;

        GUIStyle textFieldStyle = new GUIStyle("TextField")
        {
            imagePosition = obj ? ImagePosition.ImageLeft : ImagePosition.TextOnly
        };

        if (GUI.Button(textFieldRect, guiContent, textFieldStyle) && obj)
            EditorGUIUtility.PingObject(obj);

        if (textFieldRect.Contains(Event.current.mousePosition))
        {
            if (Event.current.type == EventType.DragUpdated)
            {
                Object reference = DragAndDrop.objectReferences[0];
                string path = AssetDatabase.GetAssetPath(reference);
                DragAndDrop.visualMode = Directory.Exists(path) ? DragAndDropVisualMode.Copy : DragAndDropVisualMode.Rejected;
                Event.current.Use();
            }
            else if (Event.current.type == EventType.DragPerform)
            {
                Object reference = DragAndDrop.objectReferences[0];
                string path = AssetDatabase.GetAssetPath(reference);
                if (Directory.Exists(path))
                {
                    obj = reference;
                    guid.stringValue = AssetDatabase.AssetPathToGUID(path);
                }
                Event.current.Use();
            }
        }

        Rect objectFieldRect = r;
        objectFieldRect.x = textFieldRect.xMax + 1f;
        objectFieldRect.width = 19f;

        if (GUI.Button(objectFieldRect, "", GUI.skin.GetStyle("IN ObjectField")))
        {
            string path = EditorUtility.OpenFolderPanel("Select a folder", "Assets", "");
            if (path.Contains(Application.dataPath))
            {
                path = "Assets" + path.Substring(Application.dataPath.Length);
                obj = AssetDatabase.LoadAssetAtPath(path, typeof(DefaultAsset));
                guid.stringValue = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(obj));
            }
            else Debug.LogError("The path must be in the Assets folder");
        }
    }
}
public class MyTextureData
{
    public Texture2D tex;
    public string path;

    public SpriteMetaData [] spritesheet ;
    public Vector2 offset;
}

[CustomEditor(typeof(LinSpriteAtlas))]
public class LinSpriteAtlasGUI : Editor
{
 

    void OnEnable()
    {
        
    }

    public Texture2D ReadTexture(Texture2D t)
    {
        RenderTexture rt =  RenderTexture.GetTemporary(t.width, t.height, 16);
        Graphics.Blit(t, rt);

        Texture2D t2 = new Texture2D(t.width, t.height, TextureFormat.RGBA32, false);
        RenderTexture.active = rt;
        t2.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);

        return t2;
    }

    public override void OnInspectorGUI()
    {
        LinSpriteAtlas textureData = (LinSpriteAtlas)target;
 

        base.OnInspectorGUI();

        if (GUILayout.Button("生成"))
        {
            
            string texturePath = AssetDatabase.GetAssetPath(target);
            if (textureData.texture != null)
            {
                texturePath = AssetDatabase.GetAssetPath(textureData.texture);
            }
            else
            {
                texturePath = texturePath.Substring(0, texturePath.Length - 5) + "png";
            }
            HashSet<string> paths = new HashSet<string>();
            foreach (var _folder in textureData.folders)
            {
                if (null != _folder&& _folder.Path.Length>0)
                {

                    {
                        string[] _paths = System.IO.Directory.GetFiles(_folder.Path, "*.png", SearchOption.AllDirectories);
                        foreach (var s in _paths)
                        {
                            paths.Add(s.Replace('\\', '/'));
                        }
                    }
                    {
                        string[] _paths = System.IO.Directory.GetFiles(_folder.Path, "*.tga", SearchOption.AllDirectories);
                        foreach (var s in _paths)
                        {
                            paths.Add(s.Replace('\\', '/'));
                        }
                    }
                    {
                        string[] _paths = System.IO.Directory.GetFiles(_folder.Path, "*.jpg", SearchOption.AllDirectories);
                        foreach (var s in _paths)
                        {
                            paths.Add(s.Replace('\\', '/'));
                        }
                    }
                }
            }
            Texture2D png = new Texture2D(2048, 2048,TextureFormat.RGBA32, false);
            for(int i = 0; i < png.width;i++)
            {
                for (int j = 0; j < png.height; j++)
                {
                    png.SetPixel(i, j, new Color(0, 0, 0, 0));
                }
            }
            png.Apply();
            //RenderTexture rt = new RenderTexture(2048, 2048, 16,RenderTextureFormat.ARGB32);


            Pack2d.Packer packer = new Pack2d.Packer();
            //List<Pack2d.Box> boxes = new List<Pack2d.Box>();
            foreach (var path in paths)
            {

                Object[] datas = AssetDatabase.LoadAllAssetsAtPath(path);
                
                Texture2D baseTex = null ;
             
               
                foreach (Object o in datas)
                {
                     
                    if(o is UnityEngine.Texture2D)
                    {
                        baseTex = (Texture2D)o;
                    }
                }
                if (  null != baseTex)
                {
                    string p0 = AssetDatabase.GetAssetPath(baseTex);
                    TextureImporter _importer = (TextureImporter)TextureImporter.GetAtPath(p0);

                    if (_importer.textureType == TextureImporterType.Sprite)
                    {
                        Pack2d.Box box = new Pack2d.Box { width = baseTex.width + 2, height = baseTex.height + 2 };
                        MyTextureData _data = new MyTextureData();
                        _data.tex = baseTex;

                        _data.path = p0;
                        _data.spritesheet = new SpriteMetaData[_importer.spritesheet.Length];
                        for (int i = 0; i < _importer.spritesheet.Length; i++)
                        {
                            _data.spritesheet[i] = _importer.spritesheet[i];
                        }

                        box.userData = _data;
                        packer.Add(box);
                    }
                    
                }
                
            }
            //var err  = packer.Pack(2048);
            var err = packer.Pack2(2048);
            if (err.Count>0)
            {
                 
                EditorUtility.DisplayDialog("", err.Count.ToString()+"张贴图贴图放不下", "确定");
                foreach (var b in err)
                {
                    MyTextureData ud = (MyTextureData)b.userData;
                    Debug.LogError(" "+b.width + ","+b.height + " "+ ud.path);
                }

            }
             
  
            foreach (Pack2d.Box box in packer.GetBoxs())
            {
                MyTextureData _data = (MyTextureData)box.userData;
                _data.offset = new Vector2(box.position.pos_x+1,box.position.pos_y+1);
                var _tex = _data.tex;

                _tex = ReadTexture(_tex);
                for (int i = 0; i < _tex.width; i++)
                {
                    for (int j = 0; j < _tex.height; j++)
                    {
                        Color c = _tex.GetPixel(i, j);
                        png.SetPixel(i + (int)(_data.offset.x) , j + (int)(_data.offset.y), _tex.GetPixel(i,j));
                    }
                }
                GameObject.DestroyImmediate(_tex);
            }

            byte[] bytes = png.EncodeToPNG();
 
            System.IO.File.WriteAllBytes(texturePath, bytes);
            
            AssetDatabase.ImportAsset(texturePath);

            textureData.texture = AssetDatabase.LoadAssetAtPath<Texture2D>(texturePath);

            TextureImporter importer = (TextureImporter)TextureImporter.GetAtPath(texturePath);
            importer.alphaIsTransparency = true;
            importer.textureType = TextureImporterType.Sprite;
            importer.spriteImportMode = SpriteImportMode.Multiple;


            List<SpriteMetaData> spritesheetMeta = new List<SpriteMetaData>();

            foreach (Pack2d.Box box in packer.GetBoxs())
            {
                MyTextureData _data = (MyTextureData)box.userData;
                for (int i = 0; i < _data.spritesheet.Length; i++)
                {
                    SpriteMetaData currentMeta = _data.spritesheet[i];
                    Rect _rect = currentMeta.rect;
                    _rect.x += _data.offset.x;
                    _rect.y += _data.offset.y;
                    currentMeta.rect = _rect;
                    spritesheetMeta.Add(currentMeta);
                }

              

            }
             
            importer.spritesheet = spritesheetMeta.ToArray();

            importer.SaveAndReimport();
        }
    }
}

 