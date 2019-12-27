using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(BoxProjectReflectMaker))]
public class BoxProjectReflectMakerGUI : Editor
{


    public override void OnInspectorGUI()
    {
        BoxProjectReflectMaker mk = (BoxProjectReflectMaker)target;
        base.OnInspectorGUI();
        if (mk.develop)
        {
            if (GUILayout.Button("保存"))
            {
                mk.Save();
            }
        }
        
    }
    

}
