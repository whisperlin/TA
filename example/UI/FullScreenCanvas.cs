using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class FullScreenCanvas : MonoBehaviour
{
    Canvas canvas;
    // Start is called before the first frame update
    void Start()
    {
        canvas = gameObject.AddComponent<Canvas>();
        RectTransform rectTransform =  (RectTransform)canvas.transform;
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        rectTransform.pivot = new Vector2(0f, 1f);
        rectTransform.sizeDelta = new Vector2(Screen.width, Screen.height)  ;
        rectTransform.position = Vector2.zero;
        


    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
