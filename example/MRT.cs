using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MRT : MonoBehaviour
{
    string[] bufferNames = new string[] { "RT0", "RT1" };
    Camera cam;
    public RenderTexture[] rts;
    public RenderBuffer [] buffers;
    void Start()
    {
        cam = GetComponent<Camera>();
        cam.allowHDR = true;

        rts = new RenderTexture[2];
        buffers = new RenderBuffer[2];
        rts[0] = new RenderTexture((int)cam.pixelWidth, (int)cam.pixelHeight, 24, RenderTextureFormat.ARGBFloat);
        rts[0].filterMode = FilterMode.Point;
        rts[0].name = bufferNames[0];
        rts[0].Create();
        buffers[0] = rts[0].colorBuffer;

        rts[1] = new RenderTexture((int)cam.pixelWidth, (int)cam.pixelHeight, 0, RenderTextureFormat.ARGBFloat);
        rts[1].filterMode = FilterMode.Point;
        rts[1].name = bufferNames[1];
        rts[1].Create();
        buffers[1] = rts[1].colorBuffer;
        

        cam.SetTargetBuffers(buffers, rts[0].depthBuffer);
    }

     
}
