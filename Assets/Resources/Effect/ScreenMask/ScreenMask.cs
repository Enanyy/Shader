using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenMask : MonoBehaviour {

    private string mShaderName = "Custom/ScreenMask";

    public Shader mShader;
    private Material mMaterial;
    Shader shader
    {
        get
        {
            if (mShader == null)
            {
                //找到当前的Shader文件
                mShader = Shader.Find(mShaderName);
            }
            return mShader;
        }
    }

    Material material
    {
        get
        {
            if (mMaterial == null)
            {
                mMaterial = new Material(shader);
                mMaterial.hideFlags = HideFlags.HideAndDontSave;
                Texture2D mask = Resources.Load<Texture2D>("Effect/ScreenMask/mask");
             
                mMaterial.SetTexture("_MaskTex", mask);
            }
            return mMaterial;
        }
    }


    
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            Graphics.Blit(source, destination, material);
        }
    }

}
