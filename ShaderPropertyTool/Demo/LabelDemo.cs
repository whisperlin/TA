using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LabelDemo : MonoBehaviour
{
    [Label("雾1")]
    public bool fog01 = true;
    // 雾 1
    [Label("雾浓度", "fog01", 0.0f, 0.05f)]
    public float fogDensity = 0.02f;  
    [Label("雾高度衰减系数", "fog01", 0.001f, 0.3f)]
    public float fogHeightFalloff = 0.2f;  
    [Label("雾高度", "fog01")]
    public float fogHeight = 0.0f;

    [Label("雾2")]
    public bool fog02 = true;
    [Label("雾浓度 2", "fog02", 0.0f, 0.05f)]
    public float fogDensity2 = 0.02f;
    [Label("雾高度衰减系数 2", "fog02", 0.001f, 0.3f)]
    public float fogHeightFalloff2 = 0.2f;
    [Label("雾高度 2", "fog02")]
    public float fogHeight2;

    [Label("如果需要HDR，属性名包含HDR")]
    public Color fogInscatteringColorHDR = new Color(0.447f, 0.639f, 1.0f);

    [Label("反向开关测试")]
    public bool op = true;
    [Label("开关关了你就见到我了", "!op")]
    public float val = 1;

}
