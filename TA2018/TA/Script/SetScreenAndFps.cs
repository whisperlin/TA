using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetScreenAndFps : MonoBehaviour
{
    public int fps = 30;
    public int screenWidth = 1334;
    public int screenHeight = 750;
    // Start is called before the first frame update
    void Start()
    {
        Screen.SetResolution(screenWidth, screenHeight, true);
        Application.targetFrameRate = fps;
        QualitySettings.vSyncCount = 0;
    }

     
}
