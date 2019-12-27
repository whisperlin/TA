using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwitchRole : MonoBehaviour
{
    int index = 0;
    public GameObject[] roles ;
    GameObject cur = null;
    // Start is called before the first frame update
    void Start()
    {
        Next();
    }

    // Update is called once per frame
    public void Next()
    {
        for (int i = 0; i < roles.Length; i++)
        {
            roles[i].SetActive(i == index);
            if(i == index)
            cur = roles[i];
        }
        index++;
        if (index >= roles.Length) 
            index = 0;
    }
    private void Update()
    {
         
            if (cur != null)
            {
                if (Input.touchCount == 1 && Input.touches[0].phase == TouchPhase.Moved)
                {
                    cur.transform.localRotation = Quaternion.Euler(0f, cur.transform.localRotation.eulerAngles.y - 0.5f*Input.touches[0].deltaPosition.x, 0f);
                }
            }
         
    }
}
