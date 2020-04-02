// Fantasy Adventure Environment
// Copyright Staggart Creations
// staggart.xyz

using UnityEngine;
using System.Collections;

namespace FAE
{
#if UNITY_EDITOR
    using UnityEditor;
    [ExecuteInEditMode]
#endif

    /// <summary>
    /// Sets the wind properties of the FAE shaders
    /// </summary>
    public class WindController : MonoBehaviour
    {
        public Texture2D windVectors;
        public bool visualizeVectors = false;
        /// <summary>
        /// Used to retreive the current state of the wind visualization, either on or off
        /// </summary>
        public static bool _visualizeVectors;

        public bool listenToWindZone = false;
        public WindZone windZone;

        [Range(0f, 1f)]
        public float windSpeed = 0.33f;
        [Range(0f, 3f)]
        public float windStrength = 1f;
        [Range(0f, 5f)]
        public float windAmplitude = 14f;

        [Range(0f, 150f)]
        public float trunkWindSpeed = 10f;
        [Range(0f, 30f)]
        public float trunkWindWeight = 4f;
        [Range(0f, 0.99f)]
        public float trunkWindSwinging = 0.5f;

        //Current wind parameters to be read externally
        public static float _windStrength;
        public static float _windAmplitude;

        /// <summary>
        /// Set the wind strength
        /// </summary>
        /// <param name="value"></param>
        public void SetStrength(float value)
        {
            Shader.SetGlobalFloat("_WindStrength", value);
        }

        /// <summary>
        /// Set the trunk weight
        /// </summary>
        /// <param name="value"></param>
        public void SetTrunkWeight(float value)
        {
            Shader.SetGlobalFloat("_TrunkWindWeight", value);
        }

        void OnEnable()
        {

#if UNITY_5_5_OR_NEWER
            visualizeVectors = (Shader.GetGlobalFloat("_WindDebug") == 1) ? true : false;
#endif

#if UNITY_EDITOR
            if (windVectors == null) windVectors = GetDefaultWindVectors();
#endif

            SetShaderParameters();
        }

        private void OnValidate()
        {
            if (!windZone && listenToWindZone)
            {
                if (this.GetComponent<WindZone>())
                {
                    windZone = this.GetComponent<WindZone>();
                }
                else
                {
                    windZone = FindObjectOfType<WindZone>();
                }
            }
        }


        [Range(0f, 100f)]
        public float strength = 20f;
        [Range(0f, 5f)]
        public float radius = 1.5f;

        
        private void Update()
        {
            if (windZone && listenToWindZone)
            {
                SetStrength(windStrength * windZone.windMain);
                SetTrunkWeight(trunkWindWeight * windZone.windMain);
            }

       
            Shader.SetGlobalVector("_WindDirection", this.transform.rotation * Vector3.back);
        }

        public void Apply()
        {
#if UNITY_EDITOR

            //Sync the static var to the local var
            visualizeVectors = _visualizeVectors;
            VisualizeVectors(visualizeVectors);

            SetShaderParameters();
#endif
        }

        private void SetShaderParameters()
        {
            Shader.SetGlobalTexture("_WindVectors", windVectors);
            Shader.SetGlobalFloat("_WindSpeed", windSpeed);
            Shader.SetGlobalFloat("_WindStrength", windStrength);
            Shader.SetGlobalFloat("_WindAmplitude", windAmplitude);
            Shader.SetGlobalVector("_WindDirection", this.transform.rotation * Vector3.back);
            
            Shader.SetGlobalFloat("_TrunkWindSpeed", trunkWindSpeed);
            Shader.SetGlobalFloat("_TrunkWindWeight", trunkWindWeight);
            Shader.SetGlobalFloat("_TrunkWindSwinging", trunkWindSwinging);

            //Set static var
            WindController._windStrength = windStrength;
            WindController._windAmplitude = windAmplitude;

        }

        /// <summary>
        /// Toggles the visualization of the wind vectors on all shaders that feature wind animations
        /// </summary>
        /// <param name="state">boolean</param>
        public static void VisualizeVectors(bool state)
        {
            _visualizeVectors = state;
            Shader.SetGlobalFloat("_WindDebug", state ? 1f : 0f);
        }

#if UNITY_EDITOR

        private void OnDisable()
        {
            VisualizeVectors(false);
        }

        void OnDrawGizmos()
        {
            Vector3 dir = (transform.position + transform.forward).normalized;

            Gizmos.color = Color.magenta;
            Vector3 up = transform.up;
            Vector3 side = transform.right;

            Vector3 end = transform.position + transform.forward * (windSpeed * 10f);
            Gizmos.DrawLine(transform.position, end);

            float s = windSpeed;
            Vector3 front = transform.forward * windSpeed;

            Gizmos.DrawLine(end, end - front + up * s);
            Gizmos.DrawLine(end, end - front - up * s);
            Gizmos.DrawLine(end, end - front + side * s);
            Gizmos.DrawLine(end, end - front - side * s);

            Gizmos.DrawLine(end - front - side * s, end - front + up * s);
            Gizmos.DrawLine(end - front + up * s, end - front + side * s);
            Gizmos.DrawLine(end - front + side * s, end - front - up * s);
            Gizmos.DrawLine(end - front - up * s, end - front - side * s);
        }

        [MenuItem("GameObject/3D Object/FAE Wind Controller")]
        private static void NewMenuOption()
        {
            WindController currentWindController = GameObject.FindObjectOfType<WindController>();
            if (currentWindController != null)
            {
                if (EditorUtility.DisplayDialog("FAE Wind Controller", "A WindController object already exists in your scene", "Create anyway", "Cancel"))
                {
                    CreateNewWindController();
                }
            }
            else
            {
                CreateNewWindController();
            }
        }

        private static void CreateNewWindController()
        {
            GameObject newWindController = new GameObject()
            {
                name = "Wind Controller"
            };
            newWindController.AddComponent<WindController>();

            Undo.RegisterCreatedObjectUndo(newWindController, "Created Wind Controller");
        }

        private Texture2D GetDefaultWindVectors()
        {
            string[] assets = AssetDatabase.FindAssets("FAE_WindVectors t:Texture2D");

            if (assets.Length > 0)
            {
                string path = AssetDatabase.GUIDToAssetPath(assets[0]);

                return (Texture2D)AssetDatabase.LoadAssetAtPath(path, typeof(Texture2D));
            }
            else
            {
                return null;
            }
        }
#endif

    }
}