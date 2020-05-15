using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public class PostProcessingCtrl : MonoBehaviour
{
    public UnityEngine.Rendering.PostProcessing.PostProcessVolume postProcessVolume;
    public void BloomCtrl(bool b)
    {
        Bloom bloom = postProcessVolume.profile.GetSetting<Bloom>();
       
        if (null != bloom)
        {
            bloom.active = b;
 
        }
            
    }
    
}
