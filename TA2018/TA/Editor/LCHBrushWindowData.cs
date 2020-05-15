using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public partial class LCHBrushWindow
{
    GameObject ist;
    Transform parant;
    int groundMark = 1<<10;
 
    float minVal = 1f;
    float minLimit = 0.1f;
    float brushSize = 1f;
    bool upNormal = true;
    bool reandomRot = true;
    float minScale = 0.9f;
    float maxScale= 1.1f;

 
    void DeleteObject(  Vector3 pos )
    {
        if (null == parant)
        {
            return;
        }

        int count = parant.childCount;
        float bs = brushSize * 0.5f;
        for (int i = count-1; i >= 0; i--)
        {
            Transform t = parant.GetChild(i);
            if (Vector3.Distance(pos ,t.position) < bs)
            {
                GameObject.DestroyImmediate(t.gameObject,true);
            }
        }
    }
    void AddObjectByRay(Ray ray,float scale)
    {
        RaycastHit hit;
        bool hitGround = Physics.Raycast(ray, out hit, 1000f, groundMark);
        if (hitGround)
        {
            int count = parant.childCount;
            Vector3 p = hit.point;
            for (int i = 0; i < count; i++)
            {
                Transform t = parant.GetChild(i);
                if (Vector3.Distance(p, t.position) < minVal)
                {
                    return;
                }
            }
            GameObject g =  GameObject.Instantiate(ist);
            g.transform.parent = parant;
            g.transform.position = hit.point;
            g.transform.localScale = new Vector3(scale, scale, scale);
            if (upNormal  )
            {
                g.transform.up = hit.normal;
                
            }
            if (reandomRot)
            {
                g.transform.Rotate(0, Random.Range(0f, 360f), 0, Space.Self);
            }

        }
    }
    void AddObject(Ray ray, Vector3 pos,float distance,Vector3 normal)
    {
        if (null == ist)
            return ;
        if (null == parant)
        {
            parant = new GameObject("root").transform;
        }
        int count = (int)( (brushSize * brushSize)/ (minVal*minVal) ) ;
        //这里就是反正求两个垂直的轴，这里是避免跟上方向重合
        
        Vector3 axis = normal.normalized;
        Vector3 dir2 = Vector3.up;
 
        if (Mathf.Abs(Vector3.Dot(Vector3.up, axis)) > 0.9f)
        {
            dir2 = Vector3.Cross(axis, Vector3.left).normalized;
        }
        else
        {
            dir2 = Vector3.Cross(axis, Vector3.up).normalized;
        }
        float bs = brushSize*0.5f;
        float scal = Random.Range(minScale, maxScale);
        AddObjectByRay(ray,scal);
        for (int i = 1; i < count; i++)
        {
            scal = Random.Range(minScale, maxScale);
            Vector3 newVec = Quaternion.AngleAxis(Random.Range(0,360), axis) * dir2;
            Ray r = new Ray(ray.origin + newVec * Random.Range(0, bs)  , ray.direction);
            AddObjectByRay(r, scal);

        }

        
        
    }

}
