using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public  class LchUVAreaPerviewTexture
{
    public Texture2D texture;
    const int width = 1024;
    public void Clear()
    {
        isfinish = true;
        Check();
        var pix = texture.GetPixels();
        for (int i = 0; i < pix.Length; i++)
        {
            pix[i] = new Color(0, 0, 0, 0);
        }
        texture.SetPixels(pix);
    }
    public void Check()
    {
        if (null == texture)
        {
            texture = new Texture2D(width, width, TextureFormat.RGBA32, false);
            texture.filterMode = FilterMode.Bilinear;
        }
    }
    bool isfinish = true;
    Vector2[] uvs;
    int[] triangles;
    int curIndex = 0;
    public void DrawUVs(Vector2[] uvs, int[] triangles)
    {
        Clear();
        this.uvs = uvs;
        this.triangles = triangles;
        this.curIndex = 0;
        isfinish = false;

    }

    public void Update()
    {
        if (isfinish)
            return;
        for (int i = 0; i < 40; i++)
        {
            if (curIndex < triangles.Length)
            {
                int id0 = triangles[curIndex];
                int id1 = triangles[curIndex + 1];
                int id2 = triangles[curIndex + 2];
                DrawLine(uvs[id0], uvs[id1]);
                DrawLine(uvs[id1], uvs[id2]);
                DrawLine(uvs[id0], uvs[id2]);

                curIndex += 3;
            }
            else
            {
                texture.Apply();
                isfinish = true;
                return;

            }
        }
        texture.Apply();

    }
    void DrawLineFun(Texture2D a_Texture, int x1, int y1, int x2, int y2, int lineWidth, Color a_Color)
    {
        float xPix = x1;
        float yPix = y1;

        float width = x2 - x1;
        float height = y2 - y1;
        float length = Mathf.Abs(width);
        if (Mathf.Abs(height) > length) length = Mathf.Abs(height);
        int intLength = (int)length;
        float dx = width / (float)length;
        float dy = height / (float)length;
        for (int i = 0; i <= intLength; i++)
        {
            a_Texture.SetPixel((int)xPix, (int)yPix, a_Color);

            xPix += dx;
            yPix += dy;
        }
    }
    private void DrawLine(Vector2 uv0, Vector2 uv1)
    {

        DrawLineFun(texture, (int)(width * uv0.x), (int)(uv0.y * width), (int)(uv1.x * width), (int)(uv1.y * width), 1, Color.yellow);


    }

    public void Release()
    {
        if (null != texture)
        {
            GameObject.DestroyImmediate(texture, true);
            texture = null;
        }
    }
}
