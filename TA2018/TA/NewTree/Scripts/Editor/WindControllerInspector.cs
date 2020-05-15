using UnityEngine;
using System.Collections;
using UnityEditor;

namespace FAE
{
    [CustomEditor(typeof(WindController))]
    public class WindControllerInspector : Editor
    {
        WindController wc;

        private bool showHelp = false;
        private bool visualizeVectors;

        new SerializedObject serializedObject;

        SerializedProperty listenToWindZone;
        SerializedProperty windZone;

        SerializedProperty windVectors;

        SerializedProperty windSpeed;
        SerializedProperty windStrength;
        SerializedProperty windAmplitude;

        SerializedProperty trunkWindSpeed;
        SerializedProperty trunkWindWeight;
        SerializedProperty trunkWindSwinging;


#if UNITY_EDITOR
        void OnEnable()
        {
            wc = (WindController)target;
            serializedObject = new SerializedObject(target);
            listenToWindZone = serializedObject.FindProperty("listenToWindZone");
            windZone = serializedObject.FindProperty("windZone");
            windVectors = serializedObject.FindProperty("windVectors");

            windSpeed = serializedObject.FindProperty("windSpeed");
            windStrength = serializedObject.FindProperty("windStrength");
            windAmplitude = serializedObject.FindProperty("windAmplitude");

            trunkWindSpeed = serializedObject.FindProperty("trunkWindSpeed");
            trunkWindWeight = serializedObject.FindProperty("trunkWindWeight");
            trunkWindSwinging = serializedObject.FindProperty("trunkWindSwinging");

        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUI.BeginChangeCheck();

            //Sync inspector var to static class var
            visualizeVectors = WindController._visualizeVectors;

            Undo.RecordObject(this, "Component");
            Undo.RecordObject(wc, "WindController");

            DrawFields();

            serializedObject.ApplyModifiedProperties();

            if (GUI.changed || EditorGUI.EndChangeCheck())
            {
                EditorUtility.SetDirty((WindController)target);
                wc.Apply();

                //Set the static var
                WindController.VisualizeVectors(visualizeVectors);
            }

        }


        private void DrawFields()
        {
            DoHeader();

            EditorGUILayout.Space();

            EditorGUILayout.PropertyField(windVectors);
            if (!windVectors.objectReferenceValue)
            {
                EditorGUILayout.HelpBox("Assign a wind vector map for wind to function", MessageType.Error);
                return;
            }
            
            EditorGUILayout.PropertyField(listenToWindZone, new GUIContent("Listen to Wind Zone"));
            if (showHelp) EditorGUILayout.HelpBox("When a Wind Zone is assigned, the wind strength and tree trunk weight values are divided by it's \"Main\" parameter value.\n\nThis allows you to use weather systems such as Enviro", MessageType.Info);
            if (listenToWindZone.boolValue)
            {
                EditorGUILayout.PropertyField(windZone, new GUIContent("Wind Zone"));
            }

            EditorGUILayout.Space();

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            EditorGUILayout.LabelField("Wind settings", EditorStyles.toolbarButton);
            EditorGUILayout.Space();

            EditorGUILayout.PropertyField(windSpeed, new GUIContent("Speed"));
            if (showHelp) EditorGUILayout.HelpBox("The overall speed of the wind.", MessageType.Info);
            EditorGUILayout.PropertyField(windStrength, new GUIContent("Strength"));
            if (showHelp) EditorGUILayout.HelpBox("The overall strength of the wind.", MessageType.Info);
            EditorGUILayout.PropertyField(windAmplitude, new GUIContent("Amplitude"));
            if (showHelp) EditorGUILayout.HelpBox("The overall amplitude of the wind, essentially the size of wind waves.\n\nThe shader have a \"WindAmplitudeMultiplier\" parameter which multiplies this value in the material.", MessageType.Info);

            EditorGUILayout.Space();
            EditorGUILayout.EndVertical();
            
            EditorGUILayout.Space();

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            EditorGUILayout.LabelField("Tree trunks", EditorStyles.toolbarButton);
            EditorGUILayout.Space();

            EditorGUILayout.PropertyField(trunkWindSpeed, new GUIContent("Speed"));
            if (showHelp) EditorGUILayout.HelpBox("The speed by which the tree moves.", MessageType.Info);
            EditorGUILayout.PropertyField(trunkWindWeight, new GUIContent("Weight"));
            if (showHelp) EditorGUILayout.HelpBox("The amount of influence the wind has on a tree.", MessageType.Info);
            EditorGUILayout.PropertyField(trunkWindSwinging, new GUIContent("Swinging"));
            if (showHelp) EditorGUILayout.HelpBox("A value higher than 0 means the trees will also move against the wind direction.", MessageType.Info);

            EditorGUILayout.Space();
            EditorGUILayout.EndVertical();

            visualizeVectors = EditorGUILayout.Toggle("Visualize wind", visualizeVectors);
            if (showHelp) EditorGUILayout.HelpBox("Toggle a visualisation of the wind vectors on all the objects that use FAE shaders featuring wind.\n\nThis allows you to more clearly see the effects of the settings.", MessageType.Info);

            GUIHelper.DrawFooter();
        }

        private void DoHeader()
        {
            EditorGUILayout.BeginHorizontal();
            showHelp = GUILayout.Toggle(showHelp, "Toggle help", "Button");
            GUILayout.Label("FAE Wind Controller", GUIHelper.Header);
            EditorGUILayout.EndHorizontal();
            if (showHelp) EditorGUILayout.HelpBox("This script drives the wind parameters of the Foliage, Grass, Tree Branch and Tree Trunk shaders.", MessageType.Info);
        }


#endif
    }
}