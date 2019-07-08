using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LookAtTarget : MonoBehaviour {

    public enum BONE_TYPE
    {
        Autodesk3dsMAX,
    };
    [Header("骨骼类型")]
    public BONE_TYPE type = BONE_TYPE.Autodesk3dsMAX;
    [Header("控制骨骼")]
    public Transform bone;
    [Header("目标相机")]
    public Transform target;

    public static Transform temp;
    public static Transform temp2;

    [Header("旋转限制")]
    public Vector2 RotationLimit = new Vector2(30f, 60f);
 

   
    [Header("是否只做y轴旋转")]
    public bool yRotOnly = false;

    [Header("目标y轴偏移")]
    public float yOffset = 0f;
 
     
    public static float AngleSigned(Vector3 v1, Vector3 v2, Vector3 n)
    {
        return Mathf.Atan2(
            Vector3.Dot(n, Vector3.Cross(v1, v2)),
            Vector3.Dot(v1, v2)) * Mathf.Rad2Deg;
    }

    void LateUpdate() {
        if (null == temp)
        {
            GameObject t = new GameObject("LookAtTarget");
            t.hideFlags = HideFlags.HideAndDontSave;
            temp = t.transform;
        }
        if (null == temp2)
        {
            GameObject t = new GameObject("LookAtTarget");
            t.hideFlags = HideFlags.HideAndDontSave;
            temp2 = t.transform;
        }
        temp.transform.position = bone.transform.position;
        if (type == BONE_TYPE.Autodesk3dsMAX)
        {
            temp.transform.LookAt(bone.up + bone.position ,Vector3.up);
        }
        Vector3  baseForward  = temp.transform.forward;
        temp2.transform.position = bone.transform.position;
        //temp2.transform.parent = temp;
        temp2.rotation = bone.rotation;
        temp2.transform.parent = temp;


        Vector3 targetPos = target.position + new Vector3(0, yOffset, 0);
 
        Vector3 _forward = (targetPos  - temp.position).normalized;
 
        //y朝向得到修正。

        if (yRotOnly)
        {
            Vector3 local_forward = temp.worldToLocalMatrix.MultiplyVector(_forward);
            Vector3 yBase = Vector3.forward;
            Vector3 yForward = new Vector3(local_forward.x, 0f, local_forward.z).normalized;
            float rRotationLimity = Mathf.Deg2Rad * RotationLimit.y;
            float sign = Vector3.Dot(Vector3.up, Vector3.Cross(Vector3.forward, yForward));
            float BdotF = Vector3.Dot(yBase, yForward);
            float yAngle = Mathf.Acos(BdotF);
            if (yAngle > rRotationLimity)
            {
                _forward = Quaternion.Euler(0f, rRotationLimity * sign * Mathf.Rad2Deg, 0f) * baseForward;
                //Debug.LogError("yAngle = " + yAngle);
            }
            else
            {
                _forward = Quaternion.Euler(0f, yAngle * sign * Mathf.Rad2Deg, 0f) * baseForward;
            }
        }
        else
        {
            //x轴修正。
            {
 
                Vector3 dir = targetPos - temp.position;
                float lengthXY = Mathf.Sqrt(dir.x*dir.x+dir.z*dir.z);
                if (dir.y != 0f)
                {
                    float sY = dir.y >= 0 ? 1 : -1;
                    float tan = Mathf.Abs(dir.y) / lengthXY;
                    float ag = Mathf.Atan(tan);
                    float aRotationLimitx = Mathf.Deg2Rad * RotationLimit.x;
                    if (ag > aRotationLimitx)
                    {
                        float y = Mathf.Atan(aRotationLimitx) * sY;
                        y *= lengthXY;
                        targetPos = new Vector3(targetPos.x, temp.position.y + y, targetPos.z);
                        _forward = (targetPos - temp.position).normalized;
                    }
                }
            }
            //y轴修正。
            {
                Vector3 local_target = temp.worldToLocalMatrix.MultiplyPoint(targetPos);
                float lengthXZ = Mathf.Sqrt(local_target.x* local_target.x+ local_target.z* local_target.z);
                Vector3 yBase = Vector3.forward;
                Vector3 yForward = new Vector3(local_target.x, 0f, local_target.z).normalized;
                float rRotationLimity = Mathf.Deg2Rad * RotationLimit.y;
                float sign = Vector3.Dot(Vector3.up, Vector3.Cross(Vector3.forward, yForward));
                float BdotF = Vector3.Dot(yBase, yForward);
                float yAngle = Mathf.Acos(BdotF);
                if (yAngle > rRotationLimity)
                {
                    yAngle = rRotationLimity;
                }
                var new_local = Quaternion.Euler(0f, yAngle * sign * Mathf.Rad2Deg, 0f) * yBase * lengthXZ;
                var target = temp.localToWorldMatrix.MultiplyPoint(new_local);
                targetPos = new Vector3(target.x, targetPos.y, target.z);
                _forward = (targetPos - temp.position).normalized;

            }
        }

        temp.forward = _forward;
        bone.transform.rotation = temp2.rotation;
    }
}
