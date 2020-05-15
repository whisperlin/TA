using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class MeshColliderHelper 
{
    [MenuItem("TA/其它/所有LodGroup第一层添加碰撞体并且标记为地面")]
    static void lodFun()
    {
        LODGroup[] objs = GameObject.FindObjectsOfType<LODGroup>();

        for (int i = 0; i < objs.Length; i++)
        {
            LOD [] lods = objs[i].GetLODs();
            if (lods.Length > 0)
            {
                var lod = lods[0];
                for (int k = 0; k < lod.renderers.Length; k++)
                {
                    var r = lod.renderers[k];
                    if (null != r)
                    {
                        MeshCollider mc = r.gameObject.GetComponent<MeshCollider>();
                        if (mc == null)
                        {

                            MeshFilter mf = r.gameObject.GetComponent<MeshFilter>();
                            if (null != mf)
                            {
                                mc = r.gameObject.AddComponent<MeshCollider>();//
                                mc.sharedMesh = mf.sharedMesh;
                                r.gameObject.layer = 10;
                            }
                        }
                    }
                }
                
                
            }
            
        }
    }

    
}
