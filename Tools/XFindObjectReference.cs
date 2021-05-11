using UnityEngine;
using System.Collections;
using UnityEditor;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;

public class XFindObjectReference : EditorWindow
{
    struct ABAndTag
    {
        public string abName;
        public string tagName;
    }



    private static XFindObjectReference _sWin;

    private string _fliterStr = "";
    private string _abNameStr = "";
    private string _spritePackingTagStr = "";

    private List<string> _pathList;
    private Dictionary<int,string> _recyleList;
    private Dictionary<int, ABAndTag> _oldAbAndTags;

    private int _resourceCount = 0;
    private static string _selectObjName = "";

    private Vector2 scrollPosition;

    private void OnEnable()
    {
        Clear();
    }

    public void Clear()
    {
        _selectObjName = "";
        _fliterStr = "";
        _resourceCount = 0;
        _pathList = new List<string>();
        _recyleList = new Dictionary<int, string>();
        _oldAbAndTags = new Dictionary<int, ABAndTag>();
    }

    private void OnDestory()
    {
        Debug.Log("-----------------------destory");
        Clear();
    }

    private void OnSelectionChange()
    {
        if (_sWin)
        {
            string path = AssetDatabase.GetAssetPath(Selection.activeObject);
            if (path.IndexOf("BundleResources/UI") > -1 && path.IndexOf(".prefab") > -1)
            {
                _sWin.Clear();
                _selectObjName = Selection.activeObject.name;
                _sWin._abNameStr = "ui/uiatlas/" + _selectObjName.ToLower() + ".k";
                _sWin._spritePackingTagStr = _selectObjName;
                _sWin.Repaint();
            }
            
        }
    }

    private void OnGUI()
    {
        GUILayout.Space(5);
        _fliterStr = EditorGUILayout.TextField("打包的文件夹:", _fliterStr);
        GUILayout.Space(5);
        _abNameStr = EditorGUILayout.TextField("AB Name:", _abNameStr);
        GUILayout.Space(5);
        _spritePackingTagStr = EditorGUILayout.TextField("SpritePacking Tag:", _spritePackingTagStr);
        GUILayout.Space(10);
        GUILayout.BeginHorizontal();
        if (GUILayout.Button("预览打包资源"))
        {
            PreShowResource();
        }

        if (GUILayout.Button("打包资源"))
        {
            BuildResourceABAndTag();
        }
        GUILayout.EndHorizontal();

        _resourceCount = GetPathCount();
        GUILayout.Space(10);
        GUILayout.Label("打包资源列表："+ _resourceCount);
        GUILayout.Space(5);
        scrollPosition = GUILayout.BeginScrollView(scrollPosition);
        for (int i = 0; i < _pathList.Count; i++)
        {
            GUILayout.BeginHorizontal();

            
            string tagStr = "";
            string abStr = "";
            if (!string.IsNullOrEmpty(_pathList[i]))
            {
                AssetImporter assetImporter = AssetImporter.GetAtPath(_pathList[i]);
                TextureImporter textureImporter = assetImporter as TextureImporter;
                if (textureImporter != null)
                {
                    tagStr = textureImporter.spritePackingTag;
                    abStr = textureImporter.assetBundleName;
                }

                Texture t2d = AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(_pathList[i])) as Texture;
                if (t2d != null)
                {
                    if (t2d.width > 1024 || t2d.height > 1024)
                    {
                        GUIStyle style = new GUIStyle();
                        style.normal.textColor = Color.red;
                        EditorGUILayout.LabelField(_pathList[i], style);
                    }
                    else
                    {
                        EditorGUILayout.LabelField(_pathList[i]);
                    }
                }
            }
            else
            {
                EditorGUILayout.LabelField(_pathList[i]);
            }

            tagStr = GUILayout.TextField(tagStr,GUILayout.Width(120));
            abStr = GUILayout.TextField(abStr, GUILayout.Width(200));
            if (!_oldAbAndTags.ContainsKey(i))
            {
                ABAndTag abTag = new ABAndTag();
                abTag.abName = abStr;
                abTag.tagName = tagStr;
                _oldAbAndTags.Add(i,abTag);
            }
            else
            {
                ABAndTag abAndTag = _oldAbAndTags[i];
                abAndTag.abName = abStr;
                abAndTag.tagName = tagStr;
                _oldAbAndTags[i] = abAndTag;
            }

            if (GUILayout.Button("查看资源", GUILayout.Width(60)))
            {
                if (!string.IsNullOrEmpty(_pathList[i]))
                {
                    Selection.activeObject = AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(_pathList[i]));
                }
            }

            if (GUILayout.Button("确认修改", GUILayout.Width(60)))
            {
                if (!string.IsNullOrEmpty(_pathList[i]))
                {
                    AssetImporter assetImporter = AssetImporter.GetAtPath(_pathList[i]);
                    TextureImporter textureImporter = assetImporter as TextureImporter;
                    if (textureImporter != null)
                    {
                        ABAndTag abAndTag = _oldAbAndTags[i];
                        textureImporter.textureType = TextureImporterType.Sprite;
                        textureImporter.spritePackingTag = abAndTag.tagName;
                        textureImporter.mipmapEnabled = false;
                        textureImporter.SetAssetBundleNameAndVariant(abAndTag.abName, "");
                        //                    textureImporter.assetBundleName = abStr;
                        //Debug.Log("abName:"+ abStr+"__ tag:"+ tagStr);
                        Debug.Log("set packingTag::" + _pathList[i], AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(_pathList[i])));
                        EditorUtility.SetDirty(assetImporter);
                        textureImporter.SaveAndReimport();
                        AssetDatabase.Refresh();
                    }
                }
            }

            if (GUILayout.Button("清除路径", GUILayout.Width(60)))
            {
                if (!string.IsNullOrEmpty(_pathList[i]))
                {
                    string p = _pathList[i];
                    if (!_recyleList.ContainsKey(i))
                    {
                        _recyleList.Add(i, p);
                    }
                    _pathList[i] = "";
                }
                else
                {
                    if (_recyleList.ContainsKey(i))
                    {
                        _pathList[i] = _recyleList[i];
                        _recyleList.Remove(i);
                    }
                }
                //Repaint();
            }
            GUILayout.EndHorizontal();
        }
        GUILayout.Space(15);
        GUILayout.EndScrollView();
    }

    private int GetPathCount()
    {
        int result = 0;
        for (int i = 0; i < _pathList.Count; i++)
        {
            if (!string.IsNullOrEmpty(_pathList[i]))
            {
                result += 1;
            }
        }
        return result;
    }

    private void PreShowResource()
    {
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (!string.IsNullOrEmpty(path))
        {
            string[] paths = AssetDatabase.GetDependencies(path);
            //Debug.Log("dependencies count::" + paths.Length);
            for (int i = 0; i < paths.Length; i++)
            {
                string str = paths[i];

                if (str.IndexOf(".png") > -1 || str.IndexOf(".jpg") > -1)
                {
                    //Debug.Log("dependence resource::" + str, AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(paths[i])));
                    if (str.IndexOf("UI/UIAtlas/UI") > -1)
                    {
                        if (!(str.IndexOf("UI/UIAtlas/UI/A0-public") > -1))
                        {
                            if (!string.IsNullOrEmpty(_fliterStr))
                            {
                                if (str.IndexOf(_fliterStr) > -1)
                                {
                                    _pathList.Add(str);
                                }
                                else
                                {
                                    Debug.Log("in diffienent folder::" + paths[i], AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(paths[i])));
                                }
                            }
                            else
                            {
                                _pathList.Add(str);
                            }
                        }
                    }
                }
            }
        }
    }

    private void BuildResourceABAndTag()
    {
        for (int i = 0; i < _pathList.Count; i++)
        {
            string str = _pathList[i];
            if (!string.IsNullOrEmpty(str))
            {
                AssetImporter assetImporter = AssetImporter.GetAtPath(str);
                TextureImporter textureImporter = assetImporter as TextureImporter;
                if (textureImporter != null)
                {
                    textureImporter.textureType = TextureImporterType.Sprite;
                    string tagStr = (!string.IsNullOrEmpty(_spritePackingTagStr)) ? _spritePackingTagStr : _selectObjName;
                    textureImporter.spritePackingTag = tagStr;
                    textureImporter.mipmapEnabled = false;
                    string abStr = (!string.IsNullOrEmpty(_abNameStr)) ? _abNameStr : ("ui/uiatlas/" + _selectObjName.ToLower() + ".k");
                    textureImporter.SetAssetBundleNameAndVariant(abStr,"");
//                    textureImporter.assetBundleName = abStr;
                    //Debug.Log("abName:"+ abStr+"__ tag:"+ tagStr);
                    Debug.Log("set packingTag::" + str, AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(str)));
                    EditorUtility.SetDirty(assetImporter);
                    textureImporter.SaveAndReimport();
                }
            }
        }
        AssetDatabase.Refresh();
    }


    [MenuItem("Window/Set AB And Tag %m")]
    static private void AutoSetObjectPackingTag()
    {
        if (_sWin == null)
        {
            _sWin = (XFindObjectReference)EditorWindow.GetWindow<XFindObjectReference>();
            _sWin.Show();
        }
        else
        {
            _sWin.Clear();
            _sWin.Repaint();
        }

//        _selectObjName = Selection.activeObject.name;
//        _sWin._abNameStr = "ui/uiatlas/" + _selectObjName + ".k";
//        _sWin._spritePackingTagStr = _selectObjName;
    }


    [MenuItem("Assets/Find Object References(BundleResources)", false, 10)]
    static private void Find()
    {
        EditorSettings.serializationMode = SerializationMode.ForceText;
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (!string.IsNullOrEmpty(path))
        {
            string guid = AssetDatabase.AssetPathToGUID(path);
            List<string> withoutExtensions = new List<string>() { ".prefab",".unity",".mat" };
            string[] files = Directory.GetFiles(Application.dataPath+"/BundleResources/", "*.*", SearchOption.AllDirectories)
                .Where(s => withoutExtensions.Contains(Path.GetExtension(s).ToLower())).ToArray();
            int startIndex = 0;

            EditorApplication.update = delegate ()
            {
                string file = files[startIndex];

                bool isCancel = EditorUtility.DisplayCancelableProgressBar("匹配资源中", file, (float)startIndex / (float)files.Length);

                string fileText = File.ReadAllText(file);
                if (Regex.IsMatch(fileText, guid))
                {
                    Debug.Log(file, AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(file)));
                }

                

                startIndex++;
                if (isCancel || startIndex >= files.Length)
                {
                    EditorUtility.ClearProgressBar();
                    EditorApplication.update = null;
                    startIndex = 0;
                    Debug.Log("匹配结束");
                }

            };
        }
    }

    [MenuItem("Assets/Find Object References(UI)", false, 10)]
    static private void FindUI()
    {
        EditorSettings.serializationMode = SerializationMode.ForceText;
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (!string.IsNullOrEmpty(path))
        {
            string guid = AssetDatabase.AssetPathToGUID(path);
            List<string> withoutExtensions = new List<string>() { ".prefab", ".unity", ".mat" };
            string[] files = Directory.GetFiles(Application.dataPath + "/BundleResources/UI/", "*.*", SearchOption.AllDirectories)
                .Where(s => withoutExtensions.Contains(Path.GetExtension(s).ToLower())).ToArray();
            int startIndex = 0;

            EditorApplication.update = delegate ()
            {
                string file = files[startIndex];

                bool isCancel = EditorUtility.DisplayCancelableProgressBar("匹配资源中", file, (float)startIndex / (float)files.Length);

                string fileText = File.ReadAllText(file);
                if (Regex.IsMatch(fileText, guid))
                {
                    Debug.Log(file, AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(file)));
                }



                startIndex++;
                if (isCancel || startIndex >= files.Length)
                {
                    EditorUtility.ClearProgressBar();
                    EditorApplication.update = null;
                    startIndex = 0;
                    Debug.Log("匹配结束");
                }

            };
        }
    }

    [MenuItem("Assets/Find Shader References(all material)", false, 10)]
    static private void FindShaderReferences()
    {
        EditorSettings.serializationMode = SerializationMode.ForceText;
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (!string.IsNullOrEmpty(path))
        {
            string guid = AssetDatabase.AssetPathToGUID(path);
            List<string> withoutExtensions = new List<string>() {".mat" };
            string[] files0 = Directory.GetFiles(Application.dataPath + "/Art/", "*.*", SearchOption.AllDirectories)
                .Where(s => withoutExtensions.Contains(Path.GetExtension(s).ToLower())).ToArray();

            string[] files1 = Directory.GetFiles(Application.dataPath + "/BundleResources/", "*.*", SearchOption.AllDirectories)
                .Where(s => withoutExtensions.Contains(Path.GetExtension(s).ToLower())).ToArray();

            int count = files0.Length + files1.Length;
            string[] files = new string[count];
            int idx = 0;
            files0.CopyTo(files,idx);
            idx += files0.Length;
            files1.CopyTo(files,idx);

            int startIndex = 0;

            EditorApplication.update = delegate ()
            {
                string file = files[startIndex];

                bool isCancel = EditorUtility.DisplayCancelableProgressBar("匹配资源中", file, (float)startIndex / (float)files.Length);

                string fileText = File.ReadAllText(file);
                if (Regex.IsMatch(fileText, guid))
                {
                    Debug.Log(file, AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(file)));
                }



                startIndex++;
                if (isCancel || startIndex >= files.Length)
                {
                    EditorUtility.ClearProgressBar();
                    EditorApplication.update = null;
                    startIndex = 0;
                    Debug.Log("匹配结束");
                }

            };
        }
    }

    [MenuItem("Assets/Find Object References(Art)", false, 10)]
    static private void FindArt()
    {
        EditorSettings.serializationMode = SerializationMode.ForceText;
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (!string.IsNullOrEmpty(path))
        {
            string guid = AssetDatabase.AssetPathToGUID(path);
            List<string> withoutExtensions = new List<string>() { ".prefab", ".unity", ".mat" };
            string[] files = Directory.GetFiles(Application.dataPath + "/Art/", "*.*", SearchOption.AllDirectories)
                .Where(s => withoutExtensions.Contains(Path.GetExtension(s).ToLower())).ToArray();
            int startIndex = 0;

            EditorApplication.update = delegate ()
            {
                string file = files[startIndex];

                bool isCancel = EditorUtility.DisplayCancelableProgressBar("匹配资源中", file, (float)startIndex / (float)files.Length);

                string fileText = File.ReadAllText(file);
                if (Regex.IsMatch(fileText, guid))
                {
                    Debug.Log(file, AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(file)));
                }



                startIndex++;
                if (isCancel || startIndex >= files.Length)
                {
                    EditorUtility.ClearProgressBar();
                    EditorApplication.update = null;
                    startIndex = 0;
                    Debug.Log("匹配结束");
                }

            };
        }
    }

    [MenuItem("Assets/Find Object References(ArtEffect)", false, 10)]
    private static void FindArtEffect()
    {
        EditorSettings.serializationMode = SerializationMode.ForceText;
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (!string.IsNullOrEmpty(path))
        {
            string[] ex = new[] { ".prefab", ".mat" };
            SecondFind(path, ex);
        }
    }

    private static void SecondFind(string path,string[] extensions)
    {
        string guid = AssetDatabase.AssetPathToGUID(path);
        //List<string> withoutExtensions = new List<string>() { extensions };
        string[] files = Directory.GetFiles(Application.dataPath + "/Art/Effect/", "*.*", SearchOption.AllDirectories)
            .Where(s => extensions.Contains(Path.GetExtension(s).ToLower())).ToArray();
        int startIndex = 0;

        List<string> findList = new List<string>();
        bool seachResult = false;

        EditorApplication.update = delegate ()
        {
            string file = files[startIndex];

            bool isCancel = EditorUtility.DisplayCancelableProgressBar("匹配资源中", file, (float)startIndex / (float)files.Length);

            string fileText = File.ReadAllText(file);
            if (Regex.IsMatch(fileText, guid))
            {
                string aUrl = GetRelativeAssetsPath(file);
                Debug.Log(file, AssetDatabase.LoadAssetAtPath<Object>(aUrl));

                findList.Add(aUrl);
                seachResult = true;
            }

            startIndex++;
            if (isCancel || startIndex >= files.Length)
            {
                EditorUtility.ClearProgressBar();
                EditorApplication.update = null;
                startIndex = 0;
                Debug.Log("匹配结束");

                if (seachResult)
                {
                    seachResult = false;
                    ContinueSearch(findList, extensions);
                }
            }
        };
    }

    private static void ContinueSearch(List<string> findList, string[] extensions)
    {
        for (int i = 0; i < findList.Count; i++)
        {
            string str = findList[i];
            SecondFind(str, extensions);
        }
    }

    [MenuItem("Assets/Find Object Dependencies")]
    static private void VFind()
    {
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (!string.IsNullOrEmpty(path))
        {
            string[] paths = AssetDatabase.GetDependencies(path);
            Debug.Log("dependencies count::" + paths.Length);
            for (int i = 0; i < paths.Length; i++)
            {
                Debug.Log(paths[i]);
            }
        }
    }

    [MenuItem("Assets/检查选中资源的AB引用关系")]
    static void checkDep()
    {
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        string assetAbName = AssetImporter.GetAtPath(path).assetBundleName;
        if (!string.IsNullOrEmpty(path))
        {
            string[] paths = AssetDatabase.GetDependencies(path);
            Dictionary<string, List<string>> dict = new Dictionary<string, List<string>>();
            for (int i = 0; i < paths.Length; i++)
            {
                if (paths[i].EndsWith(".cs")) continue;
                string abname = AssetImporter.GetAtPath(paths[i]).assetBundleName;
                if (abname == assetAbName) abname = string.Empty;
                if (!dict.ContainsKey(abname))
                {
                    dict.Add(abname, new List<string>());
                }
                dict[abname].Add(paths[i]);                
            }
            foreach(var item in dict)
            {
                string str = " 引用" + item.Key + "的以下资源";
                if (item.Key == string.Empty)
                {
                    str = "资源" + assetAbName + "包含以下资源";
                }

                Debug.Log(str + ":\n\t" + string.Join("\n\t", item.Value.ToArray()));
            }
        }
    }

    static private string GetRelativeAssetsPath(string path)
    {
        return "Assets" + Path.GetFullPath(path).Replace(Path.GetFullPath(Application.dataPath), "").Replace('\\', '/');
    }

    

    //[MenuItem("Assets/Clear Object PackingTag")]
    static private void ClearObjectPackingTag()
    {
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (!string.IsNullOrEmpty(path))
        {
            string[] paths = AssetDatabase.GetDependencies(path);
            Debug.Log("dependencies count::" + paths.Length);
            for (int i = 0; i < paths.Length; i++)
            {
                string str = paths[i];

                if (str.IndexOf(".png") > -1 || str.IndexOf(".jpg") > -1)
                {
                    if (str.IndexOf("UI/Icons") > -1)
                    {
                        Debug.Log(str, AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(str)));
                        continue;
                    }

                    if (str.IndexOf("UI/UIAtlas/UI") > -1)
                    {
                        if (!(str.IndexOf("UI/UIAtlas/UI/A0-public") > -1))
                        {
                            AssetImporter assetImporter = AssetImporter.GetAtPath(paths[i]);
                            TextureImporter textureImporter = assetImporter as TextureImporter;
                            if (textureImporter != null)
                            {
                                if (!string.IsNullOrEmpty(textureImporter.spritePackingTag)) //
                                {
                                    //textureImporter.spritePackingTag = null;
                                    //textureImporter.assetBundleName = null;
                                    Debug.Log("clear packingTag::"+paths[i], AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(paths[i])));
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    struct PackingTagInfo
    {
        public string packingTag;
        public int refCount;
        public string abName;
        public string path;
    }

    private static Dictionary<string, PackingTagInfo> _infos = new Dictionary<string, PackingTagInfo>();

    //[MenuItem("Assets/Build UI PackingTag", false, 10)]
    static private void BuildUIPackingTag()
    {
        List<string> withoutExtensions = new List<string>() { ".prefab" };
        string[] files = Directory.GetFiles(Application.dataPath + "/BundleResources/UI/", "*.*", SearchOption.AllDirectories)
            .Where(s => withoutExtensions.Contains(Path.GetExtension(s).ToLower())).ToArray();
        int startIndex = 0;

        EditorApplication.update = delegate ()
        {
            string file = files[startIndex];

            bool isCancel = EditorUtility.DisplayCancelableProgressBar("匹配资源中", file, (float)startIndex / (float)files.Length);

            
            string url = file.Substring(file.IndexOf("Assets"));
            GameObject obj = AssetDatabase.LoadAssetAtPath<GameObject>(url);
            if (obj)
            {
                string path = AssetDatabase.GetAssetPath(obj);
                string[] paths = AssetDatabase.GetDependencies(path);
                Debug.Log("dependencies count::" + paths.Length);
                for (int i = 0; i < paths.Length; i++)
                {
                    string str = paths[i];

                    if (str.IndexOf(".png") > -1 || str.IndexOf(".jpg") > -1)
                    {
                        if (str.IndexOf("UI/Icons") > -1)
                        {
                            Debug.Log(str, AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(str)));
                            continue;
                        }

                        Debug.Log(str, AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(str)));

                        AssetImporter assetImporter = AssetImporter.GetAtPath(paths[i]);
                        TextureImporter textureImporter = assetImporter as TextureImporter;
                        if (textureImporter != null)
                        {
                            if (textureImporter.spritePackingTag != "CommonUI01")
                            {
                                if (!_infos.ContainsKey(str))
                                {
                                    PackingTagInfo info = new PackingTagInfo();
                                    info.abName = "ui/uiatlas/" + obj.name.ToLower() + ".k";
                                    info.packingTag = obj.name;
                                    info.refCount = 1;
                                    info.path = str;
                                    _infos.Add(str, info);
                                    textureImporter.textureType = TextureImporterType.Sprite;
                                    textureImporter.spritePackingTag = info.packingTag;
                                    textureImporter.assetBundleName = info.abName;
                                    textureImporter.mipmapEnabled = false;
                                }
                                else
                                {
                                    PackingTagInfo info = _infos[str];
                                    info.abName = "ui/uiatlas/commonTest.k";
                                    info.packingTag = "CommonTest";
                                    info.refCount += 1;
                                    _infos[str] = info;
                                    textureImporter.textureType = TextureImporterType.Sprite;
                                    textureImporter.spritePackingTag = info.packingTag;
                                    textureImporter.assetBundleName = info.abName;
                                    textureImporter.mipmapEnabled = false;
                                }
                            }
                        }



                        
//                        if (str.IndexOf("UI/UIAtlas/UI") > -1)
//                        {
//                            if (!(str.IndexOf("UI/UIAtlas/UI/A0-public") > -1))
//                            {
//                                AssetImporter assetImporter = AssetImporter.GetAtPath(paths[i]);
//                                TextureImporter textureImporter = assetImporter as TextureImporter;
//                                if (textureImporter != null)
//                                {
//                                    if (string.IsNullOrEmpty(textureImporter.spritePackingTag))//
//                                    {
//                                        textureImporter.textureType = TextureImporterType.Sprite;
//                                        textureImporter.spritePackingTag = Selection.activeObject.name;
//                                        textureImporter.mipmapEnabled = false;
//                                        Debug.Log(paths[i]);
//                                    }
//                                }
//                            }
//                        }
                    }
                }
            }


            startIndex++;
            if (isCancel || startIndex >= files.Length)
            {
                EditorUtility.ClearProgressBar();
                EditorApplication.update = null;
                startIndex = 0;
                Debug.Log("匹配结束");
            }

        };
    }


    [MenuItem("Assets/Get Resource Momery", false, 10)]
    static private void GetResourceMomery()
    {
        List<string> withoutExtensions = new List<string>() { ".prefab" };
        string[] files = Directory.GetFiles(Application.dataPath + "/BundleResources/UI/", "*.*", SearchOption.AllDirectories)
            .Where(s => withoutExtensions.Contains(Path.GetExtension(s).ToLower())).ToArray();
        int startIndex = 0;

        EditorApplication.update = delegate ()
        {
            string file = files[startIndex];

            bool isCancel = EditorUtility.DisplayCancelableProgressBar("匹配资源中", file, (float)startIndex / (float)files.Length);


            string url = file.Substring(file.IndexOf("Assets"));
            GameObject obj = AssetDatabase.LoadAssetAtPath<GameObject>(url);
            if (obj)
            {
                string path = AssetDatabase.GetAssetPath(obj);
                string[] paths = AssetDatabase.GetDependencies(path);
                Debug.Log("dependencies count::" + paths.Length);
                for (int i = 0; i < paths.Length; i++)
                {
                    string str = paths[i];

                    if (str.IndexOf(".png") > -1 || str.IndexOf(".jpg") > -1)
                    {
                        if (str.IndexOf("UI/Icons") > -1)
                        {
                            Debug.Log(str, AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(str)));
                            continue;
                        }

                        //Debug.Log(str, AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(str)));

                        Texture t2d = AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(str)) as Texture;

                        if (t2d != null)
                        {
                            string memorySize = EditorUtility.FormatBytes(UnityEngine.Profiling.Profiler.GetRuntimeMemorySize(t2d));
                            Debug.Log(str+"__"+ memorySize, AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(str)));
                        } 
                    }
                }
            }


            startIndex++;
            if (isCancel || startIndex >= files.Length)
            {
                EditorUtility.ClearProgressBar();
                EditorApplication.update = null;
                startIndex = 0;
                Debug.Log("搜索结束===================");
            }

        };
    }

    //[MenuItem("Assets/Build Single AB", false, 10)]
    private static void BuildSingleAB()
    {
        var names = AssetDatabase.GetAllAssetBundleNames();
        foreach (var name in names)
            Debug.Log("Asset Bundle: " + name);

//        List<string> withoutExtensions = new List<string>() { ".prefab" };
//        string[] files = Directory.GetFiles(Application.dataPath + "/BundleResources/UI/", "*.*", SearchOption.AllDirectories)
//            .Where(s => withoutExtensions.Contains(Path.GetExtension(s).ToLower())).ToArray();
//
//
//        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
//        if (!string.IsNullOrEmpty(path))
//        {
//            AssetBundleBuild[] buildMap = new AssetBundleBuild[1];
//            buildMap[0].assetBundleName = "ui/" + Selection.activeObject.name+".perfab";
//            buildMap[0].assetBundleVariant = "k";
//            string[] assetNames = new string[1];
//            assetNames[0] = "Assets/BundleResources/UI/Achieve.prefab";
//            buildMap[0].assetNames = assetNames;
//            AssetBundleManifest main = BuildPipeline.BuildAssetBundles("Assets/ABs", buildMap, BuildAssetBundleOptions.DeterministicAssetBundle, EditorUserBuildSettings.activeBuildTarget);
//
//            //            string[] paths = AssetDatabase.GetDependencies(path);
//            //            //Debug.Log("dependencies count::" + paths.Length);
//            //            for (int i = 0; i < paths.Length; i++)
//            //            {
//            //                string str = paths[i];
//            //                Debug.Log(str, AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(str)));
//            //            }
//        }
    }


}
