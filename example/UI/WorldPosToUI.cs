using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;



public class WorldPosToUI : MonoBehaviour
{
    public Canvas _ui_canvas;
    public RectTransform rectTransform;
    public Transform rf;
    // Start is called before the first frame update
    void Start()
    {
       
    }

    // Update is called once per frame
    void Update()
    {
        if (null == _ui_canvas)
            _ui_canvas = GetComponent<Canvas>();
        if (null == _ui_canvas || null == rectTransform || null == rf)
            return;
        rectTransform.anchoredPosition = _ui_canvas.WorldToCanvas(rf.position);
    }
}
