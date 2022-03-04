using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class MeshHelper  
{


  
    public static Mesh GetFullScreenWorld(Camera cam,ref Mesh _fullScreenWorld)
    {
        if (null == _fullScreenWorld)
            _fullScreenWorld = new Mesh();
        if (null == _fullScreenWorld)
        {
            _fullScreenWorld = new Mesh();
            
        }
        float near = 0;
        float height = 0;
        float widht = 0;
        if (cam.orthographic)
        {
            near = cam.nearClipPlane + 0.001f;
            height = cam.orthographicSize;
            widht = cam.aspect * height;
        }
        else
        {
            near = cam.nearClipPlane + 0.001f;
            height = near * Mathf.Tan(Mathf.Deg2Rad * cam.fieldOfView / 2);
            widht = cam.aspect * height;
            
        }
        Vector3[] vertices = new Vector3[4]
                {
            new Vector3(-widht, -height, near),
            new Vector3(-widht, height, near),
            new Vector3(widht, height, near),
            new Vector3(widht, -height, near)
                };
        _fullScreenWorld.vertices = vertices;

        int[] tris;
        Vector2[] uv;

        tris = new int[6]
                {
                    0, 1, 2,
                     0, 2, 3,
                };
        uv = new Vector2[4]
            {
                new Vector2(0, 0),
                new Vector2(0, 1f),
                new Vector2(1f, 1f),
                new Vector2(1f, 0f)
            };
        _fullScreenWorld.triangles = tris;
        _fullScreenWorld.uv = uv;
        return _fullScreenWorld;
    }
    static Mesh _fullScreen;
    public static Mesh GetFullScreen()
    {
        if (null == _fullScreen)
        {
            _fullScreen = new Mesh();
            Vector3[] vertices = new Vector3[4]
            {
            new Vector3(-1f, -1f, 0),
            new Vector3(-1f, 1f, 0),
            new Vector3(1f, 1f, 0f),
            new Vector3(1f, -1f, 0f)
            };
            _fullScreen.vertices = vertices;

            int[] tris;
            Vector2[] uv;
            if (SystemInfo.graphicsUVStartsAtTop)
            {
                // 0, 2, 1
                tris = new int[6]
               {
                    0, 2, 1,
                     0, 3, 2,
               };

                uv = new Vector2[4]
                {
                new Vector2(0, 1f),
                new Vector2(0, 0f),
                new Vector2(1f, 0f),
                new Vector2(1f, 1f)
                };
            }
            else
            {
                tris = new int[6]
                    {
                    0, 1, 2,
                     0, 2, 3,
                    };
                uv = new Vector2[4]
                {
                new Vector2(0, 0),
                new Vector2(0, 1f),
                new Vector2(1f, 1f),
                new Vector2(1f, 0f)
                };
            }
             
            _fullScreen.triangles = tris;
   
            
            _fullScreen.uv = uv;
        }
        return _fullScreen;
    }

    static Mesh _face1;
    public static Mesh GetFace()
    {
        if (null == _face1)
        {
            _face1 = new Mesh();
            Vector3[] vertices = new Vector3[4]
            {
            new Vector3(-0.5f, 0, 0),
            new Vector3(0.5f, 0, 0),
            new Vector3(-0.5f, 1, 0),
            new Vector3(0.5f, 1, 0)
            };
            _face1.vertices = vertices;
            int[] tris = new int[6]
            {
            0, 2, 1,
            2, 3, 1
            };
            _face1.triangles = tris;
            Vector3[] normals = new Vector3[4]
            {
            -Vector3.forward,
            -Vector3.forward,
            -Vector3.forward,
            -Vector3.forward
            };
            _face1.normals = normals;
            Vector2[] uv = new Vector2[4]
            {
            new Vector2(0, 0),
            new Vector2(1, 0),
            new Vector2(0, 1),
            new Vector2(1, 1)
            };
            _face1.uv = uv;
        }
        
        return _face1;
    }


#if UNITY_EDITOR

    [MenuItem("TA/Save Mesh")]
    public static void  SaveMesh()
    {
        /*_face2 = null;
        Mesh m = GetFaceDown();
        GameObject g = GameObject.CreatePrimitive(PrimitiveType.Cube);
        g.GetComponent<MeshFilter>().sharedMesh = GetFaceDown();*/

        string path = EditorUtility.SaveFilePanelInProject("", "", "mesh", "");
        if (path.Length > 0)
        {
            _faceDown = null;
            AssetDatabase.CreateAsset(GetFaceDown(), path);
            AssetDatabase.ImportAsset(path);
        }

    }
#endif
    static Mesh _faceDown;
    public static Mesh GetFaceDown()
    {
        if (null == _faceDown)
        {
            _faceDown = new Mesh();
            Vector3[] vertices = new Vector3[4]
            {
            new Vector3(-0.5f, 0, -0.5f),
            new Vector3(0.5f, 0, -0.5f),
            new Vector3(-0.5f, 0, 0.5f),
            new Vector3(0.5f, 0, 0.5f)
            };
            _faceDown.vertices = vertices;
            int[] tris = new int[6]
            {
            0, 2, 1,
            2, 3, 1
            };
            _faceDown.triangles = tris;
            Vector3[] normals = new Vector3[4]
            {
            -Vector3.forward,
            -Vector3.forward,
            -Vector3.forward,
            -Vector3.forward
            };
            _faceDown.normals = normals;
            Vector2[] uv = new Vector2[4]
            {
            new Vector2(0, 0),
            new Vector2(1, 0),
            new Vector2(0, 1),
            new Vector2(1, 1)
            };
            _faceDown.uv = uv;
        }

        return _faceDown;
    }

}
