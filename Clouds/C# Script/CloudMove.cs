using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CloudMove : MonoBehaviour
{
    public Material CloudMaterial;
    public float Speed = 1;

    // Start is called before the first frame update
    void Start()
    {

    }
    // Update is called once per frame
    private void Update()
    {
        CloudMaterial.SetFloat("_CloudMove", CloudMaterial.GetFloat("_CloudMove") + 0.001f * Speed);
    }
}
