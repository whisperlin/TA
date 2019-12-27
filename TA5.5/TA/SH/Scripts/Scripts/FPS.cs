using System;
using UnityEngine;

public class FPS : MonoBehaviour
{
    private float fps;
    private float frames;
    private float lastInterval;
    private float num;
    private float sum;
    private float upDataInterval = 0.5f;

    private void OnGUI()
    {
        GUI.color = Color.green;
        GUILayout.Label(string.Concat(new object[] { "fps:", this.fps.ToString("f2"), "    ", this.sum / this.num }), new GUILayoutOption[0]);
    }

    private void Start()
    {
        this.lastInterval = Time.realtimeSinceStartup;
        this.frames = 0f;
    }

    private void Update()
    {
        this.frames++;
        float realtimeSinceStartup = Time.realtimeSinceStartup;
        if (realtimeSinceStartup > (this.lastInterval + this.upDataInterval))
        {
            this.fps = this.frames / (realtimeSinceStartup - this.lastInterval);
            this.frames = 0f;
            this.lastInterval = realtimeSinceStartup;
            this.sum += this.fps;
            this.num++;
        }
    }
}

