using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class LabelDemo : MonoBehaviour
{
    [Label("雾1")]
    public bool fog01 = true;
    // 雾 1
    [Label("雾浓度","fog01", 0.0f, 0.05f)]
    public float fogDensity = 0.02f; // This is the global density factor, which can be thought of as the fog layer's thickness.
    [Label("雾高度衰减系数","fog01", 0.001f, 0.3f)]
    public float fogHeightFalloff = 0.2f; // Height density factor, controls how the density increases as height decreases. Smaller values make the transition larger.
    [Label("雾高度", "fog01")]
    public float fogHeight = 0.0f;
     

    [Label("雾2")]
    public bool fog02 = true;
    // 雾 2
    [Label("雾浓度 2", "fog02",0.0f, 0.05f)]
    public float fogDensity2 = 0.02f;
 
    [Label("雾高度衰减系数 2", "fog02", 0.001f, 0.3f)]
    public float fogHeightFalloff2 = 0.2f;
    [Label("雾高度 2", "fog02")]
    public float fogHeight2;

    [Label("雾色")]
    public Color fogInscatteringColor = new Color(0.447f, 0.639f, 1.0f); // Sets the inscattering color for the fog. Essentially, this is the fog's primary color.

    [Label("雾色2")]
    [ColorUsage(false)]
    public Color fogInscatteringColor2 = new Color(0.447f, 0.639f, 1.0f); // Sets the inscattering color for the fog. Essentially, this is the fog's primary color.
    [Label("雾最大不透明度")]
    [Range(0.0f,1.0f)]
    public float fogMaxOpacity = 1.0f; // This controls the maximum opacity of the fog. A value of 1 means the fog will be completely opaque, while 0 means the fog will be essentially invisible.
    [Label("雾开始距离")]
    [Range(0.0f,200.0f)]
    public float startDistance = 0.0f; // Distance from the camera that the fog will start.
 

    [Label("方向光")]
    public Light dirLight = null;
 
    [Label("方向光范围系数", 2.0f, 64.0f)]
    public float directionalInscatteringExponent = 4.0f; // Controls the size of the directional inscattering cone, which is used to approximate inscattering from a directional light source.

    [Label("方向光影响开始距离")]
    public float directionalInscatteringStartDistance = 0.0f; // Controls the start distance from the viewer of the directional inscattering, which is used to approximate inscattering from a directional light.
    [ColorUsage(false)]
    [Label("方向光颜色")]
    public Color directionalInscatteringColor = new Color(0.25f, 0.25f, 0.125f); // Sets the color for directional inscattering, used to approximate inscattering from a directional light. This is similar to adjusting the simulated color of a directional light source.
    [Label("方向光强度", 0.0f, 10.0f)]
    public float directionalInscatteringIntensity = 1.0f;

   }
   
