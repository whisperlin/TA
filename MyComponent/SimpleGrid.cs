using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleGrid : MonoBehaviour
{
    public int id = 0;
    [Label("网格大小")]
    public Vector2Int size = new Vector2Int(10, 10);
    [Label("格子宽度")]
    public float cellWidth = 1f;
    public Material mat;


    public MeshCollider[] cells;
    public MeshRenderer[] mRenders;
    public GameObject[] ts;

    public Mesh mesh;

    public void Start()
    {
        UpdateGrid();
    }
    void UpdateMesh()
    {
        if (null == mesh)
        {
            mesh = new Mesh();
        }
        float halfWidth = cellWidth * 0.5f;
        Vector3[] vertices = new Vector3[4]
        {
            new Vector3(   -halfWidth,0,  -halfWidth),
            new Vector3(   +halfWidth,0,  -halfWidth),
            new Vector3(   -halfWidth,0,  +halfWidth),
            new Vector3(   +halfWidth,0,  +halfWidth)
        };
        mesh.vertices = vertices;

        int[] tris = new int[6]
        {
            0, 2, 1,
            2, 3, 1
        };
        mesh.triangles = tris;



        Vector2[] uv = new Vector2[4]
        {
            new Vector2(0, 0),
            new Vector2(1, 0),
            new Vector2(0, 1),
            new Vector2(1, 1)
        };
        mesh.uv = uv;
    }
    int GetIndex(int x, int y)
    {
        return x + y * size.x;
    }
    void UpdatePosition()
    {
        float offsetX = -0.5f * (size.x - 1);
        float offsetY = -0.5f * (size.y - 1);
        for (int i = 0; i < size.x; i++)
        {
            for (int j = 0; j < size.y; j++)
            {
                int _i = GetIndex(i, j);
                var t = ts[_i];
                t.transform.localScale = Vector3.one;
                t.transform.localRotation = Quaternion.identity;
                t.transform.localPosition = new Vector3(cellWidth * (offsetX + i), 0, cellWidth * (offsetY + j));
            }
        }
    }

    public void RemoveAllChilds()
    {
        if (Application.isPlaying)
        {
            for (int i = transform.childCount - 1; i >= 0; i--)
            {
                GameObject.Destroy(transform.GetChild(i).gameObject);
            }
        }
        else
        {
            for (int i = transform.childCount - 1; i >= 0; i--)
            {
                GameObject.DestroyImmediate(transform.GetChild(i).gameObject, true);
            }
        }

    }
    void UpdateMaterial()
    {
        foreach (MeshRenderer mr in mRenders)
        {
            mr.sharedMaterial = mat;
        }
    }

    public bool RaycastGrid(Ray ray, out Vector2Int cellIndex)
    {
        cellIndex = Vector2Int.zero;
        var matW2L = transform.worldToLocalMatrix;
        var matL2W = transform.localToWorldMatrix;

        Vector3 center = matW2L.MultiplyPoint(ray.origin);
        Vector3 dir = matW2L.MultiplyVector(ray.direction);
        //center + dir *t = hitPos;
        //hitPos.y = 0;
        //center.y + dir.y*t = 0;
        //t = -center.y / dir.y;
        dir.y = Math.Abs(dir.y) == 0 ? 0.000100f : dir.y;
        float t = -center.y / dir.y;
        Vector3 hipPos = center + dir * t;

        float offsetX = -0.5f * (size.x - 1);
        float offsetY = -0.5f * (size.y - 1);
        hipPos.x -= offsetX;
        hipPos.z -= offsetY;
        cellIndex.x = (int)(hipPos.x + 0.5f);
        cellIndex.y = (int)(hipPos.z + 0.5f);

        //return true;
        return HasCell(cellIndex.x, cellIndex.y);
    }
    public bool HasCell(int x,int y)
    {
        if (
            x >= size.x
            || x < 0
            || y >= size.y
            || y < 0
            )
        {
            return false;
        }
        int _id = GetIndex(x,y);

        return ts[_id] != null && ts[_id].activeSelf;
    }
    public void UpdateGrid()
    {
        UpdateMesh();
        if (size.x <= 0 || size.y <= 0)
            return;
        int count = size.x * size.y;
        if (null == cells || cells.Length != count)
        {
            RemoveAllChilds();
            cells = new MeshCollider[size.x*size.y];
            mRenders = new MeshRenderer[size.x * size.y];
            ts = new GameObject[size.x * size.y];
            for (int i = 0; i < size.x; i++)
            {
                for(int j = 0; j < size.y; j++)
                {
                    int _i = GetIndex(i, j);
                    GameObject g = new GameObject(i.ToString() + " " + j.ToString());
                    MeshFilter mf = g.AddComponent<MeshFilter>();
                    mf.sharedMesh = mesh;
                    MeshRenderer mr = g.AddComponent<MeshRenderer>();
                    
                    MeshCollider mc = g.AddComponent<MeshCollider>();
                    mc.sharedMesh = mesh;
                    cells[_i] = mc;
                    mRenders[_i] = mr;
                    ts[_i] = g;
                    g.transform.parent = transform;
                }
            }
            
        }
        UpdateMaterial();
        UpdatePosition();
        //for(int i = 0; i < )
    }
}
    
