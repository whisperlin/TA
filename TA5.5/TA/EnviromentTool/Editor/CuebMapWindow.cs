using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
public class CuebMapWindow : EditorWindow
{
    string myString = "Hello World";
    bool groupEnabled;
    bool myBool = true;
    float myFloat = 1.23f;

    // Add menu named "My Window" to the Window menu
    [MenuItem("TA/环境球/CubeMap 转 捕捉Panoramic")]
    static void Init()
    {
        // Get existing open window or if none, make a new one:
        CuebMapWindow window = (CuebMapWindow)EditorWindow.GetWindow(typeof(CuebMapWindow));
        window.Show();
    }

    Cubemap cubemap;
    void OnGUI()
    {

        cubemap = (Cubemap)EditorGUILayout.ObjectField("天空球", cubemap, typeof(Cubemap),true);
        if (GUILayout.Button("转换"))
        {
        }
        
    }
}