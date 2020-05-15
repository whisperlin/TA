using UnityEngine;
using UnityEditor;
using System.Collections;

namespace FAE
{
    /// <summary>
    /// Helper class to centralize commonly used fields and styles used in inspectors
    /// </summary>
    public class GUIHelper : Editor
    {
        /// <summary>Draws the Staggart Creations footer</summary>
        public static void DrawFooter()
        {
            GUILayout.Label("- Staggart Creations -", new GUIStyle(EditorStyles.centeredGreyMiniLabel)
            {
                alignment = TextAnchor.MiddleCenter,
                wordWrap = true,
                fontSize = 12
            });
        }

        /// <summary>Displays a box with the wind values from the current WindController</summary>
        public static void DrawWindInfo()
        {
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Global wind settings", EditorStyles.boldLabel);
            GUIHelper.ProgressBar(WindController._windStrength, 1f, "Strength");
            GUIHelper.ProgressBar(WindController._windAmplitude, 32f, "Amplitude");
            EditorGUILayout.Space();

        }

        private static void ProgressBar(float value, float maxValue, string label)
        {
            Rect rect = GUILayoutUtility.GetRect(6, 18, "TextField");
            EditorGUI.ProgressBar(rect, value / maxValue, label + " (" + value + " / " + maxValue + ")");
        }

        /// <summary>If the supported Unity version is used, a field for setting the Render Queue and GPU Instancing options is drawn</summary>
        public static void DrawExtraFields(MaterialEditor m_MaterialEditor)
        {
            #if UNITY_5_5_OR_NEWER
                m_MaterialEditor.RenderQueueField();
            #endif

            #if UNITY_5_6_OR_NEWER
                m_MaterialEditor.EnableInstancingField();
            #endif
        }

        //Styles
        private static GUIStyle _Header;
        public static GUIStyle Header
        {
            get
            {
                if (_Header == null)
                {
                    _Header = new GUIStyle(EditorStyles.centeredGreyMiniLabel)
                    {
                        alignment = TextAnchor.MiddleCenter,
                        wordWrap = true,
                        fontSize = 12
                    };
                }

                return _Header;
            }
        }



    }
}
