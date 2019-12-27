 
using UnityEngine;
using UnityEditor;

 
[CanEditMultipleObjects]
[CustomEditor(typeof(ImageEffectMgr))]
public class ImageEffectMgrEditor : Editor
{
    BloomGraphDrawer _graph;

    
 

    static GUIContent _textThreshold = new GUIContent("Threshold (gamma)");

    void OnEnable()
    {
        _graph = new BloomGraphDrawer();
        
     
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        if (!serializedObject.isEditingMultipleObjects) {
            EditorGUILayout.Space();
			ImageEffectMgr mgr = (ImageEffectMgr)target;
			_graph.Prepare(mgr);
            _graph.DrawGraph();
            EditorGUILayout.Space();
			base.OnInspectorGUI ();
 

			serializedObject.ApplyModifiedProperties();
			return;

        }
 
		base.OnInspectorGUI ();

        serializedObject.ApplyModifiedProperties();
    }
}
 