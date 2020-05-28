using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


public class ColorValueWindow :EditorWindow
{
 

    Color color = Color.white;

    // Add menu named "My Window" to the Window menu
    [MenuItem("TA/工具/颜色转换")]
    static void Init()
    {
        // Get existing open window or if none, make a new one:
        ColorValueWindow window = (ColorValueWindow)EditorWindow.GetWindow(typeof(ColorValueWindow));
        window.Show();
    }

    void OnGUI()
    {
        color = EditorGUILayout.ColorField(new GUIContent(""), color,true,true, true);
        EditorGUILayout.TextArea(color.ToString());
     
         
    }
}
