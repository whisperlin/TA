using UnityEngine;
using System.Collections;

public class AutoMove : MonoBehaviour {
	public float rotSpeed = 20;
	public float speed = 20;
	public float range;
	// Use this for initialization
	void Start () {
		range = speed;
	}
	
	// Update is called once per frame
	void Update () {
		transform.Rotate(0,rotSpeed*Time.deltaTime,0);
		transform.transform.Translate(Vector3.up * speed * Time.deltaTime);
	}
}
