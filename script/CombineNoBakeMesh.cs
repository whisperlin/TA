using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CombineNoBakeMesh : MonoBehaviour {

    Dictionary<Material, List<MeshFilter>> mfs = new Dictionary<Material, List<MeshFilter>>();
 

    List<MeshFilter> GetMeshList(Material m)
    {
        List<MeshFilter> result;
        if (mfs.TryGetValue(m,out result))
        {
            return result;
        }
        result = new List<MeshFilter>();
        mfs[m] = result;
        return result;
    }

    // Use this for initialization
    void Start () {
        MeshRenderer [] mrs = transform.GetComponentsInChildren<MeshRenderer>();
        for (int i = 0; i < mrs.Length; i++)
        {
            MeshRenderer r = mrs[i];
            MeshFilter m = r.GetComponent<MeshFilter>();
            if (null != m )
            {
                GetMeshList(r.sharedMaterial).Add(m);
            }
        }
        foreach (var item in mfs)
        {
            Material m = item.Key;
            List<MeshFilter> _mfs = item.Value;
            int meshCount = 0;
            int begin = 0;
            //CombineInstance[] combine;
            for (int i = 0; i <= _mfs.Count; i++)
            {
                if (i == _mfs.Count || meshCount + _mfs[i].sharedMesh.vertexCount > 6500 )
                {
                    int count = i - begin;
                    CombineInstance[] combine = new CombineInstance[count];
                    for (int j = begin,k=0; j < i; j++,k++)
                    {
                        MeshFilter _mf2 = _mfs[j];
                        combine[k].mesh = _mf2.sharedMesh;
                        combine[k].transform = _mf2.transform.localToWorldMatrix;
                        _mf2.gameObject.SetActive(false);
                    }
                    Mesh newMesh = new Mesh();
                    newMesh.CombineMeshes(combine);
                    GameObject g = new GameObject("DymCombineMesh_"+m.name);
                    g.AddComponent<MeshFilter>().sharedMesh = newMesh;
                    g.AddComponent<MeshRenderer>().sharedMaterial = m;
                    meshCount = 0;
                    begin = i;
                }
                else
                {
                    meshCount += _mfs[i].sharedMesh.vertexCount;
                }
            }


        }

	}
	
	
}
