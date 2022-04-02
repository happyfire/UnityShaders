using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyProjector : MonoBehaviour
{
    public bool Orthographic = true;    
    float _orthoSize;
    float _near;
    float _far;

    float _aspect;

    Matrix4x4 _projectorMatrix;

    void Awake()
    {
        
    }

    // Start is called before the first frame update
    void Start()
    {
        BoxCollider collider = GetComponent<BoxCollider>();
        _orthoSize = collider.size.y / 2;
        _near = -collider.size.z / 2;
        _far = collider.size.z / 2;
        _aspect = collider.size.x / collider.size.y;

        if(Orthographic){
            _projectorMatrix = Matrix4x4.Ortho(-_aspect * _orthoSize, _aspect * _orthoSize, -_orthoSize, _orthoSize, _near, _far);
        }
        else{
            float _fov = 60;
            _projectorMatrix = Matrix4x4.Perspective(_fov, _aspect, _near, _far);
        }

        

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}

