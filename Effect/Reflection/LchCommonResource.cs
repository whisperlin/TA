 
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

public class LchCommonResource  
{
    public  static void CheckRT(ref RenderTexture rt , int width, int height, int depth, RenderTextureFormat format = RenderTextureFormat.Default,bool minMap = false)
    {
        if (null != rt)
        {
            if (rt.width != width || rt.height != height)
            {
                GameObject.DestroyImmediate(rt, true);
            }
        }
        if (null == rt)
        {
            if (minMap)
            {
                rt = new RenderTexture(width, height, depth, format, 5);
                rt.useMipMap = true;
                rt.autoGenerateMips = true;
            }
            else
            {
                rt = new RenderTexture(width, height, depth, format, 0);
            }
        }
    }

    public static void SafeRelease(ref Object obj)
    {
        if(null != obj)
        GameObject.DestroyImmediate(obj, true);
    }
    public static void SafeRelease(ref Texture obj)
    {
        if (null != obj)
            GameObject.DestroyImmediate(obj, true);
    }

    internal static void SafeRelease(ref RenderTexture rt)
    {
        if (null != rt)
            GameObject.DestroyImmediate(rt, true);
    }
}
