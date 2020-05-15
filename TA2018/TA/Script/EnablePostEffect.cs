using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnablePostEffect : MonoBehaviour
{
    

    public void EnaglePostProcessLayer( )
    {
        UnityEngine.Rendering.PostProcessing.PostProcessLayer postProcessLayer = GameObject.FindObjectOfType<UnityEngine.Rendering.PostProcessing.PostProcessLayer>();
        if (null != postProcessLayer)
        {
            postProcessLayer.enabled = true;
        }
    }

    public void DisaglePostProcessLayer()
    {
        UnityEngine.Rendering.PostProcessing.PostProcessLayer postProcessLayer = GameObject.FindObjectOfType<UnityEngine.Rendering.PostProcessing.PostProcessLayer>();
        if (null != postProcessLayer)
        {
            postProcessLayer.enabled = false;
        }
    }
}
