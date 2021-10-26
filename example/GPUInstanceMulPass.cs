using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class GPUInstanceMulPass : MonoBehaviour
{
    public Material mat;
    public Mesh mesh;
    [Range(1,50)]
    public int  count = 10;
    List<Matrix4x4> ts = new List<Matrix4x4>();
    float[] offsetIndex = { 1f};
    // Update is called once per frame
    void LateUpdate()
    {
      
        if (null != mat && null != mesh)
        {
            float delta = 1f / count;
            mat.enableInstancing = true;
            ts.Clear();
            var m = transform.localToWorldMatrix;
            MaterialPropertyBlock ms = new MaterialPropertyBlock();
            if (offsetIndex.Length != count)
                offsetIndex = new float[count];
            for (int i = 0; i < count;i ++)
            {
                ts.Add(m);
                offsetIndex[i] = delta * i;
            }
            ms.SetFloatArray("_Offset", offsetIndex);
            Graphics.DrawMeshInstanced(mesh, 0, mat, ts, ms); 
        }
    }
}
