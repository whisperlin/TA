using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UILod : MonoBehaviour
{
    public void Far()
    {
        QualitySettings.lodBias = 2;
    }

    public void Near()
    {
        QualitySettings.lodBias = 1;
    }
}
