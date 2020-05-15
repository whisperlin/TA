using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.SceneManagement;
using UnityEditor.SceneManagement;

public partial class LCHBrushWindow  
{
    public bool editorEnable = true;

    static LayerMask LayerMaskField(string label, LayerMask layerMask)
    {
        List<string> layers = new List<string>();
        List<int> layerNumbers = new List<int>();

        for (int i = 0; i < 32; i++)
        {
            string layerName = LayerMask.LayerToName(i);
            if (layerName != "")
            {
                layers.Add(layerName);
                layerNumbers.Add(i);
            }
        }
        int maskWithoutEmpty = 0;
        for (int i = 0; i < layerNumbers.Count; i++)
        {
            if (((1 << layerNumbers[i]) & layerMask.value) > 0)
                maskWithoutEmpty |= (1 << i);
        }
        maskWithoutEmpty = EditorGUILayout.MaskField(label, maskWithoutEmpty, layers.ToArray());
        int mask = 0;
        for (int i = 0; i < layerNumbers.Count; i++)
        {
            if ((maskWithoutEmpty & (1 << i)) > 0)
                mask |= (1 << layerNumbers[i]);
        }
        layerMask.value = mask;
        return layerMask;
    }

    public static void saveScene()
    {
        Scene currentScene = SceneManager.GetActiveScene();
        if (!currentScene.isDirty) Debug.Log("Scene was NOT marked dirty");
        EditorSceneManager.MarkSceneDirty(currentScene);
        if (!EditorSceneManager.SaveScene(currentScene)) Debug.LogError("WARNING: Scene Not Saved!!!");
    }
    private void OnGUI()
    {
        ist = EditorGUILayout.ObjectField("画刷物体", ist, typeof(GameObject),false) as GameObject;

        parant = EditorGUILayout.ObjectField("根节点", parant, typeof(Transform),true) as Transform;

        groundMark = LayerMaskField("地表层级剔除", groundMark);
 
        //EditorGUILayout.LayerField
       // groundMark = LayerMaskField("地表层级剔除", groundMark);
   
 
        minVal = EditorGUILayout.Slider("最小间隔", minVal, 0.1f, 10f);

        brushSize = EditorGUILayout.Slider("画刷半径",brushSize, 1f, 10f);

        upNormal = EditorGUILayout.ToggleLeft("朝法线方向", upNormal);

        reandomRot = EditorGUILayout.ToggleLeft("随机旋转", reandomRot);

        EditorGUILayout.LabelField("最小缩放/最大缩放:" + minScale+"/"+ maxScale);
        EditorGUILayout.MinMaxSlider(ref  minScale,ref maxScale, 0.1f, 2.0f);
        //bool upNormal = true;
        //bool reandomRot = true;
        //float minScale = 0.9f;
        //float maxScale = 1.1f;
        if (editorEnable)
        {
            GUI.backgroundColor = Color.green;
            if (GUILayout.Button("开启中"))
            {
                saveScene();
                editorEnable = false;
            }
        }
        else
        {
            GUI.backgroundColor = Color.grey;
            if (GUILayout.Button("关闭中"))
            {
                editorEnable = true;
            }
        }

    }
}
