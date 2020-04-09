using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
//UI选择左下角对齐.
[RequireComponent(typeof(Image))]
public class UpdateUIPosition : MonoBehaviour {

    public Image image;
    public Camera cam;
    public Transform  target;
    
	// Use this for initialization
	void Start () {
        if (null == cam)
        {
            cam = Camera.main;
        }
        image = GetComponent<Image>();
		
	}
    
    // Update is called once per frame
    void LateUpdate() {
        if (null == target)
            return;
        
        Vector3 pos =  cam.WorldToScreenPoint(target.position);
        image.rectTransform.anchoredPosition = new Vector2(pos.x,pos.y);
         

    }
}
