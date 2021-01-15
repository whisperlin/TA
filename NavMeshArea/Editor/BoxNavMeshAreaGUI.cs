using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(BoxNavMeshArea))]
public class BoxNavMeshAreaGUI : Editor
{
    public override void OnInspectorGUI()
    {
        
        BoxNavMeshArea mavArea = (BoxNavMeshArea)target;
#if UNITY_EDITOR
        BoxNavMeshArea.editorInstance = mavArea;
#endif
        base.OnInspectorGUI();
        if (BoxNavMeshArea.showGrid)
        {
            GUI.backgroundColor = Color.green;
            if (GUILayout.Button("关闭网格显示"))
            {
                BoxNavMeshArea.showGrid = false;
            }
        }
        else
        {
            GUI.backgroundColor = Color.yellow;
            if (GUILayout.Button("显示网格"))
            {
                BoxNavMeshArea.showGrid = true;
            }
        }
         
        
         
    }
}
