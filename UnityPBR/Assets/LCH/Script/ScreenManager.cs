using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenManager
{

    public static int baseWidth = -1, baseHeight = -1;
    public static void SetScreenSize(  )
    {
        if (baseWidth == -1)
        {
            baseWidth = Screen.width;
            baseHeight = Screen.height;
        }
        Screen.SetResolution(baseWidth/2, baseHeight/2, true);
    }
    public static void ResetScreen()
    {
        if (baseWidth == -1)
            return;
        Screen.SetResolution(baseWidth, baseHeight, true);
    }

    public static void setFPS(int fps)
    {
        Application.targetFrameRate = fps;
        QualitySettings.vSyncCount = 0;
    }
}
