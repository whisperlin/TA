using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TwoPointScale : MonoBehaviour
{
    [Range(0,1)]
    public float t = 0;
    public Transform p1;
    public Transform p2;
    public Vector3 offset = Vector3.zero;
     
    // Start is called before the first frame update


    float initialFingersDistance;
    float initialScale;
    public float minHeight = -1.7f;

    void Update()
    {

        int fingersOnScreen = 0;
        // If there are two touches on the device...
        for(int i = 0; i < Input.touches.Length; i++)
        //foreach (Touch touch in Input.touches)
        {
            Touch touch =  Input.touches[i];
            fingersOnScreen++;

            if (fingersOnScreen == 2)
            {
                //First set the initial distance between fingers so you can compare.
                if (touch.phase == TouchPhase.Began)
                {
                    initialFingersDistance = Vector2.Distance(Input.touches[0].position, Input.touches[1].position);
                    initialScale = t;
                }
                else
                {
                    var currentFingersDistance = Vector2.Distance(Input.touches[0].position, Input.touches[1].position);
                    t = initialScale + (currentFingersDistance - initialFingersDistance) * 0.0015f;
                    if (t > 1f)
                        t = 1f;
                    if (t < 0f)
                        t = 0f;
                }
            }
            /*else
            {
                if (touch.phase != TouchPhase.Began)
                {
                    target.transform.localRotation = Quaternion.Euler(0f, target.transform.localRotation.eulerAngles.y + 0.2f* Input.touches[0].deltaPosition.x,0f);
                    
                }
            }*/
        }

        if (Input.touchCount == 1 && Input.touches[0].phase == TouchPhase.Moved)
        {
            offset.y -= Input.touches[0].deltaPosition.y*0.001f;
            if (offset.y > 0f)
                offset.y = 0f;
            if (offset.y < minHeight)
                offset.y = minHeight;
        }
        transform.position = Vector3.Lerp(p1.position,p2.position,t)+ offset;
        transform.forward = Vector3.Lerp(p1.forward, p2.forward, t) ;
    }
}
