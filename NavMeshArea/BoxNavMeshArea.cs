using UnityEngine;
using UnityEngine.AI;
using System.Collections;
using System.Collections.Generic;
using NavMeshBuilder = UnityEngine.AI.NavMeshBuilder;

#if UNITY_EDITOR
using UnityEditor;
#endif
// Build and update a localized navmesh from the sources marked by NavMeshSourceTag
[DefaultExecutionOrder(-102)]
public class BoxNavMeshArea : MonoBehaviour
{
#if UNITY_EDITOR
    public static bool showGrid = true;
    public static BoxNavMeshArea editorInstance = null;
#endif

    // The center of the build
    int areaId = 0;

    NavMeshData m_NavMesh;
    AsyncOperation m_Operation;
    NavMeshDataInstance m_Instance;
    List<NavMeshBuildSource> m_Sources = new List<NavMeshBuildSource>();

    Bounds bounds;
#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
 
        BoxCollider[] bcs = GetComponentsInChildren<BoxCollider>();
        if (bcs.Length == 0)
        {
            GameObject g = new GameObject("Cube");
            bcs = new BoxCollider[] { g.AddComponent<BoxCollider>() };
            g.transform.parent = transform;
            g.transform.localPosition = Vector3.zero;
            g.transform.localScale = Vector3.one;
            g.transform.localRotation = Quaternion.identity;

        }
        Matrix4x4 worldToLocal = transform.worldToLocalMatrix;
        foreach (BoxCollider b in bcs)
        {
            b.center = Vector3.zero;
            MeshFilter m = b.gameObject.GetComponent<MeshFilter>();
            if (m != null)
            {
                GameObject.DestroyImmediate(m);
                GameObject.DestroyImmediate(b.gameObject.GetComponent<Renderer>());
            }

            if (showGrid)
            {
                if (b.gameObject != Selection.activeGameObject)
                {
                    Gizmos.color = Color.yellow;
                    Gizmos.matrix = b.transform.localToWorldMatrix;
                    Gizmos.DrawWireCube(Vector3.zero, b.size);
                }
            }
        }
    }
#endif
    void OnEnable()
    {
        // Construct and add navmesh
        m_NavMesh = new NavMeshData();
        m_Instance = NavMesh.AddNavMeshData(m_NavMesh);
        UpdateNavMesh(false);
    }

    void OnDisable()
    {
        // Unload navmesh and clear handle
        m_Instance.Remove();
    }


    static Vector3 Abs(Vector3 v)
    {
        return new Vector3(Mathf.Abs(v.x), Mathf.Abs(v.y), Mathf.Abs(v.z));
    }
    
    static void GetWorldBounds(Matrix4x4 mat, Vector3 size,ref Vector3 _max,ref Vector3 _min )
    {
        size = size * 0.5f;
        Vector3 wpos = mat.MultiplyPoint(Vector3.zero);
        var absAxisX = Abs(mat.MultiplyVector(Vector3.right));
        var absAxisY = Abs(mat.MultiplyVector(Vector3.up));
        var absAxisZ = Abs(mat.MultiplyVector(Vector3.forward));

        {
            Vector3 worldSize =  absAxisX * size.x + absAxisY * size.y + absAxisZ * size.z;
            Vector3 _wpos = wpos + worldSize;
            _max.x = Mathf.Max(_wpos.x,_max.x);
            _max.y = Mathf.Max(_wpos.y, _max.y);
            _max.z = Mathf.Max(_wpos.z, _max.z);

            _min.x = Mathf.Min(_wpos.x, _min.x);
            _min.y = Mathf.Min(_wpos.y, _min.y);
            _min.z = Mathf.Min(_wpos.z, _min.z);
        }

        {
            Vector3 worldSize =  absAxisX * size.x + absAxisY * size.y - absAxisZ * size.z;
            Vector3 _wpos = wpos + worldSize;
            _max.x = Mathf.Max(_wpos.x, _max.x);
            _max.y = Mathf.Max(_wpos.y, _max.y);
            _max.z = Mathf.Max(_wpos.z, _max.z);

            _min.x = Mathf.Min(_wpos.x, _min.x);
            _min.y = Mathf.Min(_wpos.y, _min.y);
            _min.z = Mathf.Min(_wpos.z, _min.z);
        }
        {
            Vector3 worldSize =  absAxisX * size.x - absAxisY * size.y + absAxisZ * size.z;
            Vector3 _wpos = wpos + worldSize;
            _max.x = Mathf.Max(_wpos.x, _max.x);
            _max.y = Mathf.Max(_wpos.y, _max.y);
            _max.z = Mathf.Max(_wpos.z, _max.z);

            _min.x = Mathf.Min(_wpos.x, _min.x);
            _min.y = Mathf.Min(_wpos.y, _min.y);
            _min.z = Mathf.Min(_wpos.z, _min.z);
        }
        {
            Vector3 worldSize =  absAxisX * size.x - absAxisY * size.y - absAxisZ * size.z;
            Vector3 _wpos = wpos + worldSize;
            _max.x = Mathf.Max(_wpos.x, _max.x);
            _max.y = Mathf.Max(_wpos.y, _max.y);
            _max.z = Mathf.Max(_wpos.z, _max.z);

            _min.x = Mathf.Min(_wpos.x, _min.x);
            _min.y = Mathf.Min(_wpos.y, _min.y);
            _min.z = Mathf.Min(_wpos.z, _min.z);
        }
        {
            Vector3 worldSize = -absAxisX * size.x + absAxisY * size.y + absAxisZ * size.z;
            Vector3 _wpos = wpos + worldSize;
            _max.x = Mathf.Max(_wpos.x, _max.x);
            _max.y = Mathf.Max(_wpos.y, _max.y);
            _max.z = Mathf.Max(_wpos.z, _max.z);

            _min.x = Mathf.Min(_wpos.x, _min.x);
            _min.y = Mathf.Min(_wpos.y, _min.y);
            _min.z = Mathf.Min(_wpos.z, _min.z);
        }
        {
            Vector3 worldSize = -absAxisX * size.x + absAxisY * size.y - absAxisZ * size.z;
            Vector3 _wpos = wpos + worldSize;
            _max.x = Mathf.Max(_wpos.x, _max.x);
            _max.y = Mathf.Max(_wpos.y, _max.y);
            _max.z = Mathf.Max(_wpos.z, _max.z);

            _min.x = Mathf.Min(_wpos.x, _min.x);
            _min.y = Mathf.Min(_wpos.y, _min.y);
            _min.z = Mathf.Min(_wpos.z, _min.z);
        }
        {
            Vector3 worldSize = -absAxisX * size.x - absAxisY * size.y + absAxisZ * size.z;
            Vector3 _wpos = wpos + worldSize;
            _max.x = Mathf.Max(_wpos.x, _max.x);
            _max.y = Mathf.Max(_wpos.y, _max.y);
            _max.z = Mathf.Max(_wpos.z, _max.z);

            _min.x = Mathf.Min(_wpos.x, _min.x);
            _min.y = Mathf.Min(_wpos.y, _min.y);
            _min.z = Mathf.Min(_wpos.z, _min.z);
        }
        {
            Vector3 worldSize = -absAxisX * size.x - absAxisY * size.y - absAxisZ * size.z;
            Vector3 _wpos = wpos + worldSize;
            _max.x = Mathf.Max(_wpos.x, _max.x);
            _max.y = Mathf.Max(_wpos.y, _max.y);
            _max.z = Mathf.Max(_wpos.z, _max.z);

            _min.x = Mathf.Min(_wpos.x, _min.x);
            _min.y = Mathf.Min(_wpos.y, _min.y);
            _min.z = Mathf.Min(_wpos.z, _min.z);
        }

    }
    Bounds CalculateWorldBounds(List<NavMeshBuildSource> sources)
    {

        Vector3 _min = new Vector3(float.MaxValue, float.MaxValue, float.MaxValue);
        Vector3 _max = new Vector3(float.MinValue, float.MinValue, float.MinValue);
        foreach (var src in sources)
        {
            GetWorldBounds(src.transform , src.size, ref _max, ref _min);
            //result.Encapsulate(GetWorldBounds(worldToLocal , new Bounds(src.transform.MultiplyPoint(Vector3.zero), src.transform.MultiplyVector(src.size))));
        }

        Vector3 center = (_max + _min) * 0.5f;
        Vector3 _size = (_max - center )*2f;
        return new Bounds(center,_size);
    }
    
    void UpdateNavMesh(bool asyncUpdate = false)
    {
        m_Sources.Clear();

        BoxCollider[] bcs = GetComponentsInChildren<BoxCollider>();
       

         
        Matrix4x4 worldToLocal = transform.worldToLocalMatrix;
        foreach (BoxCollider b in bcs)
        {

            var s = new NavMeshBuildSource();
            s.shape = NavMeshBuildSourceShape.Box;
            s.transform = b.transform.localToWorldMatrix;
            s.size = b.size;
            s.area = areaId;
            
            var m = b.transform.localToWorldMatrix;
             

            m_Sources.Add(s);
        }
        var defaultBuildSettings = NavMesh.GetSettingsByID(0);
        defaultBuildSettings.agentRadius = 0.08f;
        defaultBuildSettings.minRegionArea = 0.5f;
 
        bounds =  CalculateWorldBounds(m_Sources);
 
        if (asyncUpdate)
            m_Operation = NavMeshBuilder.UpdateNavMeshDataAsync(m_NavMesh, defaultBuildSettings, m_Sources, bounds);
        else
        {
            NavMeshBuilder.UpdateNavMeshData(m_NavMesh, defaultBuildSettings, m_Sources, bounds);
        }
            
    }

    static Vector3 Quantize(Vector3 v, Vector3 quant)
    {
        float x = quant.x * Mathf.Floor(v.x / quant.x);
        float y = quant.y * Mathf.Floor(v.y / quant.y);
        float z = quant.z * Mathf.Floor(v.z / quant.z);
        return new Vector3(x, y, z);
    }

     

    void OnDrawGizmosSelected()
    {
        
        if (this == BoxNavMeshArea.editorInstance)
        {
            if (m_NavMesh)
            {
                Gizmos.color = Color.red;
                Gizmos.DrawWireCube(m_NavMesh.sourceBounds.center, m_NavMesh.sourceBounds.size);
            }
        }
        

        

        
    }
}
