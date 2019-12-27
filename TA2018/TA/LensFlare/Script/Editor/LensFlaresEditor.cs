using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CanEditMultipleObjects, CustomEditor(typeof(LensFare))]
public class LensFlaresEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.DrawDefaultInspector();

        //GUILayout.Label("测试");
 
        LensFare myTarget = (LensFare)target;


        GUILayout.Label(myTarget.rt);
        GUILayout.Label(myTarget.rt1x1);
        //GUILayout.Label(myTarget.rt, new GUIStyle(GUI.skin.label), new GUILayoutOption [] { GUILayout.Width(300) , GUILayout.Height(300)});
        //GUILayout.Label(myTarget.rt1x1, new GUIStyle(GUI.skin.label), GUILayout.Width(32));

    }
}
 
 
 
