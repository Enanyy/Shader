using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MergeTexture : MonoBehaviour {

    public Vector4 rect = new Vector4(0,0,249,264);

    private void Awake()
    {
        Renderer renderer = GetComponent<Renderer>();
        if(renderer)
        {
            Material material = renderer.material;
            if(material)
            {
                material.SetVector("_Rect", rect);
            }
        }
    }
}
