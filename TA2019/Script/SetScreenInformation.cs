using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetScreenInformation : MonoBehaviour
{
    [Label("设置屏幕大小")]
    public bool enableScreenSize = true;

    [Label("屏幕宽", "enableScreenSize")]
    public int size = 1334;

    [Label("设置FPS")]
    public bool enableFps = true;


    [Label("fps", "enableFps")]
    public int fps = 30;

     

    // Update is called once per frame
    public void UpdateScreen()
    {
        if(enableScreenSize)
        {
            if (size > 0)
                LScreenScreenManager.SetScreenSize();
            else
                LScreenScreenManager.ResetScreen();
        }
        if (enableFps)
        {
            LScreenScreenManager.setFPS(fps);
        }
            
    }
}
