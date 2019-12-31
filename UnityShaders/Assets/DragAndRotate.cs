using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DragAndRotate : MonoBehaviour
{
    public Transform Target;

    public float RotSpeed = 50f;

    //模型绕x轴和y轴旋转的角度
    private float m_rotX = 0.0f;
    private float m_rotY = 0.0f;
    private Quaternion m_rotation;

    public float Damping = 10f;

    void Start()
    {
        if(Target == null){
            Target = this.transform;    
        }

        m_rotX = transform.eulerAngles.x;
        m_rotY = transform.eulerAngles.y;
    }

    void RotateModel(){
        m_rotX += Input.GetAxis("Mouse Y") * RotSpeed; //鼠标上下拖动模型绕x轴旋转
        m_rotY -= Input.GetAxis("Mouse X") * RotSpeed; //鼠标左右拖动模型绕y轴旋转

        m_rotX = ClampAngle(m_rotX, -90, 90);

        m_rotation = Quaternion.AngleAxis(m_rotX, Vector3.right) * Quaternion.AngleAxis(m_rotY, Vector3.up);
        //m_rotation = Quaternion.Euler(m_rotX, m_rotY, 0);

        transform.rotation = Quaternion.Lerp(transform.rotation, m_rotation, Time.deltaTime * Damping);
    }

    private float ClampAngle(float angle, float min, float max)
    {
        if (angle < -360) angle += 360;
        if (angle > 360) angle -= 360;
        return Mathf.Clamp(angle, min, max);
    }

    void Update()
    {
        if(Target==null){
            return;
        }

        #if UNITY_STANDALONE || UNITY_WEBPLAYER || UNITY_EDITOR || UNITY_WEBGL
        if(Input.GetMouseButton(0)){
            RotateModel();
        }
        #elif UNITY_IOS || UNITY_ANDROID || UNITY_WP8
        if (Input.touchCount == 1) {
            Touch touch = Input.GetTouch (0);
            if (touch.phase == TouchPhase.Moved) {
                RotateModel();
            }
        }
        #endif
    }
}
