using UnityEngine;

public class WalkerRenderer : MonoBehaviour
{
    public Material walkerMaterial;

    public RenderTexture currentSource;
    public RenderTexture currentDest;
    
    
    public Texture spriteTexture;
    public Texture spriteTextureBg;
    private float timer = 0.0f;
    public float speed = 0.5f;

    public float interpolationStrength = 1.0f;  // 初始插值强度
    void Start()
    {
        // Initialize the textures
        
        
        // Initialize with the sprite texture
        // Graphics.Blit(spriteTexture, currentSource);
        // Graphics.Blit(spriteTextureBg, currentDest);
        //Blit 是 "Block Image Transfer" 的缩写，用于将一个纹理复制到另一个纹理。 
        // Graphics.Blit(spriteTextureBg,  currentDest);
        Graphics.Blit(spriteTextureBg, currentSource);
    }

    void Update()
    {
        // Set the speed of the walker
        timer+= Time.deltaTime;
        if(timer > speed)
        {
            timer = 0.0f;
            
            // Set the input texture for the material
            walkerMaterial.SetTexture("_InputTex", currentSource);
            //set the input random val for v2
            Vector2 randInput = new Vector2(Random.value, Random.value);
            walkerMaterial.SetVector("_RandInput", randInput);
            
            // Perform the effect
            //currentSource 是源纹理，currentDest 是目标纹理，walkerMaterial 是用于渲染的材质。
            //这句代码的意思是将 currentSource 这个纹理复制到 currentDest 这个纹理上，
            //并使用 walkerMaterial 这个材质进行渲染
            //walkerMaterial 渲染出来的纹理会出现在 currentDest 上。
            Graphics.Blit(currentSource, currentDest, walkerMaterial);

            // Swap textures
            Swap(ref currentSource, ref currentDest);
        }
    }

    private void Swap(ref RenderTexture source, ref RenderTexture dest)
    {
        (currentSource, currentDest) = (currentDest, currentSource);
    }
    
    void OnDestroy()
    {
        // Release the resources
        //walkerTextureA.Release();
        //walkerTextureB.Release();
    }
}