using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
[RequireComponent(typeof(Text))]
public class FpsUI : MonoBehaviour
{
    Text txt;
    float time;

    //string testString = "11111111";

    string fpsText = "600";
    // Start is called before the first frame update
    void Start()
    {
        txt = GetComponent<Text>();
    }

    private int frameCount;

    void Update()
    {
        time += Time.unscaledDeltaTime;
        frameCount++;
        if (time >= 1 && frameCount >= 1)
        {
 
            float fps = frameCount / time;
            time = 0;
            frameCount = 0;
            int fpsInt = (int)fps;
            txt.text = IntStringManager.GetIntString(fpsInt); 
            

        }
    }
 
}
