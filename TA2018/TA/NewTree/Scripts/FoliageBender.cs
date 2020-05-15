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
    /// Sets world-space obstacle position and bending strength on the FAE foliage shader
    /// </summary>
    public class FoliageBender : MonoBehaviour
    {

        [Range(0f, 10f)]
        public float strength = 2f;
        [Range(0f, 5f)]
        public float radius = 1.5f;

        void Update()
        {
            Shader.SetGlobalVector("_ObstaclePosition", this.transform.position);
            Shader.SetGlobalFloat("_BendingStrength", strength);
            Shader.SetGlobalFloat("_BendingRadius", radius);
        }
    }
}