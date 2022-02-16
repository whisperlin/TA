using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public static class CanvasExtensions
{
    public static Vector2 WorldToCanvas(this Canvas canvas,
                                        Vector3 world_position,
                                        Camera camera = null)
    {
        if (camera == null)
        {
            //camera = canvas.worldCamera;
            camera = Camera.main;
        }

        var viewport_position = camera.WorldToViewportPoint(world_position);
        var canvas_rect = canvas.GetComponent<RectTransform>();

        return new Vector2((viewport_position.x * canvas_rect.sizeDelta.x) - (canvas_rect.sizeDelta.x * 0.5f),
                           (viewport_position.y * canvas_rect.sizeDelta.y) - (canvas_rect.sizeDelta.y * 0.5f));
    }
}
public class TestFont : MonoBehaviour
{
    public GameObject g;
    public Canvas _ui_canvas;
    public class UIContent 
    {
        public  Vector3 worldPos = Vector3.zero;
        public float distance = 0;
        public RectTransform rectTransform;
 
 

        public UIContent(RectTransform transform)
        {
 
            this.rectTransform = transform;
        }
    }

    public class UIContentComparer : IComparer<UIContent>
    {
        public int Compare(UIContent p1, UIContent p2)
        {
            return p1.distance.CompareTo(p2.distance);
        }
    }
    UIContentComparer cmp = new UIContentComparer();

    public List<UIContent> fonts = new List<UIContent>();
    // Start is called before the first frame update
    void Start()
    {
        
        for (int i = 0; i < 1000; i++)
        {
            GameObject g1 = GameObject.Instantiate(g);
            g1.transform.SetParent( transform);
            fonts.Add( new UIContent(  (RectTransform)g1.transform ));
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (null == _ui_canvas)
            _ui_canvas = GetComponent<Canvas>();
        if (null == _ui_canvas)
            return;

        fonts.Sort(cmp);
        for (int i = 0; i < fonts.Count; i++)
        {
            fonts[i].rectTransform.SetAsLastSibling();

            fonts[i].rectTransform.anchoredPosition = _ui_canvas.WorldToCanvas(new Vector3(Random.Range(0, 10), Random.Range(0, 2), Random.Range(0, 10)));
            
        }
    }
}
